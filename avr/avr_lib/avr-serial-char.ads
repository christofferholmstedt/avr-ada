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

--  Subprograms to access the on-chip uart/usart in interrupt mode.

with AVR.Strings;                  use AVR.Strings;
with AVR.Programspace;             use AVR.Programspace;

generic
package AVR.Serial.Char is

   --  Output routines

   procedure Put (S : AVR_String);
   --  procedure Put (S : Pstr20.Pstring);
   procedure Put (Str : Program_Address; Len : Unsigned_8);
   procedure Put_C (S : Chars_Ptr);
   procedure Put (S : Chars_Ptr) renames Put_C;

   procedure Put_Line (S : AVR_String);
   procedure Put_Line (S : Chars_Ptr);

   procedure New_Line;              -- LF Only
   procedure CRLF;                  -- CR & LF

   --  Input routines
   procedure Get_Line (S    : out AVR_String;
                       Last : out Unsigned_8);

private

   pragma Inline(New_Line);
   pragma Inline(CRLF);

end AVR.Serial.Char;
