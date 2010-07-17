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

--  Make the LED blink using relative delays (i.e. delay <duration>).

with AVR;                          use AVR;
with AVR.MCU;

procedure Blink_Rel is

   JTD      : Boolean renames MCU.MCUCR_Bits (MCU.JTD_Bit);

   LED1_Pin : constant AVR.Bit_Number := 6;
   LED2_Pin : constant AVR.Bit_Number := 4;
   LED1_DD  : Boolean renames AVR.MCU.DDRB_Bits (LED1_Pin);
   LED2_DD  : Boolean renames AVR.MCU.DDRB_Bits (LED2_Pin);
   LED1     : Boolean renames AVR.MCU.PortB_Bits (LED1_Pin);
   LED2     : Boolean renames AVR.MCU.PortB_Bits (LED2_Pin);

   Cycle : constant := 1.0;

   procedure Wait_Long is
   begin
      delay Cycle;
   end Wait_Long;

   procedure LED_Off;
   pragma Inline (LED_Off);

   procedure LED_On;
   pragma Inline (LED_On);

   procedure LED_Off is
   begin
      LED1 := Low;
      LED2 := High;
   end LED_Off;

   procedure LED_On is
   begin
      LED1 := High;
      LED2 := Low;
   end LED_On;

begin
   --  disable JTAG on Butterfly for enabling access to port F
   -- JTD := True;
   -- MCU.MCUCR := MCU.JTD_Mask;

   --  configure LED as output
   LED1_DD := DD_Output;
   LED2_DD := DD_Output;

   loop
      LED_Off;
      Wait_Long;
      LED_On;
      Wait_Long;
   end loop;

end Blink_Rel;
