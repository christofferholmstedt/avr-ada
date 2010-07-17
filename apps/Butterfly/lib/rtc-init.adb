with AVR.IO;                       use AVR.IO;
with AVR.Interrupts;
with AVR.MCU;                      use AVR.MCU;


separate (RTC)
procedure Init is
begin
   --  wait for 1 sec to let the Xtal stabilize after a power-on,
   --  delay (1000);

   --  disabel global interrupt
   AVR.Interrupts.Disable_Interrupts;

   --  disable OCIE2A and TOIE2
   Set_Bit (TIMSK2, TOIE2_Bit, False);

   --  select asynchronous operation of Timer2
   Set (ASSR, AS2);

   --  clear TCNT2A
   Set (TCNT2, 0);

   --  select precaler: 32.768 kHz / 128 = 1 sec between each overflow
   --  Set (TCCR2A, Get (TCCR2A) or CS22 or CS20);
   declare
      use AVR;
      No_Clock_Source : constant Byte := 0;
      No_Prescaling   : constant Byte := CS20;
      Scale_By_8      : constant Byte := CS21;
      Scale_By_32     : constant Byte := CS21 or CS20;
      Scale_By_64     : constant Byte := CS22;
      Scale_By_128    : constant Byte := CS22 or CS20;
      Scale_By_256    : constant Byte := CS22 or CS21;
      Scale_By_1024   : constant Byte := CS22 or CS21 or CS20;
   begin
      Set (TCCR2A, Get (TCCR2A) or No_Prescaling);
   end;

   --  alternatively prescale by 32 and generate compare interrupt
   --  at 125.  that triggers an interrupt at 32 * 125 = 4000 =
   --  every 0.25ms.


   --  wait for 'Timer/Counter Control Register2 Update Busy' and
   --  'Timer/Counter2 Update Busy' to be cleared
   while (Get (ASSR) and (TCN2UB or TCR2UB)) /= 0 loop
      null;
   end loop;

   --  clear interrupt-flags of timer/counter2
   Set (TIFR2, 16#FF#);

   --  enable Timer2 overflow interrupt
   Set_Bit (TIMSK2, TOIE2_Bit, True);

   --  enable global interrupt
   AVR.Interrupts.Enable_Interrupts;
end Init;

