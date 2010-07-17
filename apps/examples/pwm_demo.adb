---------------------------------------------------------------------------
-- The AVR-Ada Library is free software;  you can redistribute it and/or --
-- modify it under terms of the  GNU General Public License as published --
-- by  the  Free Software  Foundation;  either  version 2, or  (at  your --
-- option) any later version.  The AVR-Ada Library is distributed in the --
-- hope that it will be useful, but  WITHOUT ANY WARRANTY;  without even --
-- the  implied warranty of MERCHANTABILITY or FITNESS FOR A  PARTICULAR --
-- PURPOSE. See the GNU General Public License for more details.         --
---------------------------------------------------------------------------


--   Description:
--   This example shows how to generate voltages between VCC and GND using
--   Pulse Width Modulation (PWM).

--   A LED with a series resistor should be connected from PD5 to GND.

--   See also Atmel AVR Application Note AVR130


with Interfaces;                   use Interfaces;
with AVR;                          use AVR;
with AVR.MCU;
with AVR.Wait;

procedure PWM_Demo is

   --  at 4MHz waiting for 4 cycles is 1 micro-second
   procedure Wait_10ms;
   pragma Inline (Wait_10ms);

   procedure Wait_10ms is
   begin
      AVR.Wait.Wait_4_Cycles (10_000);
   end Wait_10ms;

   CTC1_Mask  : constant Nat8 := MCU.WGM12_Mask; -- on ATmega8
   PWM10_Mask : constant Nat8 := MCU.WGM10_Mask; -- on ATmega8

   OC1A_Pin  : constant Bit_Number := MCU.PORTD5_Bit;
   OC1A_DDR  : Bits_In_Byte renames MCU.DDRD_Bits;
   OC1A_Port : Bits_In_Byte renames MCU.PORTD_Bits;

begin
   MCU.DDRB_Bits := (others => DD_Output);  -- use all pins on PortB for output
   MCU.PORTB := 16#FF#;                 -- set output high -> turn all LEDs off


   OC1A_DDR (OC1A_Pin) := DD_Output; -- set pin5 as output
   OC1A_Port (OC1A_Pin) := False;    -- clear pin5

   -- enable 8 bit PWM, select inverted PWM
   MCU.TCCR1A := PWM10_Mask or MCU.COM1A1_Mask or MCU.COM1A0_Mask;

   --  timer1 running on 1/8 MCU clock with clear timer/counter1 on
   --  Compare Match -- PWM frequency will be MCU clock / 8 / 512,
   --  e.g. with 4Mhz Crystal 977 Hz.
   MCU.TCCR1B := MCU.CS11_Mask or CTC1_Mask;


   --
   --  Dimm LED on and off in interval of 2.5 seconds
   --

   loop
      -- dimm LED off
      for I in reverse Nat8 loop
         MCU.OCR1AL := I;
         Wait_10ms;
      end loop;

      -- dimm LED on
      for I in Nat8 loop
         MCU.OCR1AL := I;
         Wait_10ms;
      end loop;
   end loop;
end PWM_Demo;
