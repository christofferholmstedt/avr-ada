--
--  Target(s)...: ATmega169
--
with Interfaces;           use Interfaces;
with AVR;                  --     use Avr;
with AVR.Strings;          use AVR.Strings;


package LCD_Driver is
   pragma Preelaborate;


   --
   --  direct access to the segment registers
   --

   Register_Count   : constant :=     19;

   subtype Register_Range is Unsigned_8 range 1 .. Register_Count;
   subtype Register_Array is AVR.Byte_Array (Register_Range);

   LCD_Registers : Register_Array;
   for LCD_Registers'Address use 16#EC#;

   -- LCD display buffer in RAM (for double buffering)
   LCD_Data : Register_Array;

   -- indicate when the LCD interrupt handler should update the LCD
   procedure Update_Required;
   pragma Inline (Update_Required);
   --  the procedural interface permits easier simulation of the
   --  package on a host system

   --
   --  timing
   --

   Timer_Seed  : constant   := 8;

   LCD_Timer   : Unsigned_8 := Timer_Seed;
   pragma Volatile (LCD_Timer);


   Flash_Seed  : constant   := 10; -- period of character flashing

   --
   --  elements for display
   --
   subtype LCD_Character is Character range '*' .. '_';
   --  characters that can be sent to the display.  This does not
   --  include lowercase characters!

   Textbuffer_Size  : constant := 25;
   subtype Textbuffer_Range is Unsigned_8 range 1 .. Textbuffer_Size;

   LCD_Text_Buffer : AVR_String (Textbuffer_Range);
   -- Buffer that contains the text to be displayed
   -- Note: Bit 7 indicates that this character is flashing

   --  positions in the LCD, the left-most is 2, the right-most
   --  position is 7.
   subtype LCD_Index is Unsigned_8 range 2 .. 7;


   --
   --  special icon segments besides the characters
   --

   type Special_Characters is (Colons,
                               N1, N2, N3, N4, N5, N7, N8, N9, N10,
                               S1, S2, S3, S4, S5, S7, S8, S9, S10);

   type Special_Char_Array is array (Special_Characters) of Boolean;
   pragma Pack (Special_Char_Array);
   for Special_Char_Array'Size use 24;

   Special_Character_Status : Special_Char_Array := (others => False);

   --  initialize the registers and timing
   procedure Init;


   --
   --  control scrolling of characters
   --

   subtype Scrollmode_T is Unsigned_8 range 0 .. 3;
   None  : constant Scrollmode_T := 0;
   Once  : constant Scrollmode_T := 1;
   Cycle : constant Scrollmode_T := 2;
   Wave  : constant Scrollmode_T := 3;

   Scroll_Mode : Scrollmode_T := None;
   pragma Volatile (Scroll_Mode);

   subtype Offset_Range is Unsigned_8 range 0 .. Textbuffer_Size - 1;

   Scroll_Offset : Offset_Range;
   pragma Volatile (Scroll_Offset);
   --  Only six letters can be shown on the LCD.  With the
   --  Scroll_Offset and Scroll_Mode variables, one can select which
   --  part of the buffer to show.  Scroll_Offset is an offset to the
   --  textbuffer, where display starts.

   --  Start-up delay before scrolling a string over the LCD
   Start_Scroll_Delay : Unsigned_8 := 0;


   --  Show or hide all LCD segments on the LCD
   procedure All_Segments (Show : Boolean);


   --
   -- Contrast
   --

   subtype Contrast_Level is Unsigned_8 range 0 .. 16#0F#;
   --  15 (16#0F#) is the highest contrast level.

   Initial_Contrast : constant Contrast_Level := 16#0F#; -- full contrast

   procedure Set_Contrast_Level (Level : Contrast_Level);
   pragma Inline (Set_Contrast_Level);


   --
   --  Button debounce timer
   --
   Button_Timeout : Boolean := False;
   pragma Volatile (Button_Timeout);


end LCD_Driver;
