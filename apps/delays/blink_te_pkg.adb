with AVR;                          use AVR;
with AVR.MCU;
with AVR.Real_Time.Timing_Events;  use AVR.Real_Time.Timing_Events;

package body Blink_TE_Pkg is


   procedure Init is
   begin
      LED_DD := DD_Output;
      LED := True;
   end Init;


   procedure Toggle_LED_Handler (E : access Timing_Event)
   is
   begin
      LED := not LED;
      Set_Handler (E, 0.5, Toggle_LED_Handler'Access);
   end Toggle_LED_Handler;


end Blink_TE_Pkg;


