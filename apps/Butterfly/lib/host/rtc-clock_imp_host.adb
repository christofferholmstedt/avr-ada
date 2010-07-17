with RTC.Set_Clock;
with Ada.Calendar;

separate (RTC)
package body Clock_Imp is

   use Ada.Calendar;

   D : constant Duration := 1.0;

   Next : Ada.Calendar.Time := Ada.Calendar.Clock + D;


   task type Tick;

   task body Tick is
   begin
      loop
         delay until Next;
         RTC.Set_Clock.Inc_Sec;
         Next := Next + 1.0;
      end loop;
   end Tick;
   type Tick_Acc is access Tick;

   procedure Init is
      T : Tick_Acc;
   begin
      T := new Tick;
   end Init;

end Clock_Imp;

