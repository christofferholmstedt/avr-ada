------------------------------------------------------------------------------
--                                                                          --
--                         GNAT COMPILER COMPONENTS                         --
--                                                                          --
--                       A D A . E X C E P T I O N S                        --
--                                                                          --
--                                 B o d y                                  --
--                                                                          --
--          Copyright (C) 1992-2007, Free Software Foundation, Inc.         --
--                                                                          --
-- GNAT is free software;  you can  redistribute it  and/or modify it under --
-- terms of the  GNU General Public License as published  by the Free Soft- --
-- ware  Foundation;  either version 2,  or (at your option) any later ver- --
-- sion.  GNAT is distributed in the hope that it will be useful, but WITH- --
-- OUT ANY WARRANTY;  without even the  implied warranty of MERCHANTABILITY --
-- or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License --
-- for  more details.  You should have  received  a copy of the GNU General --
-- Public License  distributed with GNAT;  see file COPYING.  If not, write --
-- to  the  Free Software Foundation,  51  Franklin  Street,  Fifth  Floor, --
-- Boston, MA 02110-1301, USA.                                              --
--                                                                          --
-- As a special exception,  if other files  instantiate  generics from this --
-- unit, or you link  this unit with other files  to produce an executable, --
-- this  unit  does not  by itself cause  the resulting  executable  to  be --
-- covered  by the  GNU  General  Public  License.  This exception does not --
-- however invalidate  any other reasons why  the executable file  might be --
-- covered by the  GNU Public License.                                      --
--                                                                          --
-- GNAT was originally developed  by the GNAT team at  New York University. --
-- Extensive contributions were provided by Ada Core Technologies Inc.      --
--                                                                          --
------------------------------------------------------------------------------

--  Version is for AVR use when there are no exception handlers (i.e. either
--  of Restriction No_Exception_Handlers or No_Exception_Propagation is set).

package body Ada.Exceptions is

   procedure Last_Chance_Handler (Msg : System.Address; Line : Integer);
   pragma Import (C, Last_Chance_Handler, "__gnat_last_chance_handler");
   pragma No_Return (Last_Chance_Handler);

   pragma Suppress (All_Checks);
   --  We definitely do not want exceptions occurring within this unit, or
   --  we are in big trouble. If an exceptional situation does occur, better
   --  that it not be raised, since raising it can cause confusing chaos.

   procedure Set_Exception_Msg
     (Id      : Exception_Id;
      Message : String);
   --  This routine is called to setup the exception referenced by the
   --  Current_Excep field in the TSD to contain the indicated Id value
   --  and message. Message is a string which is generated as the
   --  exception message.

   procedure Set_Exception_Msg
     (Id      : Exception_Id;
      Message : String)
   is
   begin
      --  This routine is currently empty, but can be set to write a
      --  time stamp and other info to the EEPROM, for example.
      null;
   end Set_Exception_Msg;

   procedure Raise_Exception
     (E       : Exception_Id;
      Message : String := "")
   is
   begin
      Set_Exception_Msg (E, Message);
      Last_Chance_Handler (Message'Address, 0);
   end Raise_Exception;

end Ada.Exceptions;
