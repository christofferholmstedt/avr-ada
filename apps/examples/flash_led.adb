---------------------------------------------------------------------------
-- The AVR-Ada Library is free software;  you can redistribute it and/or --
-- modify it under terms of the  GNU General Public License as published --
-- by  the  Free Software  Foundation;  either  version 2, or  (at  your --
-- option) any later version.  The AVR-Ada Library is distributed in the --
-- hope that it will be useful, but  WITHOUT ANY WARRANTY;  without even --
-- the  implied warranty of MERCHANTABILITY or FITNESS FOR A  PARTICULAR --
-- PURPOSE. See the GNU General Public License for more details.         --
---------------------------------------------------------------------------



--   Title:    Timer/Counter Output Compare Mode: Pin OC0 toggles

--   Author:   Rolf Ebert based on Peter Fleury's idea <pfleury@gmx.ch>

--   Description:
--   Timer0 support the possibility to react on timer interrupt events
--   on a purely hardware basis without the need to execute
--   code. Related output pins can be configured to be set, cleared or
--   toggled automatically on a compare match.

--   This examples shows how to toggle an output pin and flashing a
--   LED.  After initialization, the LED flashes on OC0 output pin
--   without code execution.

--   A LED with a series resistor should be connected from OC0 pin to
--   GND.

--   See also Atmel AVR Application Note AVR130


with AVR;                          use AVR;
with AVR.MCU;
with AVR.Timer0;

procedure Flash_Led is
begin
   --
   --  Initialisation
   --
   --  Attiny13 fuse bit is set to 4.8MHz
   --     MCU.CLKPR := MCU.CLKPCE_Mask;
   --     MCU.CLKPR := 4;  -- clock scaling = 2^CLKPR

   --     --  set the calibration byte
   --     MCU.OSCCAL := 16#65#;


   -- set OC0 pin as output, required for output toggling
   MCU.DDRB_Bits := (others => DD_Output);
   -- set all pins to high to switch off the leds.
   MCU.PortB := 16#FF#;


   --
   --  initialize timer to Clear Timer on Compare, scale the input
   --  clock and set a value to compare the timer against.
   --
   Timer0.Init_CTC (Timer0.Scale_By_1024, Overflow => 250);

   --  Toggle the OC0(A)-Pin on compare match
   Timer0.Set_Output_Compare_Mode_Toggle;

   --
   -- Initialisation done, LED will now flash without executing any code !
   --
   loop   -- loop forever
      null;
   end loop;
end Flash_Led;
