with AVR;                          use AVR;
with AVR.MCU;
with AVR.Real_Time;                use AVR.Real_Time;
with AVR.Real_Time.Clock;

procedure Blink_Clock is
   
   Cycle : constant Time_Span := 0.5;
   Next  : Time := Clock + Cycle;

   LED : Boolean renames MCU.PortB_Bits (3);
   LED_DD : Boolean renames MCU.DDRB_Bits (3);

   function Off return Boolean renames True;

begin

   LED_DD := DD_Output;
   LED    := Off;

   loop
      if Clock > Next then
         LED := not LED;
         Next := Next + Cycle;
      end if;
   end loop;

end Blink_Clock;
