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

with Ada.Unchecked_Conversion;
with System;                            use type System.Address;
with AVR.Int_Img;
with AVR.MCU;                           use AVR.MCU;
with AVR.Config;

package body AVR.UART is

#if UART = "USART0" then
   UCSRA      : Nat8 renames MCU.UCSR0A;
   UCSRA_Bits : Bits_In_Byte renames MCU.UCSR0A_Bits;
   UCSRB      : Nat8 renames MCU.UCSR0B;
   UCSRC      : Nat8 renames MCU.UCSR0C;

   UBRRL      : Nat8 renames MCU.UBRR0L;
   UBRRH      : Nat8 renames MCU.UBRR0H;
   UBRR       : Nat16 renames MCU.UBRR0;

   RXEN_Bit   : constant AVR.Bit_Number := RXEN0_Bit;
   TXEN_Bit   : constant AVR.Bit_Number := TXEN0_Bit;
   UCSZ0_Bit  : constant AVR.Bit_Number := UCSZ00_Bit;
   UCSZ1_Bit  : constant AVR.Bit_Number := UCSZ01_Bit;
   U2X_Mask   : constant                := U2X0_Mask;

   UDRE_Bit   : constant AVR.Bit_Number := MCU.UDRE0_Bit;

   UDR        : Nat8 renames MCU.UDR0;
   RXC_Bit    : constant AVR.Bit_Number := MCU.RXC0_Bit;

#elsif UART = "USART" then

   UCSZ0_Bit  : constant AVR.Bit_Number := MCU.UCSZ0_Bit;
   UCSZ1_Bit  : constant AVR.Bit_Number := MCU.UCSZ1_Bit;

   RXC_Bit    : constant AVR.Bit_Number := MCU.RXC_Bit;

#elsif UART = "UART" then
   UCSRA_Bits : Bits_In_Byte renames MCU.USR_Bits;

   UCSRB      : Unsigned_8 renames MCU.UCR;

   UBRRL      : Unsigned_8 renames MCU.UBRR;
   UBRR       : Unsigned_8 renames MCU.UBRR;

   UDR        : Unsigned_8 renames MCU.UDR;

   RXC_Bit    : constant AVR.Bit_Number := MCU.RXC_Bit;

#end if;

   --
   --  Init
   --

   --  procedure Init (Baud : Baud_Rate := 19200)
   --  is
   --     subtype B is Baud_Rate'Base;
   --     Ubrr : constant Unsigned_16 := Unsigned_16
   --       ((Config.Clock_Frequency + 8 * B (Baud)) /
   --          ((16 * B (Baud)) - 1));
   --  begin
   --     Init (Ubrr, False);
   --  end Init;


   procedure Init (Baud_Divider : Unsigned_16;
                   Double_Speed : Boolean := False)
   is
   begin
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
   end Init;


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


   procedure Put (S : AVR_String) is
   begin
      for I in S'Range loop
         Put (S (I));
      end loop;
   end Put;


--     procedure Put (S : Pstr20.Pstring) is
--     begin
--        for I in Unsigned_8'(1) .. Length(S) loop
--           Put (Element (S, I));
--        end loop;
--     end Put;


   procedure Put (Str : Program_Address; Len : Unsigned_8)
   is
      C : Unsigned_8;
      Text_Ptr : Program_Address := Str;
      use AVR.Programspace;
   begin
      for J in Unsigned_8'(1) .. Len loop
         C := Get (Text_Ptr);
         Put_Raw (C);
         Text_Ptr := Text_Ptr + 1;
      end loop;
   end Put;


   --  pointer calculation for putting C like zero ended strings
   function "+" (L : Chars_Ptr; R : Unsigned_16) return Chars_Ptr;
   pragma Inline ("+");

   function "+" (L : Chars_Ptr; R : Unsigned_16) return Chars_Ptr is
      function Addr is new Ada.Unchecked_Conversion (Source => Chars_Ptr,
                                                     Target => Unsigned_16);
      function Ptr is new Ada.Unchecked_Conversion (Source => Unsigned_16,
                                                    Target => Chars_Ptr);
   begin
      return Ptr (Addr (L) + R);
   end "+";

   procedure Put_C (S : Chars_Ptr) is
      P : Chars_Ptr := S;
   begin
      if P = null then return; end if;
      while P.all /= ASCII.NUL loop
         Put (P.all);
         P := P + 1;
      end loop;
   end Put_C;


   procedure Put_Line (S : AVR_String) is
   begin
      Put (S);
      New_Line;
   end Put_Line;


   procedure Put_Line (S : Chars_Ptr) is
   begin
      Put_C (S);
      New_Line;
   end Put_Line;


   procedure New_Line is
      EOL : constant := 16#0A#;
   begin
      Put_Raw (EOL);
   end New_Line;


   procedure Put (Data : Unsigned_8;
                  Base : Unsigned_8 := 10)
   is
   begin
      if Base /= 16 then
         declare
            Img : AStr3;
            L   : Unsigned_8;
         begin
            AVR.Int_Img.U8_Img (Data, Img, L);
            for I in 1 .. L loop
               Put (Img (I));
            end loop;
         end;
      else
         declare
            Img : AStr2;
         begin
            AVR.Int_Img.U8_Hex_Img (Data, Img);
            Put (Img (1));
            Put (Img (2));
         end;
      end if;
   end Put;


   procedure Put (Data : Integer_16;
                  Base : Unsigned_8 := 10)
   is
      Img : AStr5;
      L   : Unsigned_8;
   begin
      if Base /= 16 then
         if Data < 0 then
            Put ('-');
            AVR.Int_Img.U16_Img (Unsigned_16 (-Data), Img, L);
         else
            AVR.Int_Img.U16_Img (Unsigned_16 (Data), Img, L);
         end if;
         for J in Unsigned_8'(1) .. L loop
            Put (Img (J));
         end loop;
      else
         Put_Line ("Put(int16, base=16) not yet implemented");
      end if;
   end Put;


   procedure Put (Data : Unsigned_16;
                  Base : Unsigned_8 := 10)
   is
      Img : AStr5;
      L   : Unsigned_8;
   begin
      if Base = 16 then
         Put (High_Byte (Data), 16);
         Put (Low_Byte (Data), 16);
      elsif Base = 10 then
         AVR.Int_Img.U16_Img (Data, Img, L);
         for J in Unsigned_8'(1) .. L loop
            Put (Img (J));
         end loop;
      else
         Put_Line ("Put(u16) not yet implemented");
      end if;
   end Put;


   procedure Put (Data : Unsigned_32;
                  Base : Unsigned_8 := 10)
   is
      -- Img : AStr5;
      -- L   : Unsigned_8;
      pragma Not_Referenced (Base);
   begin
--      if Base = 16 then
         Put (Unsigned_8 (Data / 256 / 256 / 256), 16);
         Put (Unsigned_8 ((Data and 16#00FF0000#) / 256 / 256), 16);
         Put (Unsigned_8 ((Data and 16#0000FF00#) / 256), 16);
         Put (Unsigned_8 (Data and 16#000000FF#), 16);
--      end if;
   end Put;


   function Get return Character is
      function To_Char is new Ada.Unchecked_Conversion (Target => Character,
                                                        Source => Unsigned_8);
   begin
      return To_Char (Get_Raw);
   end Get;


   function Get_Raw return Unsigned_8 is
   begin
      while UCSRA_Bits (RXC_Bit) = False loop null; end loop;
      return UDR;
      --     0:   80 91 c0 00     lds     r24, 0x00C0
      --     4:   87 ff           sbrs    r24, 7
      --     6:   fc cf           rjmp    .-8             ; 0x0
      --     8:   80 91 c6 00     lds     r24, 0x00C6
      --     c:   08 95           ret
   end Get_Raw;


   procedure Get_Line (S    : out AVR_String;
                       Last : out Unsigned_8)
   is
      C : Character;
   begin
      for I in S'First .. S'Last loop
         C := Get;
         if C = ASCII.CR or C = ASCII.LF then
            Last :=  I - 1;
            return;
         else
            S (I) := C;
         end if;
      end loop;
      Last := S'Last;

      return;
   end Get_Line;


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
                 others => False);
   end Receiver_Mode;


   procedure Send_LIN_Break is
#if not UART = "UART" then
      Orig_Baud_Divider : constant Unsigned_16 := UBRR;
#else
      Orig_Baud_Divider : constant Unsigned_8 := UBRRL;
#end if;
   begin
      --  We send a 16#00#. That will pull the line low for 9 bit
      --  lengths.  In order to achieve a low of 13 bit times we have
      --  to increase the bit time by about 50%, i.e. reduce the baud
      --  rate by 2/3.
      --
      --  the Baud rate calculates as follows:
      --               Freq
      --  Baud = ---------------
      --          16 (UBBR + 1)
      --
      --  after transformation we get
      --
      --  UBBR (2/3Baud) = 1.5(UBBR + 1) - 1
      --
      --  I consider that formula too complicated for what we need.
      --  The pragmatic solution is to simply double the existing UBBR
      --  value.
      --
      --  The current setting is in UBBR
      --
      --  Freq [MHz] | Baud rate | UBBR |
      --      8.0    |      9600 |   51 |
      --
      UBRR := UBRR * 2;


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

      --
      Put_Raw (16#00#);

      --  reset the baud divider
      UBRR := Orig_Baud_Divider;

   end Send_LIN_Break;


end AVR.UART;

-- Local Variables:
-- mode:ada
-- End:
