--  Target(s)...: ATmega169

with Interfaces;     use Interfaces;   -- unsigned_8
with LCD_Driver;     use LCD_Driver;   -- scrollmode visible
with Pstr20;

package LCD_Functions is
   -- pragma Preelaborate (LCD_Functions);


   subtype Str is Pstr20.Pstring;


   -- clear the display
   procedure Clear;


   procedure Put (Text : Str; Scroll : Scrollmode_T := None);


   -- put a single character at the specified location
   procedure Put (Digit : LCD_Index; Char : Character);

   --  Put the number Num in the display right-aligned at the location
   --  Digit.  That means the ones are at Digit, the tens at Digit-1
   --  and the hundreds at Digit-2.  Show in Base 10 per default.  The
   --  only other permitted value is 16 for hex-numbers.  Hexadecimal
   --  number will alway have a leading 0.
   procedure Put (Right_Digit : LCD_Index;
                  Num         : Unsigned_8;
                  Base        : Unsigned_8 := 10);
   procedure Put (Right_Digit : LCD_Index;
                  Num         : Unsigned_16;
                  Base        : Unsigned_8 := 10);


   --  switch the colons on the LCD
   procedure Colon (Show : Boolean);


   --  reset the blinking cycle of a flashing digit
   procedure Flash_Reset;


   --  set the contrast level
   procedure Set_Contrast (Contrast : Contrast_Level);

end Lcd_Functions;
