with Interfaces;                   use Interfaces;
with AVR;                          use AVR;
with AVR.Interrupts;
with AVR.MCU;                      use AVR.MCU;

with LCD_Driver_Direct;

package body Button is

   --  wireing

   Pin_B_Mask : constant Nat8 := 2**4 or 2**6 or 2**7;
   Pin_E_Mask : constant Nat8 := 2**2 or 2**3;


   BUTTON_A : constant :=  2**6;   -- UP
   BUTTON_B : constant :=  2**7;   -- DOWN
   BUTTON_C : constant :=  2**2;   -- LEFT
   BUTTON_D : constant :=  2**3;   -- RIGHT
   BUTTON_O : constant :=  2**4;   -- Enter


   procedure Pin_Change_Interrupt;


   Key : Button_Direction := Nil;
   pragma Volatile (Key);

   Key_Valid : Boolean := False;
   pragma Volatile (Key_Valid);


   procedure Sig_Pin_Change0;
   pragma Machine_Attribute (Entity         => Sig_Pin_Change0,
                             Attribute_Name => "signal");
   pragma Export (C, Sig_Pin_Change0, Sig_PCINT0_String);

   procedure Sig_Pin_Change0 is
   begin
      Pin_Change_Interrupt;
   end Sig_Pin_Change0;


   procedure Sig_Pin_Change1;
   pragma Machine_Attribute (Entity         => Sig_Pin_Change1,
                             Attribute_Name => "signal");
   pragma Export (C, Sig_Pin_Change1, Sig_PCINT1_String);

   procedure Sig_Pin_Change1 is
   begin
      Pin_Change_Interrupt;
   end Sig_Pin_Change1;


   --  Check status on the joystick
   procedure Pin_Change_Interrupt is
      Buttons : Nat8;
      K : Button_Direction;
   begin

      --      Read the buttons:
      --
      --      Bit             7   6   5   4   3   2   1   0
      --      ---------------------------------------------
      --      PORTB           B   A       O
      --      PORTE                           D   C
      --      ---------------------------------------------
      --      PORTB | PORTE   B   A       O   D   C
      --      =============================================

      Buttons := (not PINB) and Pin_B_Mask;
      Buttons := Buttons or ((not PINE) and Pin_E_Mask);


      -- Output virtual keys
      if (Buttons and BUTTON_A) /= 0 then
         K := Up;
      elsif (Buttons and BUTTON_B) /= 0 then
         K := Down;
      elsif (Buttons and BUTTON_C) /= 0 then
         K := Left;
      elsif (Buttons and BUTTON_D) /= 0 then
         K := Right;
      elsif (Buttons and BUTTON_O) /= 0 then
         K := Enter;
      else
         K := Nil;
      end if;


      if K /= Nil then
         if not KEY_VALID then
            KEY := K;          -- Store key in global key buffer
            KEY_VALID := TRUE;
         end if;
      end if;

      -- Delete pin change interrupt flags
      EIFR := PCIF1_Mask or PCIF0_Mask;

      -- Reset the Auto Power Down timer
      -- Power_Save_Timer := 0;

   end Pin_Change_Interrupt;


   --  Initialize the five button pin
   procedure Init is
   begin
      -- Init port pins for input and internal pull-up resistors
      DDRB  := DDRB and (not Pin_B_Mask);
      PORTB := PORTB or Pin_B_Mask;
      DDRE  := DDRE and (not Pin_E_Mask);
      PORTE := PORTE or Pin_E_Mask;

      --
      -- Enable pin change interrupt on PORTB (INT 1) and PORTE (INT 0)
      --

      --  The PCMSK1 and PCMSK0 Registers control which pins contribute
      --  to the pin change interrupts.
      PCMSK0 := Pin_E_Mask;
      PCMSK1 := Pin_B_Mask;

      --  External Interrupt Flag Register
      --  clear the flags by writing logical ones to them (p. 77).
      EIFR := PCIF0_Mask or PCIF1_Mask;
      --  External Interrupt Mask Register,
      --  enable pin change interrupts 0 and 1.
      EIMSK := PCIE0_Mask or PCIE1_Mask;
   end Init;


   function Get return Button_Direction is
      K : Button_Direction;
   begin
      Interrupts.Disable_Interrupts;

      if LCD_Driver_Direct.Debounce_Timeout then
         if Key_Valid then      -- Check for unread key in buffer
            K := Key;
            Key_Valid := False;
         else
            K := Nil;           -- No key stroke available
         end if;
         LCD_Driver_Direct.Debounce_Timeout := False;
      end if;

      Interrupts.Enable_Interrupts;

      return K;
   end Get;

end Button;
