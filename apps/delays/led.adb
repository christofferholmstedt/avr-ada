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

package body LED is

   --  there is a LED on the Arduino platform at Port B, pin 5 (digital pin 13)
   LED1    : Boolean renames AVR.MCU.PORTB_Bits (5);
   LED1_DD : Boolean renames AVR.MCU.DDRB_Bits (5);

   LED2    : Boolean renames AVR.MCU.PORTB_Bits (2);
   LED2_DD : Boolean renames AVR.MCU.DDRB_Bits (2);


   procedure Init is
      --  JTD : Boolean renames MCU.MCUCR_Bits (MCU.JTD_Bit);
   begin
      -- disable JTAG on Butterfly for enabling access to port F
      -- JTD := True;
      -- MCU.MCUCR := MCU.JTD_Mask;

      LED1_DD := DD_Output;
      LED2_DD := DD_Output;
   end Init;

   --  check your actual wiring. The STK500 connects the LEDs between
   --  the port pin and +5V. You switch them on by setting the pin to
   --  Low.  The Arduino 2009 has a LED between B5 and ground.  You
   --  have to set the pin high to switch on.
   procedure Off_1 is
   begin
      LED1 := Low;
   end Off_1;

   procedure Off_2 is
   begin
      LED2 := Low;
   end Off_2;

   procedure On_1 is
   begin
      LED1 := High;
   end On_1;

   procedure On_2 is
   begin
      LED2 := High;
   end On_2;

end LED;
