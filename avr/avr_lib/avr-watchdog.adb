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


--  Subprograms to access the on-chip watchdog timer.
--  Tested with ATmega8 only

with System.Machine_Code;          use System.Machine_Code;
with Ada.Unchecked_Conversion;

with AVR;                          use AVR;
with AVR.MCU;                      use AVR.MCU;
with AVR.Interrupts;

package body AVR.Watchdog is

   function WDT_To_Byte is
      new Ada.Unchecked_Conversion (WDT_Oscillator_Cycles, Unsigned_8);


   procedure Enable (Wdt : WDT_Oscillator_Cycles)
   is
   begin
      Interrupts.Save_Disable;
      WDTCR_Bits := (WDCE_Bit => True,
                     WDE_Bit  => True,
                     others   => False);
      WDTCR := (WDT_To_Byte (Wdt) or WDE_Mask);
      Interrupts.Restore;
   end Enable;


   procedure Disable
   is
   begin
      Interrupts.Save_Disable;
      WDTCR_Bits := (WDCE_Bit => True,
                     WDE_Bit  => True,
                     others   => False);
      WDTCR := 0;
      Interrupts.Restore;
   end Disable;


   procedure Wdr
   is
   begin
      Asm ("wdr", Volatile => True);
   end Wdr;

end AVR.Watchdog;
