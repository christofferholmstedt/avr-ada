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


with Interfaces;                   use Interfaces;
with AVR.MCU;

package AVR.Timer1 is
   pragma Preelaborate;

   --
   --  Different scaling factors for timer clock input.
   --
   --  Verify in the data sheet that the scaling factor is available
   --  at all for your mcu.
   --
   subtype Scale_Type is Unsigned_8;
   function No_Clock_Source return Scale_Type;
   function No_Prescaling   return Scale_Type;
   function Scale_By_8      return Scale_Type;
   function Scale_By_64     return Scale_Type;
   function Scale_By_256    return Scale_Type;
   function Scale_By_1024   return Scale_Type;

   type PWM_Type is private;
   Fast_PWM_8bit              : constant PWM_Type; --  top = 00FF
   Fast_PWM_9bit              : constant PWM_Type; --  top = 01FF
   Fast_PWM_10bit             : constant PWM_Type; --  top = 03FF
   --  Fast_PWM_ICR               : constant PWM_Type; --  top = MCU.ICR1
   --  Fast_PWM_OCR               : constant PWM_Type; --  top = MCU.OCR1A
   Phase_Correct_PWM_8Bit     : constant PWM_Type; --  top = 00FF
   --  Phase_Correct_PWM_9Bit     : constant PWM_Type; --  top = 01FF
   --  Phase_Correct_PWM_10Bit    : constant PWM_Type; --  top = 03FF
   --  Phase_Correct_PWM_ICR      : constant PWM_Type; --  top = MCU.ICR1
   --  Phase_Correct_PWM_OCR      : constant PWM_Type; --  top = MCU.OCR1A
   --  Phase_Freq_Correct_PWM_ICR : constant PWM_Type; --  top = MCU.ICR1
   --  Phase_Freq_Correct_PWM_OCR : constant PWM_Type; --  top = MCU.OCR1A


   --  normal mode
   procedure Init_Normal (Prescaler : Scale_Type);
   --  clear timer on compare match
   procedure Init_CTC (Prescaler : Scale_Type; Overflow : Unsigned_16 := 0);
   procedure Set_Overflow_At (Overflow : Unsigned_16);
   --  PWM modes
   procedure Init_PWM (Prescaler      : Scale_Type;
                       PWM_Resolution : PWM_Type;
                       Inverted       : Boolean := False);

   procedure Set_Output_Compare_Mode_Normal;
   procedure Set_Output_Compare_Mode_Toggle;
   procedure Set_Output_Compare_Mode_Clear;
   procedure Set_Output_Compare_Mode_Set;
   procedure Set_Output_Compare_Mode_B_Normal;
   procedure Set_Output_Compare_Mode_B_Toggle;
   procedure Set_Output_Compare_Mode_B_Clear;
   procedure Set_Output_Compare_Mode_B_Set;

   --  stop the timer,
   --  set prescaler to No_Clock_Source, disable timer interrupts
   procedure Stop;

   procedure Enable_Interrupt_Compare;
   procedure Enable_Interrupt_Overflow;


   Signal_Compare  : constant String := MCU.Sig_Timer1_CompA_String;
   Signal_Overflow : constant String := MCU.Sig_Timer1_OVF_String;


private

   type PWM_Type is array (0..3) of Boolean;
   -- pragma Pack (PWM_Type);
   -- for PWM_Type'Size use 8;
   Fast_PWM_8bit              : constant PWM_Type := (0 => True,  1 => False, 2 => True,  3 => False); --  top = 00FF
   Fast_PWM_9bit              : constant PWM_Type := (0 => False, 1 => True,  2 => True,  3 => False); --  top = 01FF
   Fast_PWM_10bit             : constant PWM_Type := (0 => True,  1 => True,  2 => True,  3 => False); --  top = 03FF
   --  Fast_PWM_ICR               : constant PWM_Type := 14; --  TOP = MCU.ICR1
   --  Fast_PWM_OCR               : constant PWM_Type := 15; --  TOP = MCU.OCR1A
   Phase_Correct_PWM_8Bit     : constant PWM_Type := (0 => True,  1 => False, 2 => False, 3 => False); --  top = 00FF
   --  Phase_Correct_PWM_9Bit     : constant PWM_Type :=  2; --  TOP = 01FF
   --  Phase_Correct_PWM_10Bit    : constant PWM_Type :=  3; --  TOP = 03FF
   --  Phase_Correct_PWM_ICR      : constant PWM_Type := 10; --  TOP = MCU.ICR1
   --  Phase_Correct_PWM_OCR      : constant PWM_Type := 11; --  TOP = MCU.OCR1A
   --  Phase_Freq_Correct_PWM_ICR : constant PWM_Type :=  8; --  TOP = MCU.ICR1
   --  Phase_Freq_Correct_PWM_OCR : constant PWM_Type :=  9; --  TOP = MCU.OCR1A


   pragma Inline (No_Clock_Source);
   pragma Inline (No_Prescaling);
   pragma Inline (Scale_By_8);
   pragma Inline (Scale_By_64);
   pragma Inline (Scale_By_256);
   pragma Inline (Scale_By_1024);
   pragma Inline (Stop);
   pragma Inline (Set_Overflow_At);

end AVR.Timer1;
