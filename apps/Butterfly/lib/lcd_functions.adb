--
--  Target(s)...: ATmega169
--


with Interfaces;        use Interfaces;

with LCD_Driver;        use LCD_Driver;
with Int_Img;           use Int_Img;

-- with Avr;            use Avr;
-- with Ada.Unchecked_Conversion;

package body LCD_Functions is


   --  Writes a string to the LCD
   procedure Put (Text : Str; Scroll : Scrollmode_T := None) is
      use Pstr20;
      pragma Unreferenced (Scroll);
      L : constant Unsigned_8 := Length (Text);
   begin
      -- Wait for access to buffer
      while Update_Required loop null; end loop;

      for J in 1 .. L loop
         LCD_Driver.Text_Buffer (J) := Element (Text, J);
      end loop;

      Text_Buffer (L + 1) := ASCII.NUL;

      if L > 5 then
         Scroll_Mode := Once;   -- Scroll if text is longer than display size
         Scroll_Offset := 0;
         Start_Scroll_Timer := 3; -- Start-up delay before scrolling the text
      else
         Scroll_Mode   := None;
         Scroll_Offset := 0;
      end if;

      LCD_Driver.Update_Required := True;
   end Put;


   --    Parameters :    digit: Which digit to write on the LCD
   --                char : Character to write
   --
   --  Writes a character to the LCD
   procedure Put (Digit : LCD_Index; Char : Character) is
   begin
      Text_Buffer (Digit) := Char;
   end Put;


   procedure Put (Right_Digit : LCD_Index;
                  Num         : Unsigned_8;
                  Base        : Unsigned_8 := 10)
   is
      N : Unsigned_8 := Num; -- starts with Num, eventually becomes ones
      H : Unsigned_8 := 0;   -- hundreds
      T : Unsigned_8 := 0;   -- tens / sixteens
      L : LCD_Driver.Textbuffer_Range := Right_Digit - 1;
   begin
      if Base /= 16 then
         while N >= 100 loop
            H := H + 1;
            N := N - 100;
         end loop;

         while N >= 10 loop
            T := T + 1;
            N := N - 10;
         end loop;

         LCD_Driver.Text_Buffer (L) := Character'Val (N + 48);
         L := L - 1;

         if H > 0 then
            LCD_Driver.Text_Buffer (L) := Character'Val (T + 48);
            L := L - 1;
            LCD_Driver.Text_Buffer (L) := Character'Val (H + 48);
         else
            if T > 0 then
               LCD_Driver.Text_Buffer (L) := Character'Val (T + 48);
            else
               LCD_Driver.Text_Buffer (L) := ' ';
            end if;
            L := L - 1;
            LCD_Driver.Text_Buffer (L) := ' ';
         end if;

      else
         --  hexadecimal
         U8_Hex_Img (Num, LCD_Driver.Text_Buffer (L - 1 .. L);
      end if;
   end Put;


   procedure Put (Right_Digit : LCD_Index;
                  Num         : Unsigned_16;
                  Base        : Unsigned_8 := 10)
   is
      pragma Unreferenced (Base);
      N : Unsigned_16 := Num;-- starts with Num, eventually becomes ones
      T : Unsigned_8 := 0;  -- tens / sixteens
      H : Unsigned_8 := 0;  -- hundreds
      TH : Unsigned_8 := 0;  -- thousands
      TT : Unsigned_8 := 0;  -- ten-thousends
      L : LCD_Driver.Textbuffer_Range := Right_Digit - 1;
   begin
      while N >= 10_000 loop
         TT := TT + 1;
         N  := N - 10_000;
      end loop;

      while N >= 1_000 loop
         TH := TH + 1;
         N  := N - 1_000;
      end loop;

      while N >= 100 loop
         H := H + 1;
         N := N - 100;
      end loop;

      while N >= 10 loop
         T := T + 1;
         N := N - 10;
      end loop;

      -- ones
      LCD_Driver.Text_Buffer (L) := Character'Val (N+48);
      L := L - 1;
      LCD_Driver.Text_Buffer (L) := Character'Val (T+48);
      L := L - 1;
      LCD_Driver.Text_Buffer (L) := Character'Val (H+48);
      L := L - 1;
      LCD_Driver.Text_Buffer (L) := Character'Val (TH+48);
      L := L - 1;
      LCD_Driver.Text_Buffer (L) := Character'Val (TT+48);

   end Put;


   --  Clear the LCD
   procedure Clear is
   begin
      Text_Buffer := (others => ' ');
   end Clear;


   --  Enable/disable colons on the LCD
   procedure Colon (Show : Boolean) is
   begin
      LCD_Driver.Special_Character_Status.Colons := Show;
   end Colon;


   --  This function resets the blinking cycle of a flashing digit
   procedure Flash_Reset is
   begin
      LCD_Driver.Flash_Timer := 0;
      null;
   end Flash_Reset;


   procedure Set_Contrast (Contrast : Contrast_Level)
     renames LCD_Driver.Set_Contrast_Level;

end LCD_Functions;
