with Blink_TE_Pkg;                 use Blink_TE_Pkg;
with AVR.Real_Time.Timing_Events;  use AVR.Real_Time.Timing_Events;
with AVR.Real_Time.Timing_Events.Process;

procedure Blink_Timing_Events is

   E : aliased Timing_Event;

begin
   Init;

   Set_Handler (E'Access, 1.0, Toggle_LED_Handler'Access);

   loop
      AVR.Real_Time.Timing_Events.Process;
   end loop;
end Blink_Timing_Events;


