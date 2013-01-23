package body AVR.Strings.Edit is


   function Length (Text : Input_String) return All_Input_Index_T is
   begin
      return Text.Last - Text.First + 1;
   end Length;


   function First (Text : Input_String) return All_Input_Index_T is
   begin
      return Text.First;
   end First;


   function Last (Text : Input_String) return All_Input_Index_T is
   begin
      return Text.Last;
   end Last;


   procedure Skip (Blank : Character := ' ') is
   begin
      while Input_Line (Input_Ptr) = Blank loop
         Input_Ptr := Input_Ptr + 1;
         exit when Input_Ptr > Input_Last;
      end loop;
   end Skip;


   --  This procedure skips the blank characters starting from
   --  Input_Line(ptr_input).  Ptr_Input is advanced to the first
   --  non-blank character or to Input_Buffer_Length + 1.
   procedure Get_Str (Stop : Character := ' ') is
   begin
      while Input_Line(Input_Ptr) /= Stop loop
         Input_Ptr := Input_Ptr + 1;
         exit when Input_Ptr > Input_Last;
      end loop;
   end Get_Str;

   function Get_Str (Stop : Character := ' ') return Input_String is
      Word : Input_String;
   begin
      Skip;
      Word.First := Input_Ptr;
      Get_Str (Stop);
      Word.Last := Input_Ptr - 1;
      return Word;
   end Get_Str;


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


   procedure Get_U16_Hex (Val : out Unsigned_16)
   is
      -- Is_Negative : Boolean := False;
      Digit : Unsigned_8;
   begin
      --  if Input_Line(Input_Ptr) = '-' then
      --     Is_Negative := True;
      --     Input_Ptr := Input_Ptr + 1;
      --  end if;

      Val := 0;
      while Input_Ptr <= Strings.Edit.Input_Last loop
         Digit := Get_Digit (Input_Line(Input_Ptr));
         exit when Digit > 15;
         Val := Val * 16 + Unsigned_16(Digit);
         Input_Ptr := Input_Ptr + 1;
      end loop;
   end Get_U16_Hex;


   function Get_U16_Hex return Unsigned_16
   is
      R : Unsigned_16;
   begin
      Get_U16_Hex(R);
      return R;
   end Get_U16_Hex;


   procedure Get_U8_Hex (Val : out Unsigned_8)
   is
      V16 : Unsigned_16;
   begin
      Get_U16_Hex (V16);
      Val := Unsigned_8(V16 and 16#00FF#);
   end Get_U8_Hex;

   function Get_U8_Hex return Unsigned_8
   is
      U8 : Unsigned_8;
   begin
      Get_U8_Hex (U8);
      return U8;
   end Get_U8_Hex;


   -- Put -- Put a character into a string
   --
   --    Value       - The character to be put
   --    Field       - The output field
   --    Justify     - Alignment within the field
   --    Fill        - The fill character
   --
   -- This  procedure  places  the specified character (Value parameter)
   -- into the Output_Line. The character is written starting
   -- from the Destination (Pointer).
   procedure Put (Value       : Character;
                  Field       : All_Output_Index_T := 0;
                  Justify     : Alignment := Left;
                  Fill        : Character := ' ')
   is
   begin
      if Field > 1 then
         if Output_Ptr + Field > All_Output_Index_T'Last then
            -- error;
            null;
         else
            if Justify = Right then
               for I in 1 .. Field - 1 loop
                  Output_Line (Output_Ptr) := Fill;
                  Output_Ptr := Output_Ptr + 1;
               end loop;
            end if;
         end if;
      end if;
      -- in all cases we append the Value
      Output_Line (Output_Ptr) := Value;
      Output_Ptr := Output_Ptr + 1;

      if Justify = Left then
         for I in 1 .. Field - 1 loop
            Output_Line (Output_Ptr) := Fill;
            Output_Ptr := Output_Ptr + 1;
         end loop;
      end if;

   end Put;

   procedure Put (Value       : AVR_String;
                  Field       : All_Output_Index_T := 0;
                  Justify     : Alignment := Left;
                  Fill        : Character := ' ')
   is
   begin
      null;
   end Put;

end AVR.Strings.Edit;
