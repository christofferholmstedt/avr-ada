--
--

-- with AVR;                   use AVR;
with AVR.ATmega169;         use AVR.ATmega169;
with AVR.Programspace;

package body LCD_Driver is


   Update_Is_Required : Boolean := False;
   pragma Volatile (Update_Required);


   --  write the character C to the display location Digit
   procedure Write_Digit (C : LCD_Character; Digit : LCD_Index);


   -- Look-up table used when converting ASCII to
   -- LCD display data (segment control)
   subtype Segment_Pattern is Unsigned_16;
   type Int_Array is array (LCD_Character) of Segment_Pattern;
   LCD_Character_Table : constant Int_Array :=
     (16#CA28#,     -- '*'
      16#2A80#,     -- '+'
      16#0000#,     -- ',' use for space ' '
      16#0A00#,     -- '-'
      16#0A51#,     -- '.' Degree sign
      16#4008#,     -- '/'
      16#5559#,     -- '0'
      16#0118#,     -- '1'
      16#1e11#,     -- '2
      16#1b11#,     -- '3
      16#0b50#,     -- '4
      16#1b41#,     -- '5
      16#1f41#,     -- '6
      16#0111#,     -- '7
      16#1f51#,     -- '8
      16#1b51#,     -- '9'
      16#0000#,     -- ':' (Not defined)
      16#0000#,     -- ';' (Not defined)
      16#0000#,     -- '<' (Not defined)
      16#0000#,     -- '=' (Not defined)
      16#0000#,     -- '>' (Not defined)
      16#0000#,     -- '?' (Not defined)
      16#0000#,     -- '@' (Not defined)
      16#0f51#,     -- 'A' (+ 'a')
      16#3991#,     -- 'B' (+ 'b')
      16#1441#,     -- 'C' (+ 'c')
      16#3191#,     -- 'D' (+ 'd')
      16#1e41#,     -- 'E' (+ 'e')
      16#0e41#,     -- 'F' (+ 'f')
      16#1d41#,     -- 'G' (+ 'g')
      16#0f50#,     -- 'H' (+ 'h')
      16#2080#,     -- 'I' (+ 'i')
      16#1510#,     -- 'J' (+ 'j')
      16#8648#,     -- 'K' (+ 'k')
      16#1440#,     -- 'L' (+ 'l')
      16#0578#,     -- 'M' (+ 'm')
      16#8570#,     -- 'N' (+ 'n')
      16#1551#,     -- 'O' (+ 'o')
      16#0e51#,     -- 'P' (+ 'p')
      16#9551#,     -- 'Q' (+ 'q')
      16#8e51#,     -- 'R' (+ 'r')
      16#9021#,     -- 'S' (+ 's')
      16#2081#,     -- 'T' (+ 't')
      16#1550#,     -- 'U' (+ 'u')
      16#4448#,     -- 'V' (+ 'v')
      16#c550#,     -- 'W' (+ 'w')
      16#c028#,     -- 'X' (+ 'x')
      16#2028#,     -- 'Y' (+ 'y')
      16#5009#,     -- 'Z' (+ 'z')
      16#0000#,     -- '[' (Not defined)
      16#0000#,     -- '\' (Not defined)
      16#0000#,     -- ']' (Not defined)
      16#0000#,     -- '^' (Not defined)
      16#0000#      -- '_'
     );
   pragma Linker_Section (LCD_Character_Table, ".progmem");


   --  Set up the LCD (timing, contrast, etc.)
   procedure Init is
      LCD_Control_Status_A : AVR.Bits_In_Byte;
      for LCD_Control_Status_A'Address use LCDCRA;

      LCD_Control_Status_B : AVR.Bits_In_Byte;
      for LCD_Control_Status_B'Address use LCDCRB;

      Frame_Rate_Reg : AVR.Bits_In_Byte;
      for Frame_Rate_Reg'Address use LCDFRR;

   begin
      All_Segments (False);                       -- Clear segment buffer

      Set_Contrast_Level (Initial_Contrast);
      -- Set the LCD contrast level

      -- Select asynchronous clock source, enable all COM pins and enable all
      -- segment pins. (see page 221)
      LCD_Control_Status_B := (LCDCS_Bit => True,     -- async ext. clock

                               LCD2B_Bit => False,    -- 1/3 bias

                               LCDMUX0_Bit => True,   --\   1/4 duty
                               LCDMUX1_Bit => True,   --/   COM0 .. COM3

                               LCDPM0_Bit => True,    --\   use all IO ports
                               LCDPM1_Bit => True,    ---   SEG0 .. SEG24 as
                               LCDPM2_Bit => True,    --/   segment driver
                               others => False);


      --  Set LCD prescaler to give a framerate of 32,0 Hz (= prescaled
      --  LCD clock, clk_{LCD_PS}, (see page 222)
      Frame_Rate_Reg := (LCDCD0_Bit => True,   --\
                         LCDCD1_Bit => True,   ---  clock divider = 8
                         LCDCD2_Bit => True,   --/

                         LCDPS0_Bit => False,  --\
                         LCDPS1_Bit => False,  ---  prescaler = 16
                         LCDPS2_Bit => False,  --/

                         others => False);
      --
      --                  f_clk_LCD
      -- f_frame = ------------------------
      --             K x N x ( 1 + LCDCD)
      --
      -- f_clk_LCD             = 32.768 kHz
      -- N (prescaler)         = 16
      -- K (duty=1/4)          = 8
      -- LCDCD (clock devider) = 7
      --
      --             32.768 kHz
      -- f_frame = -------------- = 32 Hz
      --             8 x 16 x 8
      --
      -- see page 223
      --

      LCD_Control_Status_A :=
        (LCDEN_Bit => True, -- enable LCD
         LCDAB_Bit => True, -- set low power waveform
         LCDIE_Bit => True, -- enable LCD start of frame itr
         others => False);

      Update_Is_Required := False;
   end Init;


   procedure Update_Required is
   begin
      Update_Is_Required := True;
   end Update_Required;



   --*************************************************************************
   --
   --  Parameters :  C: The symbol to be displayed in a LCD digit
   --                digit: In which digit (2-7) the symbol should be displayed
   --                Note: Digit 2 is the first used digit on the LCD,
   --
   --  Purpose :     Stores LCD control data in the LCD_displayData buffer.
   --                (The LCD_displayData is latched in the LCD_SOF interrupt.)
   --
   --**************************************************************************
   procedure Write_Digit (C : LCD_Character; Digit : LCD_Index)
   is
      Seg    : Segment_Pattern;        -- Holds the segment pattern
      Mask   : Unsigned_8;
      Nibble : Unsigned_8;
      Ptr    : Register_Range;
   begin
      --  Lookup character table for segmet data
      Seg := Programspace.Get (LCD_Character_Table (C)'Address);

      -- Adjust mask according to LCD segment mapping
      if (Digit and 16#01#) /= 0 then
         Mask := 16#0F#;              -- Digit in (3, 5, 7)
      else
         Mask := 16#F0#;              -- Digit in (2, 4, 6)
      end if;

      Ptr := Digit / 2;               -- Digit = {1,1,2,2,3,3}

      for I in 1 .. 4 loop -- for all nibbles in the segment pattern
         Nibble := Unsigned_8 (Seg and 16#000F#); -- get low nibble
         Seg := Shift_Right (Seg, 4);            -- shift remaining pattern
         if (Digit and 16#01#) /= 0 then
            Nibble := Shift_Left (Nibble, 4);
         end if;
         LCD_Registers (Ptr) := (LCD_Registers (Ptr) and Mask) or Nibble;
         Ptr := Ptr + 5;
      end loop;
   end Write_Digit;


   procedure Check_Special (S : Special_Characters;
                            R : Register_Range;
                            Segment  : Unsigned_8);
   pragma Inline (Check_Special);

   procedure Check_Special (S : Special_Characters;
                            R : Register_Range;
                            Segment  : Unsigned_8)
   is
   begin
      if Special_Character_Status (S) then
         LCD_Registers (R) := LCD_Registers (R) or Segment;
      else
         LCD_Registers (R) := LCD_Registers (R) and (not Segment);
      end if;
   end Check_Special;


   procedure All_Segments (Show : Boolean) is
      --    shows or hide all all LCD segments on the LCD
      Full : Unsigned_8 := 0;
   begin
      if Show then Full := 16#FF#; end if;
      LCD_Registers := (others => Full);
   end All_Segments;


   Blank : constant Character := ',';  --  character code that displays
                                       --  nothing, refer to the
                                       --  LCD_Character_Table above.

   Debounce_Timer : Unsigned_8 := 0;
   Flash_Timer    : Unsigned_8 := 0;
   --  The Flash_Timer is used to determine the on/off timing of
   --  flashing characters

   procedure LCD_Interrupt;
   pragma Machine_Attribute(Entity         => LCD_Interrupt,
                            Attribute_Name => "signal");
   pragma Export(C, LCD_Interrupt, Sig_LCD_String);


   procedure LCD_Interrupt is
      C : Character;
      EOL : Unsigned_8;
      Flash : Boolean;
      C_Flash : Boolean := False;

   begin
      if not Button_Timeout then
         Debounce_Timer := Debounce_Timer + 1;

         if Debounce_Timer > 3 then
            Button_Timeout := True;
            Debounce_Timer := 0;
         end if;
      end if;


      LCD_Timer := LCD_Timer - 1;   -- decreased every LCD frame

      if Scroll_Mode /= None then

         -- If we are in scroll mode, and the timer has expired,
         -- we will update the LCD
         if LCD_Timer = 0 then
            if Start_Scroll_Delay = 0 then
               Update_Is_Required := True;
            else
               Start_Scroll_Delay := Start_Scroll_Delay - 1;
            end if;
         end if;
      else
         -- if not scrolling,
         -- disble LCD start of frame interrupt
         --        cbi(LCDCRA, LCDIE);   --DEBUG
         --  Set_IO_Bit (LCDCRA, LCDIE, False);
         Scroll_Offset := 0;
      end if;

      EOL := 0;
      if Update_Is_Required then
         -- Duty cycle of flashing characters
         if Flash_Timer < FLASH_SEED * 2 then
            Flash := False;
         else
            Flash := True;
         end if;

         -- Repeat for the six LCD characters
         for I in Lcd_Index loop
            if Scroll_Offset + I >= LCD_Index'First and then EOL = 0 then
               -- We have some visible characters
               C := LCD_Text_Buffer(Unsigned_8((I-LCD_Index'First) + Scroll_Offset)
                                + LCD_Text_Buffer'First);
               -- C_Flash := (C and 16#80#) /= 0;
               -- C := C and 16#7F#;

               if C = ' ' then
                  C := Blank;
               elsif C = ASCII.NUL then
                  EOL := I+1;      -- End of character data
               end if;
            else
               C := Blank;
            end if;

            -- Check if this character is flashing

            if C_Flash and then Flash then
               Write_Digit (Blank, I);
            else
               Write_Digit (C, I);
            end if;

         end loop;

         --  see if any special character have to be displayed
         Check_Special ( S1, 1, 16#02#);
         Check_Special ( N1, 1, 16#04#);
         Check_Special ( S2, 1, 16#20#);
         Check_Special ( N2, 1, 16#40#);
         Check_Special ( S3, 2, 16#04#);
         Check_Special ( S4, 2, 16#40#);
         Check_Special ( N4, 2, 16#02#);
         Check_Special ( N5, 2, 16#20#);
         Check_Special ( S9, 3, 16#02#);
         Check_Special ( N9, 3, 16#04#);
         Check_Special (S10, 3, 16#20#);
         Check_Special (N10, 3, 16#40#);


         -- Copy the segment buffer to the real segments
         LCD_Registers := LCD_Data;

         -- Handle colon
         if Special_Character_Status (Colons) then
            LCD_Registers (9) := 16#01#;
         else
            LCD_Registers (9) := 16#00#;
         end if;

         -- If the text scrolled off the display,
         -- we have to start over again.
         if EOL = 1 + LCD_Index'First then
            -- G_Scroll := -6;
            Scroll_Offset := 0;
         else
            Scroll_Offset := Scroll_Offset + 1;
         end if;

         -- No need to update anymore
         Update_Is_Required := False;
      end if;


      -- LCD_Timer is used when scrolling text
      if LCD_Timer = 0 then
         LCD_Timer := Timer_Seed;
      end if;

      -- Flash_Timer is used when flashing characters
      if Flash_Timer = Flash_Seed then
         Flash_Timer := 0;
      else
         Flash_Timer := Flash_Timer + 1;
      end if;

   end LCD_Interrupt;


   procedure Set_Contrast_Level (Level : Contrast_Level) is
      LCDCCR_Reg : Unsigned_8;
      for LCDCCR_Reg'Address use LCDCCR;
   begin
      LCDCCR_Reg := Level and 16#0F#;
   end Set_Contrast_Level;


end LCD_Driver;
