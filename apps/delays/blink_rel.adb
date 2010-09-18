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

--
--  use standard Ada relative delays for blinking.
--
--  depending on the configuration settings in the AVR support library
--  that either uses AVR.Real_Time is busy waits form AVR.Wait;
--

with LED;

procedure Blink_Rel is

   Off_Cycle : constant := 1.0;
   On_Cycle  : constant := 1.0;

begin
   --  configure LED as output
   LED.Init;

   loop
      LED.Off_1;
      delay Off_Cycle;
      LED.On_1;
      delay On_Cycle;
   end loop;

end Blink_Rel;
