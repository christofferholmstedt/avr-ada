with AVR;                          use AVR;
with AVR.Strings;                  use AVR.Strings;
with PM_Str;                       use PM_Str;

package Commands is
   pragma Preelaborate;


   type Cmd_Action is not null access procedure;

   type Cmd_Info is record
      Id     : PM_String;
      Action : Cmd_Action;
   end record;

   type Cmd_List_T is array(Positive range <>) of Cmd_Info;

   procedure Parse_Input_And_Trigger_Action (Cmd_List       : Cmd_List_T;
                                             Default_Action : Cmd_Action);

   type Text_In_Progmem (Len : Nat8) is record
      Text : AVR_String(1..Len);
   end record;


   Cmd_List : constant Cmd_List_T;
   Default  : constant Cmd_Action;

private


   procedure Show_Commands;
   procedure Reset;
   procedure Wd_Reset;
   procedure OW_Parse;
   procedure IO_Parse;


   Help_Txt    : constant AVR_String := "help";
   Reset_Txt   : constant AVR_String := "reset";
   Wd_Reset_Txt : constant AVR_String := "wd_reset";
   Ow_Txt      : constant AVR_String := "1w";
   IO_Txt      : constant AVR_String := "io";

   Help_PM     : constant Text_In_Progmem := (Help_Txt'Length, Help_Txt);
   Reset_PM    : constant Text_In_Progmem := (Reset_Txt'Length, Reset_Txt);
   Wd_Reset_PM : constant Text_In_Progmem := (Wd_Reset_Txt'Length, Wd_Reset_Txt);
   Ow_PM       : constant Text_In_Progmem := (Ow_Txt'Length, Ow_Txt);
   IO_PM       : constant Text_In_Progmem := (IO_Txt'Length, IO_Txt);

   pragma Linker_Section (Help_PM, ".progmem");
   pragma Linker_Section (Reset_PM, ".progmem");
   pragma Linker_Section (Wd_Reset_PM, ".progmem");
   pragma Linker_Section (Ow_PM, ".progmem");
   pragma Linker_Section (IO_PM, ".progmem");

   Cmd_List : constant Cmd_List_T :=
     ((PM_String(Help_PM'Address),     Show_Commands'Access),
      (PM_String(Reset_PM'Address),    Reset'Access),
      (PM_String(Wd_Reset_PM'Address), Wd_Reset'Access),
      (PM_String(OW_PM'Address),       OW_Parse'Access),
      (PM_String(IO_PM'Address),       IO_Parse'Access));

   Default : constant Cmd_Action := Show_Commands'Access;
end Commands;
