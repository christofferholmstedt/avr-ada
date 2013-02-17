with System;
with Interfaces;                   use Interfaces;
with AVR;                          use AVR;
with AVR.Strings;
with AVR.Strings.Edit;             use AVR.Strings.Edit;
with AVR.Strings.Edit.Integers;
with AVR.UART_Base_Polled;
with Commands;                     use Commands;

package body IO is


   procedure Flush is new AVR.Strings.Edit.Flush_Output
     (Put_Raw => AVR.UART_Base_Polled.Put_Raw);


   procedure Parse is
   begin
      Commands.Parse_Input_And_Trigger_Action (IO_Cmds, IO_Default);
   end Parse;


   procedure IO_Get
   is
      Addr : Unsigned_16;
   begin
      Skip;
      Integers.Get (Unsigned_16(Addr), 16);
      Integers.Put (Addr, 16, Field => 4, Justify => Right, Fill => '0');
      Put(": ");
      declare
         Cell : Unsigned_8;
         for Cell'Address use System.Address(Addr);
      begin
         Integers.Put (Cell, 16, Field => 2, Justify => Right, Fill => '0');
      end;
      New_Line; Flush;
   end IO_Get;


   procedure Dump
   is
      Addr : Unsigned_16;
   begin
      Skip;
      Integers.Get (Unsigned_16(Addr), 16);
      Integers.Put (Addr, 16, Field => 4, Justify => Right, Fill => '0');
      Put (':');
      for I in 1 .. 16 loop
         declare
            Cell : Unsigned_8;
            for Cell'Address use System.Address(Addr);
         begin
            Put(' ');
            Integers.Put(Cell, 16, Field => 2, Justify => Right, Fill => '0');
         end;
         Addr := Addr + 1;
      end loop;
      Edit.New_Line; Flush;
   end Dump;


   procedure IO_Set
   is
      Addr : Unsigned_16;
      Val  : Unsigned_8;
   begin
      Skip;
      Integers.Get (Unsigned_16(Addr), 16);
      Skip;
      Integers.Get (Val, 16);
      --  Put ("set register ");
      --  Integers.Put (Addr, 16, Field => 4, Justify => Right, Fill => '0');
      --  Put (" to value ");
      --  Integers.Put (Val, 16, Field => 2, Justify => Right, Fill => '0');
      --  Edit.New_Line; Flush;
      declare
         Cell : Unsigned_8;
         for Cell'Address use System.Address(Addr);
      begin
         Cell := Val;
         null;
      end;
   end IO_Set;


   procedure Show_IO_Commands
   is
      procedure Put_Char (C : Character) is
      begin
         AVR.Strings.Edit.Put (C);
      end Put_Char;
      procedure Put is new PM_Str.Generic_Put (Put_Char);
   begin
      for I in IO_Cmds'Range loop
         Put (IO_Cmds(I).Id);
         Edit.New_Line; Flush;
      end loop;
   end Show_IO_Commands;

end IO;
