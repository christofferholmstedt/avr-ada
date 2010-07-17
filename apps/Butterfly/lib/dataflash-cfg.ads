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


--  this package contains generic access routines for reading and
--  writing configuration parameters.  It is preinstantiated for the
--  dataflash management itself that are stored in either the eeprom
--  or in configuration pages of the dataflash memory.

package Dataflash.Cfg is


   --  the current page and first empty address within that page.
   procedure Store_DF_Page (P : Page_Address);
   function Get_DF_Page return Page_Address;

   procedure Store_DF_Empty_Addr (B : Byte_Address);
   function Get_DF_Empty_Addr return Byte_Address;

private

   pragma Inline (Store_DF_Page);
   pragma Inline (Get_DF_Page);
   pragma Inline (Store_DF_Empty_Addr);
   pragma Inline (Get_DF_Empty_Addr);

end Dataflash.Cfg;
