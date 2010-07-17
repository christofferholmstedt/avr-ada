--   implementation for simulation on host, uses the arrow keys + return

with Ada.Text_IO;                  use Ada.Text_IO;

package body Button is


   Key : Button_Direction := Nil;
   pragma Volatile (Key);

   Key_Valid : Boolean := False;
   pragma Volatile (Key_Valid);


   --  Check status on the joystick
   procedure Pin_Change_Interrupt is
      C : Character;
      Avail : Boolean;

      K : Button_Direction;
   begin
      -- Ada.Text_IO.Put_Line ("wait for key");
      Get_Immediate (C, Avail);
      -- Ada.Text_IO.Put_Line ("got " & avail'img);
      K := Nil;

      if Avail then
         -- Ada.Text_IO.Put_Line ("isr: c = '" & C & "', pos(c) =" & Character'Pos (C)'Img);
         if Character'Pos (C) = 224 then
            Get_Immediate (C, Avail);
            if Avail then
               case C is
               when 'H' => K := Up;
               when 'K' => K := Left;
               when 'P' => K := Down;
               when 'M' => K := Right;
               when others => null; -- ignore
               end case;
            end if;
         else
            if C = ASCII.LF or else C = ASCII.CR then
               K := Enter;
            end if;
         end if;
      end if;

      if K /= Nil then
         if not Key_Valid then
            Key := K;          -- Store key in global key buffer
            Key_Valid := True;
         end if;
      end if;

   end Pin_Change_Interrupt;


   --  Initialize the five button pin
   procedure Init is
   begin
      null;
      Key_Valid := False;
   end Init;


   function Get return Button_Direction is
      K : Button_Direction;
   begin
      Pin_Change_Interrupt;

      if Key_Valid then      -- Check for unread key in buffer
         K := Key;
         Key_Valid := False;
         Ada.Text_IO.Put_Line ("key: " & Key'Img);
      else
         K := Nil;           -- No key stroke available
         delay 0.01;
      end if;

      return K;
   end Get;

end Button;
