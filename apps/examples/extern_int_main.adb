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


with AVR.Interrupts;
with AVR;                          use AVR;
with AVR.MCU;
with Extern_Int;

procedure Extern_Int_Main is
   Enable_Ext_Int0 : Boolean renames
#if MCU = "atmega8" or else MCU = "atmega32" then
     MCU.GICR_Bits (MCU.INT0_Bit);
#elsif MCU = "atmega328p" then
     MCU.PCMSK0_Bits (MCU.PCINT0_Bit);
#end if;

begin

   MCU.DDRB_Bits := (others => DD_Output); -- use all pins on PortB for output
   MCU.PORTB := 16#FF#;                    -- and turn off all LEDs

   MCU.DDRD_Bits := (others => DD_Input);  -- use all pins on port D for input
   MCU.PORTD := 16#FF#;                    -- activate internal pull-up

   Enable_Ext_Int0 := True;                -- enable external int0
   MCU.MCUCR_Bits (MCU.ISC01_Bit) := True; -- falling egde: int0

   AVR.Interrupts.Enable;                  -- enable interrupts

   loop null; end loop;                    -- loop for ever
end Extern_Int_Main;
