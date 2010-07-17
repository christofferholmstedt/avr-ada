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

with Interfaces;                   use type Interfaces.Unsigned_8;
with AVR.MCU;

package body Extern_Int is


   procedure On_Keypress;
   pragma Machine_Attribute (Entity         => On_Keypress,
                             Attribute_Name => "signal");
   pragma Export (C, On_Keypress, AVR.MCU.Sig_INT0_String);
   --  attach the routine On_Keypress to the external interrupt 0

   procedure On_Keypress is
   begin
      LED := LED + 1;
      MCU.PORTB := not LED;
   end On_Keypress;

end Extern_Int;
