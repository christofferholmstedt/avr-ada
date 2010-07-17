with AVR.IO;                       use AVR.IO;
with AVR.Interrupts;
with AVR.MCU;                      use AVR.MCU;

with RTC.Set_Clock;

separate (RTC)
package body Clock_Imp is


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
      --  at 125.  That triggers an interrupt at 32 * 125 = 4000 =
      --  every 0.25ms. ???


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



   --
   --  set up the interrupt to count the ticks
   --

   procedure Overflow2;
   pragma Machine_Attribute (Entity         => Overflow2,
                             Attribute_Name => "signal");
   pragma Export (C, Overflow2, AVR.MCU.Sig_Timer2_OVF_String);


   type Count_7_Bits is mod 2 ** 7;
   Sec_By_128 : Count_7_Bits;
   --  no volatile necessary as it is only used in the interrupt routine

   procedure Overflow2 is
   begin
      Sec_By_128 := Sec_By_128 + 1;
      if Sec_By_128 = 0 then
         RTC.Set_Clock.Inc_Sec;
      end if;
   end Overflow2;
--   674:   80 91 51 01     lds     r24, 0x0151
--   678:   8f 5f           subi    r24, 0xFF       ; 255
--   67a:   8f 77           andi    r24, 0x7F       ; 127
--   67c:   80 93 51 01     sts     0x0151, r24
--   680:   88 23           and     r24, r24
--   682:   11 f4           brne    .+4             ; 0x688 <__vector_5+0x36>
--   684:   0e 94 a6 02     call    0x54c <rtc__set_clock__inc_sec>

end Clock_Imp;

