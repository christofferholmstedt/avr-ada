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


--   Title:    Read input port using external Interrupt
--   Author:   Peter Fleury <pfleury@gmx.ch> http://jump.to/fleury
--   Date:     December 2002

--   Description: Demonstrates use of external interrupts.  Each time
--   a push button is pressed, the external interrupt INT0 is called,
--   which increments the global variable led and outputs its value to
--   port B.  For simplicity, no de-bouncing is implemented.


with AVR;                          use AVR;

package Extern_Int is
   pragma Elaborate_Body;


   LED : Nat8 := 0;

end Extern_Int;
