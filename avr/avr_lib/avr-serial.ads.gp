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

--  Subprograms to access the on-chip uart/usart in interrupt rx mode.

with System;                            use type System.Address;
with AVR.MCU;                           use AVR.MCU;

generic
   Buffer_Size : Positive;		-- Receiver buffer size (range 1..255)
package AVR.Serial is

   --  initialize the registers, internal clock and baud rate generator
   procedure Init (Baud_Divider : Unsigned_16;
                   Double_Speed : Boolean := False);

   --  procedure OSCCAL_Calibration;

   --  used for interfacing with C
   --  can put out a C like zero ended string
   type Chars_Ptr is access all Character;
   pragma No_Strict_Aliasing (Chars_Ptr);

   --  Output routines
   procedure Put (Ch : Character);
   procedure Put_Raw (Data : Unsigned_8);

   --  Input routines
   function Get return Character;
   function Get_Raw return Unsigned_8;
   procedure Get_Raw(Byte : out Unsigned_8);
   function Have_Input return Boolean;

   procedure Sender_Mode;
   procedure Receiver_Mode;

private

   pragma Inline (Get);
   pragma Inline (Put_Raw);
   pragma Inline (Have_Input);

   procedure Put_Char (Ch : Character) renames Put;
   pragma Inline (Put_Char);

   pragma Inline (Sender_Mode);
   pragma Inline (Receiver_Mode);

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
   RXCIE_Bit  : constant AVR.Bit_Number := MCU.RXCIE0_Bit;

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

end AVR.Serial;
