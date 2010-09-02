---------------------------------------------------------------------------
-- The AVR-Ada Library is free software;  you can redistribute it and/or --
-- modify it under terms of the  GNU General Public License as published --
-- by  the  Free Software  Foundation;  either  version 2, or  (at  your --
-- option) any later version.  The AVR-Ada Library is distributed in the --
-- hope that it will be useful, but  WITHOUT ANY WARRANTY;  without even --
-- the  implied warranty of MERCHANTABILITY or FITNESS FOR A  PARTICULAR --
-- PURPOSE. See the GNU General Public License for more details.         --
--                                                                       --
-- As a special exception, if other files instantiate generics from this --
-- unit,  or  you  link  this  unit  with  other  files  to  produce  an --
-- executable   this  unit  does  not  by  itself  cause  the  resulting --
-- executable to  be  covered by the  GNU General  Public License.  This --
-- exception does  not  however  invalidate  any  other reasons why  the --
-- executable file might be covered by the GNU Public License.           --
---------------------------------------------------------------------------
-- Modified by Warren W. Gay VE3WWG
---------------------------------------------------------------------------

with Ada.Unchecked_Conversion;
with System;                            use type System.Address;
with AVR.MCU;                           use AVR.MCU;
with AVR.Interrupts;

package body AVR.Serial is

   --
   --  Init
   --

   procedure Init (Baud_Divider : Unsigned_16;
                   Double_Speed : Boolean := False)
   is
      use AVR.Interrupts;        

      Data : Unsigned_8;
   begin

      Disable_Interrupts;

      -- Set baud rate
#if not UART = "UART" then
      UBRR := Baud_Divider;
#else
      UBRR := Low_Byte (Baud_Divider);
#end if;

#if not UART = "UART" then
      -- Enable 2x speed
      if Double_Speed then
         UCSRA := U2X_Mask;
      else
         UCSRA := 0;
      end if;
      -- UCSRA_Bits (U2X_Bit) := Double_Speed;
#end if;

      -- Enable receiver and transmitter
      UCSRB := +(RXEN_Bit => True,
                 TXEN_Bit => True,
                 RXCIE_Bit => True,     -- Enable Receiver interrupts
                 others => False);

#if UART = "USART" then
      -- Async. mode, 8N1
      UCSRC := +(UCSZ0_Bit => True,
                 UCSZ1_Bit => True,
                 URSEL_Bit => True,
                 others => False);

      --  at least on atmega8 UCSRC and UBRRH share the same address.
      --  When writing to the ACSRC register, the URSEL must be set,
      --  too.
#elsif UART = "USART0" then
      -- Async. mode, 8N1
      UCSRC := +(UCSZ0_Bit => True,
                 UCSZ1_Bit => True,
                 others => False);

#end if;

      -- Clear UART input queue
        
      while UCSRA_Bits(RXC_Bit) = True loop
         Data := UDR;     -- Empty data buffer
      end loop;
    
      Enable_Interrupts;

   end Init;

   procedure Sender_Mode
   is
   begin   
      -- Enable transmitter
      UCSRB := +(TXEN_Bit => True,
                 others => False);
   end Sender_Mode;
      
      
   procedure Receiver_Mode
   is
   begin
      -- Enable receiver
      UCSRB := +(RXEN_Bit => True,   
                 RXCIE_Bit => True,     -- Enable Receiver interrupts            
                 others => False);
   end Receiver_Mode;


   -- Receive buffer
   Max_Buffer_Size : constant Unsigned_16 := Unsigned_16(Buffer_Size);

   type Data_Buffer  is array (Unsigned_8 range 0..Unsigned_8(Max_Buffer_Size-1)) of Unsigned_8;
   
   Rx_Buf : Data_Buffer;
   Rx_Inx, Rx_Outx : Unsigned_8 := 0;
   
   pragma Volatile(Rx_Buf);
   pragma Volatile(Rx_Inx);
   pragma Volatile(Rx_Outx);
   
   -- Receive ISR Routine
   procedure Receiver_ISR;
   pragma Machine_Attribute (Entity => Receiver_ISR, Attribute_Name => "signal");

#if UART = "USART0" then
   pragma Export(C,Receiver_ISR,MCU.Sig_USART_RX_String);
#elsif UART = "USART" then
   pragma Export(C,Receiver_ISR,MCU.Sig_USART_RX_String);
#elsif UART = "UART" then
   pragma Export(C,Receiver_ISR,MCU.Sig_UART_RX_String);
#end if;
   
   procedure Receiver_ISR is
   begin
   
      while UCSRA_Bits(RXC_Bit) = True loop 
         Rx_Buf(Rx_Inx) := UDR;

         Rx_Inx := Rx_Inx + 1;
         if Rx_Inx > Rx_Buf'Last then
            Rx_Inx := Rx_Buf'First;
         end if;
      end loop;
   
   end Receiver_ISR;
   
   function Get_Raw return Unsigned_8 is
      Byte : Unsigned_8;
   begin
   
      while Rx_Outx = Rx_Inx loop
         null;
      end loop;
   
      Byte := Rx_Buf(Rx_Outx);

      Rx_Outx := Rx_Outx + 1;
      if Rx_Outx > Rx_Buf'Last then
         Rx_Outx := Rx_Buf'First;
      end if;
   
      return Byte;
   
   end Get_Raw;


   procedure Get_Raw(Byte : out Unsigned_8) is
   begin
      Byte := Get_Raw;
   end Get_Raw;


   function Have_Input return Boolean is
   begin
      return Rx_Outx /= Rx_Inx;
   end;
   

   function Get return Character is
      function To_Char is new Ada.Unchecked_Conversion (Target => Character,
                                                        Source => Unsigned_8);
   begin
      return To_Char (Get_Raw);
   end Get;  


   function To_U8 is
      new Ada.Unchecked_Conversion (Source => Character,
                                    Target => Unsigned_8);

   procedure Put (Ch : Character) is
   begin
      Put_Raw (To_U8 (Ch));
   end Put;


   procedure Put_Raw (Data : Unsigned_8) is
   begin
      -- wait until Data Register Empty (DRE) is signaled
      while UCSRA_Bits (UDRE_Bit) = False loop null; end loop;
      UDR := Data;

      --  avr-gcc 3.4.4 -Os -mmcu=atmega169
      --     0:   98 2f           mov     r25, r24
      --     2:   80 91 c0 00     lds     r24, 0x00C0
      --     6:   85 ff           sbrs    r24, 5
      --     8:   fc cf           rjmp    .-8             ; 0x2
      --     a:   90 93 c6 00     sts     0x00C6, r25
      --     e:   08 95           ret

      --  avr-gcc 3.4.4 -Os -mmcu=at90s8515
      --     0:   5d 9b           sbis    0x0b, 5 ; 11
      --     2:   fe cf           rjmp    .-4
      --     4:   8c b9           out     0x0c, r24       ; 12
      --     6:   08 95           ret

      --  avr-gcc 4.3.2 -Os -mmcu=atmega8
      --     0:   98 2f           mov     r25, r24
      --     2:   80 91 c0 00     lds     r24, 0x00C0
      --     6:   85 ff           sbrs    r24, 5
      --     8:   00 c0           rjmp    .+0
      --     a:   90 93 c6 00     sts     0x00C6, r25

   end Put_Raw;

end AVR.Serial;

-- Local Variables:
-- mode:ada
-- End:
