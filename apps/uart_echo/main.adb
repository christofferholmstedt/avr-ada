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

with AVR;                          use AVR;
with AVR.UART;


procedure Main is
   C : Character;
begin

   --  51 -->  1200Bd @  1MHz
   --  12 -->  4800Bd @  1MHz

   --  51 -->  4800Bd @  4MHz
   --  12 --> 19200Bd @  4MHz

   --  51 -->  9600Bd @  8MHz
   --  25 --> 19200Bd @  8MHz
   --  15 --> 31250Bd @  8MHz

   -- 103 -->  9600Bd @ 16MHz
   --  51 --> 19200Bd @ 16MHz
   --  25 --> 38400Bd @ 16MHz

   AVR.UART.Init(51);

   loop
      C := UART.Get;
      UART.Put (C);
   end loop;

end Main;

