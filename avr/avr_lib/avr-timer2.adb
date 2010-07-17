with Interfaces;                   use Interfaces;
with AVR;                          use AVR;
with AVR.MCU;

package body AVR.Timer2 is


   -- Overflow_Count : Unsigned_16;
   -- pragma Volatile (Overflow_Count);

#if MCU = "atmega168" or else MCU = "atmega169" then
   Output_Compare_Reg : Unsigned_8 renames MCU.OCR2A;
#elsif mcu = "atmega32" then
   Output_Compare_Reg : Unsigned_8 renames MCU.OCR2;
#end if;


#if MCU = "attiny13" or else MCU = "atmega168" or else MCU = "atmega169" then
   Ctrl_Reg       : Bits_In_Byte renames MCU.TCCR2A_Bits;
#elsif MCU = "atmega32" then
   Ctrl_Reg       : Bits_In_Byte renames MCU.TCCR2_Bits;
#end if;


#if MCU = "atmega168" then
   Prescale_Reg   : Unsigned_8 renames MCU.TCCR2B;
#elsif MCU = "atmega169" then
   Prescale_Reg   : Unsigned_8 renames MCU.TCCR2A;
#elsif MCU = "atmega32" then
   Prescale_Reg   : Unsigned_8 renames MCU.TCCR2;
#end if;

#if MCU = "atmega168" or else MCU = "atmega169" then
   Interrupt_Mask : Bits_In_Byte renames MCU.TIMSK2_Bits;
   Output_Compare_Interrupt_Enable : Boolean renames MCU.TIMSK2_Bits (MCU.OCIE2A_Bit);
   Overflow_Interrupt_Enable       : Boolean renames MCU.TIMSK2_Bits (MCU.TOIE2_Bit);
#elsif MCU = "atmega32" then
   Interrupt_Mask : Bits_In_Byte renames MCU.TIMSK_Bits;
   Output_Compare_Interrupt_Enable : Boolean renames MCU.TIMSK_Bits (MCU.OCIE2_Bit);
#end if;


   function No_Clock_Source return Scale_Type is
   begin
      return 0;
   end No_Clock_Source;

   function No_Prescaling   return Scale_Type is
   begin
      return MCU.CS20_Mask;
   end No_Prescaling;

   function Scale_By_8      return Scale_Type is
   begin
      return MCU.CS21_Mask;
   end Scale_By_8;

   function Scale_By_32     return Scale_Type is
   begin
      return MCU.CS21_Mask or MCU.CS20_Mask;
   end Scale_By_32;

   function Scale_By_64     return Scale_Type is
   begin
      return MCU.CS22_Mask;
   end Scale_By_64;

   function Scale_By_128    return Scale_Type is
   begin
      return MCU.CS22_Mask or MCU.CS20_Mask;
   end Scale_By_128;

   function Scale_By_256    return Scale_Type is
   begin
      return MCU.CS22_Mask or MCU.CS21_Mask;
   end Scale_By_256;

   function Scale_By_1024   return Scale_Type is
   begin
      return MCU.CS22_Mask or MCU.CS21_Mask or MCU.CS20_Mask;
   end Scale_By_1024;


   procedure Init_CTC (Prescaler : Scale_Type; Overflow : Unsigned_8 := 0)
   is
   begin
      --  set the control register with the prescaler and mode flags to
      --  timer output compare mode and clear timer on compare match
#if MCU = "attiny13" or else MCU = "atmega168" or else MCU = "atmega169" then
      Ctrl_Reg := (MCU.COM2A0_Bit => False, --  \  normal operation,
                   MCU.COM2A1_Bit => False, --  /  OC0 disconnected

                   MCU.WGM20_Bit => False,  --  \  Clear Timer on Compare
                   MCU.WGM21_Bit => True,   --  /  Match (CTC)

                   others    => False);
#elsif MCU = "atmega32" then
      Ctrl_Reg := (MCU.COM20_Bit => False, --  \  normal operation,
                   MCU.COM21_Bit => False, --  /  OC0 disconnected

                   MCU.WGM20_Bit => False,  --  \  Clear Timer on Compare
                   MCU.WGM21_Bit => True,   --  /  Match (CTC)

                   others    => False);
#end if;

      --  select the clock
      Prescale_Reg := Prescale_Reg or Prescaler;

      --  enable Timer2 output compare interrupt
      Output_Compare_Interrupt_Enable := True;

      Output_Compare_Reg := Overflow;

      --  clear interrupt-flags of timer/counter0
      -- MCU.TIFR2 := 16#FF#;

      --  reset all counters
      -- Clear_Overflow_Count;
      MCU.TCNT2 := 0;

   end Init_CTC;


   procedure Init_Normal (Prescaler : Scale_Type)
   is
   begin
      --  set the control register with the prescaler and mode flags to
      --  timer output compare mode and clear timer on compare match
#if MCU = "atmega168" or else MCU = "atmega169" then
      Ctrl_Reg := (MCU.COM2A0_Bit => False, --  \  normal operation,
                   MCU.COM2A1_Bit => False, --  /  OC0 disconnected

                   MCU.WGM20_Bit => False,  --  \  Normal
                   MCU.WGM21_Bit => False,  --  /  

                   others    => False);
#elsif MCU = "atmega32" then
      Ctrl_Reg := (MCU.COM20_Bit => False, --  \  normal operation,
                   MCU.COM21_Bit => False, --  /  OC0 disconnected

                   MCU.WGM20_Bit => False,  --  \  
                   MCU.WGM21_Bit => False,  --  /  normal mode

                   others    => False);
#end if;

      --  select the clock
      Prescale_Reg := Prescale_Reg or Prescaler;

      --  enable Timer2 overflow interrupt
      Overflow_Interrupt_Enable := True;

      --  clear interrupt-flags of timer/counter0
      -- MCU.TIFR2 := 16#FF#;

      --  reset all counters
      -- Clear_Overflow_Count;
      MCU.TCNT2 := 0;

   end Init_Normal;
   
   
   procedure Stop is
   begin
      -- Stop the timer and disable all timer interrupts
      Prescale_Reg := No_Clock_Source;
      Interrupt_Mask := (others => Low);
   end Stop;


   procedure Enable_Interrupt_Compare is
   begin
      Output_Compare_Interrupt_Enable := True;
   end Enable_Interrupt_Compare;


   procedure Enable_Interrupt_Overflow is
   begin
      Output_Compare_Interrupt_Enable := True;
   end Enable_Interrupt_Overflow;


   procedure Set_Overflow_At (Overflow : Unsigned_8) is
   begin
      Output_Compare_Reg := Overflow;
   end Set_Overflow_At;


end AVR.Timer2;

