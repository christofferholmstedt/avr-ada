with Interfaces;                   use Interfaces;

package body AVR.Strings.Edit.Generic_Integers is


   function Get_Digit (C : Character) return Unsigned_8
   is
   begin
      if C in '0' .. '9' then
         return Character'Pos (C) - 48;
      elsif C in 'a' .. 'f' then
         return Character'Pos (C) - 87;
      elsif C in 'A' .. 'F' then
         return Character'Pos (C) - 55;
      else
         return 16;
      end if;
   end Get_Digit;



   -- Get -- Get an integer number from the Input_Line
   --
   --      Value   - The result
   --      Base    - The base of the expected number
   --      ToFirst - Force value to First instead of exception
   --      ToLast  - Force value to Last instead of exception
   --
   -- This procedure gets an integer number from the Input_Line. The
   -- process starts at Input_Line (Input_Ptr). The parameter Base
   -- indicates the base of the expected number.
   --
   procedure Get_I (Value   : out Number_T;
                    Base    : in Number_Base := 10)
   is
      Radix       : constant Number_T'Base := Number_T'Base(Base);
      Is_Negative : Boolean := False;
      Digit       : Nat8;
   begin
      if Input_Line(Input_Ptr) = '+' then
         Input_Ptr := Input_Ptr + 1;
      elsif Input_Line(Input_Ptr) = '-' then
         Is_Negative := True;
         Input_Ptr := Input_Ptr + 1;
      end if;

      Value := 0;
      while Input_Ptr <= Input_Last loop
         Digit := Get_Digit (Input_Line(Input_Ptr));
         exit when Digit > Nat8(Base);
         Value := Value * Radix;
         Value := Value + Number_T'Base(Digit);
         Input_Ptr := Input_Ptr + 1;
      end loop;
      if Is_Negative then
         Value := - Value;
      end if;
   end Get_I;


   procedure Get_U (Value   : out Number_T;
                    Base    : in Number_Base := 10)
   is
      Radix : constant Number_T'Base := Number_T'Base(Base);
      Digit : Nat8;
   begin
      if Input_Line(Input_Ptr) = '+' then
         Input_Ptr := Input_Ptr + 1;
      end if;

      Value := 0;
      while Input_Ptr <= Input_Last loop
         Digit := Get_Digit (Input_Line(Input_Ptr));
         exit when Digit > Nat8(Base);
         Value := Value * Radix;
         Value := Value + Number_T'Base(Digit);
         Input_Ptr := Input_Ptr + 1;
      end loop;
   end Get_U;


   --  # if MCU = "host" then
   --     procedure Put_U32 (Value       : in Unsigned_32;
   --                        Base        : in Number_Base := 10;
   --                        Target      : in out AStr11;
   --                        Last        : out Unsigned_8)
   --     is
   --        Temp : Unsigned_32 := Value;
   --        Nibble : Unsigned_32;
   --        Target_Str : String (1..11) := (others => '@');
   --        L : Natural;
   --     begin
   --        for I in reverse Target_Str'Range loop
   --           Nibble := Temp mod Unsigned_32(Base);
   --           Temp := Temp / Unsigned_32(Base);
   --           if Nibble > 9 then
   --              Target_Str (I) := Character'Val (Character'Pos ('A') + Nibble - 10);
   --           else
   --              Target_Str (I) := Character'Val (Character'Pos ('0') + Nibble);
   --           end if;
   --        end loop;

   --        for I in Target_Str'Range loop
   --           L := I;
   --           exit when Target_Str(I) /= '0';
   --        end loop;

   --        for I in L .. Target_Str'Last loop
   --           Target(Unsigned_8(I-L)+2) := Target_Str(I);
   --        end loop;
   --        Last := Unsigned_8(Target_Str'Last-L+2);
   --     end Put_U32;
   --  #else
   type Chars_Ptr is access all Character;

   function U32_Img (Val : Unsigned_32;
                     S   : Chars_Ptr;
                     Radix : Number_Base)
                    return All_Edit_Index_T;
   pragma Import (C, U32_Img, "ada_u32_img");
   --  pragma Linker_Options ("ada_u32_img.o");

   procedure Put_U32 (Value   : in Unsigned_32;
                      Base    : in Number_Base := 10;
                      Target  : in out AStr11;
                      Last    : out Unsigned_8)
   is
      Len : All_Edit_Index_T;
   begin
      Len := U32_Img (Value, Target(Target'First+1)'Unchecked_Access, Base);
      Last := Target'First + Len;
   end Put_U32;
   -- #end if;


   -- Put -- Put an integer into the Output_Line
   --
   --      Value       - The value to be put
   --      Base        - The base used for the output
   --      Field       - The output field
   --      Justify     - Alignment within the field
   --      Fill        - The fill character
   --
   -- This procedure places the number specified  by  the  parameter  Value
   -- into  the  Output_Line. The string is written starting
   -- from  Output_Line (Output_Ptr). The parameter Base indicates the number
   -- base used for the output. The base itself  does  not  appear  in  the
   -- output.
   --
   -- Example :
   --
   --      Put (5, 2, 10, Center, '@');
   --
   --      Now the Output_Line is "@@@+101@@@##########", Output_Ptr = 11
   --
   procedure Generic_Put_I (Value   : in Number_T;
                            Field   : in All_Edit_Index_T := 0;
                            Justify : in Alignment := Left;
                            Fill    : in Character := ' ')
   is
      Is_Negative : constant Boolean := (Value < 0);
      Pos_Value   : constant Number_T := abs(Value);
      Value_Img   : AStr11;
      Last        : Edit_Index_T;
   begin
      Put_U32 (Unsigned_32(Pos_Value), 10, Value_Img, Last);
      if Is_Negative then
         Value_Img(1) := '-';
         Put (Value_Img (1..Last), Field, Justify, Fill);
      else
         Put (Value_Img (2..Last), Field, Justify, Fill);
      end if;
   end Generic_Put_I;


   procedure Generic_Put_U (Value   : in Number_T;
                            Base    : in Number_Base := 10;
                            Field   : in All_Edit_Index_T := 0;
                            Justify : in Alignment := Left;
                            Fill    : in Character := ' ')
   is
      Value_Img : AStr11;
      Last      : Edit_Index_T;
   begin
      Put_U32 (Unsigned_32(Value), Base, Value_Img, Last);
      Put (Value_Img (2..Last), Field, Justify, Fill);
   end Generic_Put_U;

end AVR.Strings.Edit.Generic_Integers;
