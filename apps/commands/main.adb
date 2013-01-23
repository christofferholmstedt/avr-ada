--  command interpreter and chip inspection
with AVR;                          use AVR;
with AVR.Strings;                  use AVR.Strings;
with AVR.Strings.Edit;
with AVR.UART;
with Commands;                     use Commands;

procedure Main is
   Prompt : constant AVR_String := "$> ";

begin
   UART.Init (UART.Baud_19200_16MHz);
   UART.Put_Line ("starting chip inspection");

   Cmd_Loop : loop
      UART.Put (Prompt);
      UART.Get_Line (Strings.Edit.Input_Line, Strings.Edit.Input_Last);
      Strings.Edit.Input_Ptr := 1;

      UART.Put ("found complete input """);
      UART.Put (Strings.Edit.Input_Line(1 .. Strings.Edit.Input_Last));
      UART.Put_Line ("""");

      Parse_Input_And_Trigger_Action (Commands.Cmd_List, Commands.Default);
   end loop Cmd_Loop;
end Main;
