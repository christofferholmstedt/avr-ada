package AVR.Strings.Edit is
   pragma Preelaborate;

   --  we use global variables for the input and output buffers
   Input_Buffer_Length  : constant := 30;

   subtype All_Input_Index_T is Unsigned_8 range 0 .. Input_Buffer_Length+1;
   subtype Input_Index_T is All_Input_Index_T range 1 .. Input_Buffer_Length;

   Input_Line  : AVR_String (Input_Index_T); --  buffer for all input
   Input_Ptr   : All_Input_Index_T;          --  current location of parsing
   Input_Last  : All_Input_Index_T;          --  end marker of input


   type Input_String is private;
   function Length (Text : Input_String) return All_Input_Index_T;
   function First (Text : Input_String) return All_Input_Index_T;
   function Last (Text : Input_String) return All_Input_Index_T;

   --------------------------------------------------------------------------

   --  Skip all leading occurences of the specified character.  It
   --  advances the Input_Ptr to the first non-specified character or
   --  to the end of the Input_Line.
   procedure Skip (Blank : Character := ' ');

   --  Input_Ptr is advanced to the first Stop character or to
   --  Input_Buffer_Length + 1.
   procedure Get_Str (Stop : Character := ' ');
   function Get_Str (Stop : Character := ' ') return Input_String;

   procedure Get_U16_Hex (Val : out Unsigned_16);
   function Get_U16_Hex return Unsigned_16;
   procedure Get_U8_Hex (Val : out Unsigned_8);
   function Get_U8_Hex return Unsigned_8;

   ---------------------------------------------------------------------

   Output_Buffer_Length : constant := 30;

   subtype All_Output_Index_T is Unsigned_8 range 0 .. Output_Buffer_Length+1;
   subtype Output_Index_T is All_Output_Index_T range 1 .. Output_Buffer_Length;

   Output_Line : AVR_String (Output_Index_T);
   Output_Ptr  : All_Output_Index_T;

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
                  Fill        : Character := ' ');
   procedure Put (Value       : AVR_String;
                  Field       : All_Output_Index_T := 0;
                  Justify     : Alignment := Left;
                  Fill        : Character := ' ');

private

   type Input_String is record
      First : Input_Index_T;
      Last  : Input_Index_T;
   end record;


end AVR.Strings.Edit;
