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
with AVR.Real_Time.Timing_Events;  use AVR.Real_Time.Timing_Events;
with LED;

package body Blink_TE_Pkg is

   procedure Init is
   begin
      LED.Init;
   end Init;

   procedure LED_Off_Handler (Ev : access Timing_Event)
   is
   begin
      LED.Off_1;
      Set_Handler (E, 0.5, LED_On_Handler'Access);
   end LED_Off_Handler;

   procedure LED_On_Handler (Ev : access Timing_Event)
   is
   begin
      LED.On_1;
      Set_Handler (E, 0.5, LED_Off_Handler'Access);
   end LED_On_Handler;

end Blink_TE_Pkg;


