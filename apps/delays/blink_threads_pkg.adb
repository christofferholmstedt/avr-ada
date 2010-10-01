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
with AVR.MCU;
with Threads;
with LED;

package body Blink_Threads_Pkg is

   procedure Delay_MS (MS : Natural) is
      Ticks : Natural := Natural'Max (MS/2, 1);
   begin
      Threads.Sleep (Ticks);
   end;


   procedure Blinky_1 is
   begin
      loop
         LED.On_1;
         Delay_MS (600);

         LED.Off_1;
         Delay_MS (200);
      end loop;
    end Blinky_1;


    procedure Blinky_2 is
    begin
       loop
          LED.On_2;
          Delay_MS (800);

          LED.Off_2;
          Delay_MS (400);
       end loop;
    end Blinky_2;

end Blink_Threads_Pkg;