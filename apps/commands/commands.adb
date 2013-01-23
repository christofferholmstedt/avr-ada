with System;
with Interfaces;                   use Interfaces;
with Ada.Unchecked_Conversion;
with Interfaces;                   use Interfaces;
with AVR;                          use AVR;
with AVR.UART;
with AVR.Watchdog;
with AVR.Strings.Edit;             use AVR.Strings.Edit;
with AVR.Programspace;             use AVR.Programspace;

with PM_Str;
with IO;
with OW;

package body Commands is


   function Is_Equal (Left : PM_String; Right : Input_String) return Boolean
   is
      use System;
      Ch : Character;
      PM_Ptr : Programspace.Program_Address;
      Left_Len : constant Unsigned_8 := Unsigned_8(Length(Left));
      function "+" is new Ada.Unchecked_Conversion (Source => Unsigned_8,
                                                    Target => Character);
   begin
      --  UART.Put ("'");
      --  UART.Put(Input_Line(First(Right) .. Last(Right)));
      --  UART.Put ("' =? '");

      if Left_Len /= Unsigned_8(Length(Right)) then return False; end if;

      PM_Ptr := Programspace.Program_Address(Left);
      for I in First(Right) .. Last(Right) loop
         PM_Ptr := PM_Ptr + 1;
         Ch := +Programspace.Get(PM_Ptr);
         if Ch /= Input_Line(I) then return False; end if;
      end loop;

      return True;
   end Is_Equal;


   procedure Parse_Input_And_Trigger_Action (Cmd_List       : Cmd_List_T;
                                             Default_Action : Cmd_Action)
   is
      use AVR.Strings.Edit;
      Cmd : Input_String;
   begin
      Skip;
      Cmd := Get_Str;

      --  UART.Put ("found id '");
      --  UART.Put(Input_Line(First(Cmd) .. Last(Cmd)));
      --  UART.Put_Line ("'");

      for I in Cmd_List'Range loop
         if Is_Equal (Cmd_List(I).Id, Cmd) then
            Cmd_List(I).Action.all;
            return;
         end if;
      end loop;
      -- UART.Put_Line("no command found, trigger default action");
      -- Default_Action.all;
   end Parse_Input_And_Trigger_Action;


   procedure Show_Commands is
      procedure Put is new PM_Str.Generic_Put (UART.Put_Char);
   begin
      for I in Cmd_List'Range loop
         Put (Cmd_List(I).Id);
         UART.New_Line;
      end loop;
   end Show_Commands;

   procedure Reset is
   begin
      UART.Put_Line ("reset");
   end Reset;

   procedure Wd_Reset is
   begin
      UART.Put_Line ("going to reset via watchdog");
      Watchdog.Enable(Watchdog.WDT_16K);
      Watchdog.Wdr;
      loop null; end loop;
   end Wd_Reset;

   procedure OW_Parse renames OW.Parse;
   procedure IO_Parse renames IO.Parse;

end Commands;
