---------------------------------------------------------------------------
-- The AVR-Ada Library is free software;  you can redistribute it and/or --
-- modify it under terms of the  GNU General Public License as published --
-- by  the  Free Software  Foundation;  either  version 2, or  (at  your --
-- option) any later version.  The AVR-Ada Library is distributed in the --
-- hope that it will be useful, but  WITHOUT ANY WARRANTY;  without even --
-- the  implied warranty of MERCHANTABILITY or FITNESS FOR A  PARTICULAR --
-- PURPOSE. See the GNU General Public License for more details.         --
--                                                                       --
-- As a special exception, if other files instantiate generics from this --
-- unit,  or  you  link  this  unit  with  other  files  to  produce  an --
-- executable   this  unit  does  not  by  itself  cause  the  resulting --
-- executable to  be  covered by the  GNU General  Public License.  This --
-- exception does  not  however  invalidate  any  other reasons why  the --
-- executable file might be covered by the GNU Public License.           --
---------------------------------------------------------------------------

with AVR;                          use AVR;
with AVR.MCU;
with AVR.Real_Time;                use AVR.Real_Time; -- make "+" visible
with AVR.Real_Time.Clock;

procedure Blink_Abs is

   LED_Port : Bits_In_Byte renames AVR.MCU.PORTB_Bits;
   LED_Pin  : constant AVR.Bit_Number := 2;
   LED_DD   : Bits_In_Byte renames AVR.MCU.DDRB_Bits;

   Next      : AVR.Real_Time.Time;
   Off_Cycle : constant := 1.0;
   On_Cycle  : constant := 1.0;

   procedure LED_Off;
   pragma Inline (LED_Off);

   procedure LED_On;
   pragma Inline (LED_On);

   procedure LED_Off is
   begin
      LED_Port (LED_Pin) := True;
   end LED_Off;

   procedure LED_On is
   begin
      LED_Port (LED_Pin) := False;
   end LED_On;

begin
   --  configure LED as output
   LED_DD (LED_Pin) := DD_Output;

   loop
      Next := Real_Time.Clock + Off_Cycle;

      LED_Off;
      delay until Next;
      Next := Real_Time.Clock + On_Cycle;

      LED_On;
      delay until Next;
   end loop;

end Blink_Abs;


