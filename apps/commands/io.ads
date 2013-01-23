with AVR.Strings;                  use AVR.Strings;
with Commands;                     use Commands;
with PM_Str;                       use PM_Str;

package IO is
   pragma Preelaborate;


   procedure Parse;
   procedure IO_Get;
   procedure IO_Set;
   procedure Dump;

   Get_Txt    : constant AVR_String := "get";
   Set_Txt    : constant AVR_String := "set";
   Dump_Txt   : constant AVR_String := "dump";

private

   Get_PM     : constant Text_In_Progmem := (Get_Txt'Length, Get_Txt);
   Set_PM     : constant Text_In_Progmem := (Set_Txt'Length, Set_Txt);
   Dump_PM    : constant Text_In_Progmem := (Dump_Txt'Length, Dump_Txt);

   pragma Linker_Section (Get_PM, ".progmem");
   pragma Linker_Section (Set_PM, ".progmem");
   pragma Linker_Section (Dump_PM, ".progmem");

   IO_Cmds : constant Cmd_List_T :=
     ((PM_String(Get_PM'Address), IO_Get'Access),
      (PM_String(Set_PM'Address), IO_Set'Access),
      (PM_String(Dump_PM'Address), Dump'Access));

   procedure Show_IO_Commands;

   IO_Default : constant Cmd_Action := Show_IO_Commands'Access;

end IO;
