

package Button is
   --  pragma Preelaborate (Button);

   type Button_Direction is
     (Nil, Enter, Up, Down, Left, Right);
   for Button_Direction'Size use 8;

   -- subtype Button_Direction is Button_Direction_Base range Enter .. Right;

   procedure Init;

   function Get return Button_Direction;

end Button;
