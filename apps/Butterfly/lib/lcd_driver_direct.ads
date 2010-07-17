--  directly writing driver for the LCD.  This package does not use
--  interrupts or timing for driving the LCD.
--
--  usage: set the text in Text_Buffer and the icons in
--  Special_Character_Status.  Then call Update_Required to actually
--  write the corresponding segment buffer.
--

with AVR;                          use AVR;
with AVR.Strings;                  use AVR.Strings;

package LCD_Driver_Direct is
   -- pragma Preelaborate;

   --
   --  elements for display
   --

   subtype LCD_Character is Character range '*' .. '_';
   --  characters that can be sent to the display.  This does not
   --  include lowercase characters!

   subtype LCD_Index is Nat8 range 2 .. 7;
   --  positions in the LCD, the left-most is 2, the right-most
   --  position is 7.  See the data sheet.

   LCD_Text_Buffer : AStr16;
   --  Buffer that contains the text to be displayed.

   subtype Offset_Range is Nat8 range AStr16'First .. AStr16'Last;

   First_Char : Offset_Range;
   --  First_Char is the pointer to the first character in Text_Buffer
   --  that is to be displayed.

   Last_Char : Offset_Range;
   --  Last_Char is the pointer to the last character in Text_Buffer
   --  that is to be displayed.  If Last_Char is less than First_Char
   --  or Last_Char > First_Char + 5 then the six characters from
   --  First_Char .. First_Char + 5 will be displayed.

   --
   --  special icon segments above and below the characters
   --

   type Special_Characters is (
      Colons,
      N1, N2, N3, N4, N5, N7, N8, N9, N10,  --  numbers
      S1, S2, S3, S4, S5, S7, S8, S9, S10); --  arrows

   type Special_Char_Array is array (Special_Characters) of Boolean;
   pragma Pack (Special_Char_Array);
   for Special_Char_Array'Size use 24;

   Special_Character_Status : Special_Char_Array := (others => False);

   Use_Special_Characters : Boolean := False;
   --  if you use any icon, their display have to be enabled first

   procedure Init;
   --  initialize the registers

   procedure All_Segments (Show : Boolean);
   --  Show or hide all LCD segments on the LCD

   --
   --  Timing and interrupt handling
   --

   -- indicate when the LCD interrupt handler should update the LCD
   procedure Update_Required;
   pragma Inline (Update_Required);

   --
   -- Contrast
   --

   Full_Contrast : constant := 16#0F#;
   Null_Contrast : constant := 16#00#;

   type Contrast_Level is range Null_Contrast .. Full_Contrast;
   for Contrast_Level'Size use 8;

   Initial_Contrast : constant Contrast_Level := Full_Contrast;

   procedure Set_Contrast_Level (Level : Contrast_Level);
   pragma Inline (Set_Contrast_Level);

   -----------------------------------------------------------------------

   Debounce_Timeout : Boolean := True;
   pragma Volatile (Debounce_Timeout);


end LCD_Driver_Direct;
