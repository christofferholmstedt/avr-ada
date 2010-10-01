--   Title:    AVR Starter Kit testprogram
--   Author:   Peter Fleury  pfleury@gmx.ch http://jump.to/fleury
--   Date:     December 2002
--   Purpose:  testprogram for a STK200 compatible starter kit

--   Program description
--   Turns on one LED on port B which walks from bit 0 to bit 7 in
--   intervals of 1 sec If one of the keys is pressed, the
--   corresponding LED is turned on.


with Interfaces;                   use Interfaces;
with AVR;                          use AVR;
with AVR.MCU;
with AVR.Interrupts;

package body Test_Starterkit is

   -- constant definitions
   Timer_1_Cnt : constant := 16#F0BE#;
   -- 1 sec, use AVRcalc to calculate these values
   -- ((TCNT1H=0xf0, TCNT1L=0xbe)

   -- this constants should be in <avr/io8515.h> !!
   TMC16_CK1024 : constant Nat8 := MCU.CS12_Mask or MCU.CS10_Mask;

   --  module global variables
   LED : Nat8 := 0;
   pragma Volatile (LED);
   --  use volatile when variable is accessed from interrupts and in
   --  the main program


   procedure Timer;
   pragma Machine_Attribute (Entity         => Timer,
                             Attribute_Name => "signal");
   pragma Export (C, Timer, MCU.Sig_TIMER1_COMPA_String);

   -- signal handler for tcnt1 overflow interrupt
   procedure Timer is
   begin
      -- invert the output since a zero means: LED on
      MCU.PORTB := not LED;

      -- overflow: start with bit 0 again
      if LED = 16#80# then
         LED := 1;
      else
         -- move to next LED
         LED := Shift_Left (LED, 1);
      end if;

      -- reset counter to get this interrupt again
      MCU.TCNT1 := Timer_1_Cnt;
   end Timer;


   procedure Main is

      Keys : Nat8;

   begin

      -- use all pins on PortB for output
      MCU.DDRB_Bits := (others => DD_Output);
      -- and turn off all LEDs
      MCU.PORTB := 16#FF#;


      -- use all pins on port D for input
      MCU.DDRD_Bits := (others => DD_Input);
      -- activate internal pull-up
      MCU.PORTD := 16#FF#;

      -- disable PWM and Compare Output Mode
      MCU.TCCR1A := 0;

      -- use CLK/1024 prescale value
      MCU.TCCR1B := TMC16_CK1024;
      -- reset TCNT1
      MCU.TCNT1 := Timer_1_Cnt;

      -- enable TCNT1 overflow
      MCU.TIMSK1 := MCU.TOIE1_Mask;

      -- init variable representing the LED state
      LED := 1;

      -- enable interrupts
      AVR.Interrupts.Enable;

      loop    -- loop forever
         Keys := not MCU.PIND;  -- read input port with keys (active-low)

         if (Keys and 1) /= 0 then
            LED := 1;
         elsif (Keys and 2) /= 0 then  -- priority encoder: if multiple keys
            LED := 2;                  -- are pressed, only the lowest key is
         elsif (Keys and 4) /= 0 then  -- recognized.
            LED := 4;
         elsif (Keys and 8) /= 0 then
            LED := 8;
         elsif (Keys and 16#10#) /= 0 then
            LED := 16#10#;
         elsif (Keys and 16#20#) /= 0 then
            LED := 16#20#;
         elsif (Keys and 16#40#) /= 0 then
            LED := 16#40#;
         elsif (Keys and 16#80#) /= 0 then
            LED := 16#80#;
         end if;

         if Keys /= 0 then
            MCU.PORTB := not LED;    -- Set corresponding LED if key pressed
         end if;
      end loop;
   end Main;

end Test_Starterkit;
