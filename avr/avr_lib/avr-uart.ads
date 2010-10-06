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


--  Subprograms to access the on-chip uart/usart in polled mode.

with AVR.Strings;                  use AVR.Strings;
with AVR.Programspace;             use AVR.Programspace;

package AVR.UART is
   pragma Preelaborate;

   --  type Baud_Rate is (B_1200, B_2400, B_4800, B_9600, B_14400, B_19200,
   --                     B_28800, B_38400, B_56000, B_57600, B_115200,
   --                     B_128000, B_256000);
   --    type Baud_Rate is range 0 .. 256000;

   --  initialize the registers for a given Baud speed.  Requires
   --  AVR.Config.Clock_Speed
   --  procedure Init (Baud : Baud_Rate := 19200);

   --  initialize the registers, internal clock and baud rate generator
   procedure Init (Baud_Divider : Unsigned_16;
                   Double_Speed : Boolean := False);

   type Buffer_Ptr is access all Nat8_Array;
   procedure Init_Interrupt_Read (Baud_Divider   : Unsigned_16;
                                  Double_Speed   : Boolean := False;
                                  Receive_Buffer : Buffer_Ptr);

   --  used for interfacing with C
   --  can put out a C like zero ended string
   type Chars_Ptr is access all Character;
   pragma No_Strict_Aliasing (Chars_Ptr);

   --  Output routines
   procedure Put (Ch : Character);
   procedure Put_Raw (Data : Unsigned_8);

   procedure Put (S : AVR_String);
   --  procedure Put (S : Pstr20.Pstring);
   procedure Put (Str : Program_Address; Len : Unsigned_8);
   procedure Put_C (S : Chars_Ptr);
   procedure Put (S : Chars_Ptr) renames Put_C;

   procedure Put_Line (S : AVR_String);
   procedure Put_Line (S : Chars_Ptr);

   procedure New_Line;  --  only line-feed (LF)
   procedure CRLF;      --  DOS like CR & LF

   procedure Put (Data : Unsigned_8;
                  Base : Unsigned_8 := 10);

   procedure Put (Data : Integer_16;
                  Base : Unsigned_8 := 10);

   procedure Put (Data : Unsigned_16;
                  Base : Unsigned_8 := 10);

   procedure Put (Data : Unsigned_32;
                  Base : Unsigned_8 := 10);

   --  Input routines
   function Get return Character;
   function Get_Raw return Unsigned_8;
   procedure Get_Raw (Byte : out Unsigned_8);
   function Have_Input return Boolean;

   procedure Get_Line (S    : out AVR_String;
                       Last : out Unsigned_8);

private

   pragma Inline (Get);
   pragma Inline (Put_Raw);
   pragma Inline (Have_Input);

   procedure Put_Char (Ch : Character) renames Put;
   pragma Inline (Put_Char);

   pragma Inline (New_Line);
   pragma Inline (CRLF);

end AVR.UART;

