-- ----------------------------------------------------------------------------
--  "THE BEER-WARE LICENSE" (Revision 42):
--  <joerg@FreeBSD.ORG> wrote this file.  As long as you retain this notice you
--  can do whatever you want with this stuff. If we meet some day, and you
--  think this stuff is worth it, you can buy me a beer in return. Joerg Wunsch
-------------------------------------------------------------------------------
--
--  modified and translated to AVR-Ada by Bernd Trog
--
--    Simple AVR demonstration.  Controls a LED that can be directly
--    connected from OC1/OC1A to GND.  The brightness of the LED is
--    controlled with the PWM.  After each period of the PWM, the PWM
--    value is either incremented or decremented, that's all.


with Interfaces;                   use type Interfaces.Unsigned_8;
with AVR;                          use AVR;
with AVR.Interrupts;
with AVR.MCU;


package body Demo_Ada is

   OCR    : Nat16 renames MCU.OCR1A;
   -- OC1_Bit    : constant Bit_Number := MCU.PORTB3;
   OC1    : Boolean renames MCU.PORTB_Bits (3);
   DDROC  : Nat8 renames MCU.DDRB;
   XCOM11 : constant := MCU.COM1A1_Mask;

   type Direction_Type is (Up, Down);

   --  "volatile" makes sure that the content is stored in SRAM - not in
   --  a register(its not realy necessary in this program)
   pragma Volatile (Direction_Type);


   type PWM_10Bit is mod 2 ** 10; -- 0 .. 1023
   pragma Volatile (PWM_10Bit);

   --  The PWM is being used in 10-bit mode, so we need a
   --  10-bit variable to remember the current value.
   PWM : PWM_10Bit;
   Direction : Direction_Type;

   procedure Timer_Enable_Int (Ints : Nat8);
   procedure IOinit;
   procedure Overflow_1_Interrupt;

   --  "signal" marks the procedure as an interrupt routine
   --  without a "sei" instruction in the prologue

   pragma Machine_Attribute (Entity         => Overflow_1_Interrupt,
                             Attribute_Name => "signal");

   --  Now export the procedure under the name "__vector_N"
   --  see avr-<MCU> for details

   pragma Export (Convention    => C,
                  Entity        => Overflow_1_Interrupt,
                  External_Name => MCU.Sig_TIMER1_OVF1_String);

   --  The interrupt procedure
   procedure Overflow_1_Interrupt
   is
   begin
      --  this section determines the new value of the PWM.
      case Direction is
         when Up =>
            PWM := PWM + 1;
            if PWM = PWM_10Bit'Last then  -- PWM_10Bit'Last = 1023
               Direction := Down;
            end if;

         when Down =>
            PWM := PWM - 1;
            if PWM = PWM_10Bit'First then -- PWM_10Bit'First = 0
               Direction := Up;
            end if;
      end case;

      --  Here's where the newly computed value is loaded into the PWM
      --  register.  Since we are in an interrupt routine, it is safe
      --  to use a 16-bit assignment to the register.  Outside of an
      --  interrupt, the assignment should only be performed with
      --  interrupts disabled if there's a chance that an interrupt
      --  routine could also access this register (or another register
      --  that uses TEMP)

      OCR := Nat16 (PWM);

   end Overflow_1_Interrupt;


   procedure Timer_Enable_Int (Ints : Nat8)
   is
   begin
      MCU.TIMSK := Ints;
   end Timer_Enable_Int;
   pragma Inline_Always (Timer_Enable_Int);


   --  This routine gets called after a reset. It initializes the PWM
   --  and Enables interrupts.
   procedure IOinit
   is
   begin
      --  tmr1 is 10-bit PWM
      MCU.TCCR1A := MCU.PWM10_Mask or MCU.PWM11_Mask or XCOM11;

      --  tmr1 running on full MCU clock
      MCU.TCCR1B := MCU.CS10_Mask;

      --  set PWM value to 0
      OCR := Nat16'(0);

      --  enable OC1 and PB2 as output
      DDROC := OC1;

      Timer_Enable_Int (MCU.TOIE1);

      --  enable interrupts
      AVR.Interrupts.Enable_Interrupts;
   end ioinit;


   procedure Main
   is
   begin
      IOinit;

      loop
         null;
         --  The main loop of the program does nothing.
         --  all the work is done by the interrupt routine!
         --  If this was a real product, we'd probably put a SLEEP instruction
         --  in this loop to conserve power.
      end loop;
   end Main;

end Demo_Ada;
