---------------------------------------------------------------------------
-- The AVR-Ada Library is free software;  you can redistribute it and/or --
-- modify it under terms of the  GNU General Public License as published --
-- by  the  Free Software  Foundation;  either  version 2, or  (at  your --
-- option) any later version.  The AVR-Ada Library is distributed in the --
-- hope that it will be useful, but  WITHOUT ANY WARRANTY;  without even --
-- the  implied warranty of MERCHANTABILITY or FITNESS FOR A  PARTICULAR --
-- PURPOSE. See the GNU General Public License for more details.         --
--                                                                       --
-- As a special exception, if other files instantiate generics from this --
-- unit,  or  you  link  this  unit  with  other  files  to  produce  an --
-- executable   this  unit  does  not  by  itself  cause  the  resulting --
-- executable to  be  covered by the  GNU General  Public License.  This --
-- exception does  not  however  invalidate  any  other reasons why  the --
-- executable file might be covered by the GNU Public License.           --
---------------------------------------------------------------------------

with AVR.EEprom;

package body Dataflash.Cfg is

   --  on some old AVR parts the lowest eeprom cell is buggy.  Avoid
   --  using it for real data by allocating a dummy variable first.
   Dummy : Nat16;
   pragma Linker_Section (Dummy, ".eeprom");


   --  the current page
   Page_Cfg : Page_Address;
   pragma Linker_Section (Page_Cfg, ".eeprom");


   --  the current byte address within the page
   First_Empty_Cfg : Byte_Address;
   pragma Linker_Section (First_Empty_Cfg, ".eeprom");


   procedure Store_DF_Page (P : Page_Address) is
   begin
      AVR.EEprom.Put (Page_Cfg'Address, Nat16 (P));
   end Store_DF_Page;


   function Get_DF_Page return Page_Address is
      P : Nat16;
   begin
      P := AVR.EEprom.Get (Page_Cfg'Address);
      return Page_Address (P);
   end Get_DF_Page;


   procedure Store_DF_Empty_Addr (B : Byte_Address) is
   begin
      AVR.EEprom.Put (First_Empty_Cfg'Address, Nat16 (B));
   end Store_DF_Empty_Addr;


   function Get_DF_Empty_Addr return Byte_Address is
      B : Nat16;
   begin
      B := AVR.EEprom.Get (First_Empty_Cfg'Address);
      return Byte_Address (B);
   end Get_DF_Empty_Addr;


end Dataflash.Cfg;
