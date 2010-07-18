with Interfaces;                   use Interfaces;
with AVR.MCU;

package AVR.Timer2 is
   pragma Preelaborate;

   --     type Mode_Type is (Normal,              --  normal
   --                        CTC,                 --  clear timer on compare
   --                        Fast_PWM,            --  fast pulse width modulation
   --                        Phase_Correct_PWM);  --  phase correct PWM


   subtype Scale_Type is Unsigned_8;
   function No_Clock_Source return Scale_Type;
   function No_Prescaling   return Scale_Type;
   function Scale_By_8      return Scale_Type;
   function Scale_By_32     return Scale_Type;
   function Scale_By_64     return Scale_Type;
   function Scale_By_128    return Scale_Type;
   function Scale_By_256    return Scale_Type;
   function Scale_By_1024   return Scale_Type;

   procedure Init_Normal (Prescaler : Scale_Type);
   procedure Init_CTC (Prescaler : Scale_Type; Overflow : Unsigned_8 := 0);
   procedure Stop;  --  set prescaler to No_Clock_Source, disable timer interrupts
   procedure Enable_Interrupt_Compare;
   procedure Enable_Interrupt_Overflow;
   procedure Set_Overflow_At (Overflow : Unsigned_8);

#if MCU = "atmega168" then
   Signal_Compare  : constant String := MCU.Sig_Timer2_CompA_String;
#elsif MCU = "atmega169" or else MCU = "atmega32" then
   Signal_Compare  : constant String := MCU.Sig_Timer2_Comp_String;
#end if;
   Signal_Overflow : constant String := MCU.Sig_Timer2_OVF_String;

private

   pragma Inline (No_Clock_Source);
   pragma Inline (No_Prescaling);
   pragma Inline (Scale_By_8);
   pragma Inline (Scale_By_32);
   pragma Inline (Scale_By_64);
   pragma Inline (Scale_By_128);
   pragma Inline (Scale_By_256);
   pragma Inline (Scale_By_1024);
   pragma Inline (Stop);
   pragma Inline (Set_Overflow_At);
   pragma Inline (Enable_Interrupt_Compare);
   pragma Inline (Enable_Interrupt_Overflow);

end AVR.Timer2;

