with AVR.MCU;
with AVR.Real_Time.Timing_Events;  use AVR.Real_Time.Timing_Events;

package Blink_TE_Pkg is

   LED_DD : Boolean renames AVR.MCU.DDRB_Bits(0);
   LED    : Boolean renames AVR.MCU.PortB_Bits(0);

   procedure Init;
   pragma Inline (Init);

   procedure Toggle_LED_Handler (E : access Timing_Event);

end Blink_TE_Pkg;


