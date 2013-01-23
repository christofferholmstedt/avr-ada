with System;
with Interfaces;                   use Interfaces;
with AVR;                          use AVR;
with AVR.Strings;
with AVR.Strings.Edit;             use AVR.Strings.Edit;
with AVR.UART;
with Commands;                     use Commands;

package body IO is


   procedure Parse is
   begin
      Commands.Parse_Input_And_Trigger_Action (IO_Cmds, IO_Default);
   end Parse;

   procedure IO_Get
   is
      Addr : Unsigned_16;
   begin
      Skip;
      Addr := Get_U16_Hex;
      UART.Put ("read register ");
      UART.Put (Addr);
      declare
         Cell : Unsigned_8;
         for Cell'Address use System.Address(Addr);
      begin
         UART.Put(": ");
         UART.Put(Cell, 16);
      end;

      UART.New_Line;
   end IO_Get;

   procedure Dump
   is
      Addr : Unsigned_16;
   begin
      Skip;
      Addr := Get_U16_Hex;
      UART.Put (Addr, 16);
      UART.Put (':');
      for I in 1 .. 16 loop
         declare
            Cell : Unsigned_8;
            for Cell'Address use System.Address(Addr);
         begin
            UART.Put(' ');
            UART.Put(Cell, 16);
         end;
         Addr := Addr + 1;
      end loop;
      UART.New_Line;
   end Dump;

   procedure IO_Set
   is
      Addr : Unsigned_16;
      Val  : Unsigned_8;
   begin
      Skip;
      Addr := Get_U16_Hex;
      Skip;
      Val := Get_U8_Hex;
      UART.Put ("set register ");
      UART.Put (Addr);
      UART.Put (" to value ");
      UART.Put (Val);
      UART.New_Line;
      declare
         Cell : Unsigned_8;
         for Cell'Address use System.Address(Addr);
      begin
         Cell := Val;
      end;
   end IO_Set;

   procedure Show_IO_Commands
   is
      procedure Put is new PM_Str.Generic_Put (UART.Put_Char);
   begin
      for I in IO_Cmds'Range loop
         Put (IO_Cmds(I).Id);
         UART.New_Line;
      end loop;
   end Show_IO_Commands;

end IO;
