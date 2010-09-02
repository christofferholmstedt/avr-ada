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

package body AVR.Serial.Char is

   procedure Put (S : AVR_String) is
   begin
      for I in S'Range loop
         AVR.Serial.Put (S (I));
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
         AVR.Serial.Put_Raw (C);
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
         AVR.Serial.Put (P.all);
         P := P + 1;
      end loop;
   end Put_C;


   procedure Put_Line (S : AVR_String) is
   begin
      AVR.Serial.Char.Put (S);
      AVR.Serial.Char.New_Line;
   end Put_Line;


   procedure Put_Line (S : Chars_Ptr) is
   begin
      AVR.Serial.Char.Put_C (S);
      AVR.Serial.Char.New_Line;
   end Put_Line;


   procedure New_Line is
      EOL : constant := 16#0A#;
   begin
      AVR.Serial.Put_Raw (EOL);
   end New_Line;


   procedure CRLF is
      LF : constant := 16#0A#;
      CR : constant := 16#0D#;
   begin
      AVR.Serial.Put_Raw (LF);
      AVR.Serial.Put_Raw (CR);
   end CRLF;


   procedure Get_Line (S    : out AVR_String;
                       Last : out Unsigned_8)
   is
      C : Character;
   begin
      for I in S'First .. S'Last loop
         C := AVR.Serial.Get;
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

end AVR.Serial.Char;

-- Local Variables:
-- mode:ada
-- End:
