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

--  this is the implementation on the host computer using an external
--  file as substitute for the eeprom.

with Config_Files;                use Config_Files;
pragma Elaborate_All (Config_Files);

package body Dataflash.Cfg is


   Eeprom_Cfg_File : constant String := "eeprom.cfg";

   C : Config_Files.Configuration_Type;

   function Read is new Read_Modular (Page_Address);
   function Read is new Read_Modular (Unsigned_8);
   procedure Write is new Write_Modular (Page_Address);
   procedure Write is new Write_Modular (Unsigned_8);


   procedure Store_DF_Page (P : Page_Address) is
   begin
      if not Is_Open (C) then
         Open (C, Eeprom_Cfg_File, Read_Only => False);
      end if;
      Write (C, "Page", P);
      Close (C);
   end Store_DF_Page;


   function Get_DF_Page return Page_Address is
      P : Page_Address;
   begin
      if not Is_Open (C) then
         Open (C, Eeprom_Cfg_File);
      end if;
      P := Read (C, "Page", 5);
      Close (C);
      return (P);
   end Get_DF_Page;


   procedure Store_DF_Empty_Addr (B : Unsigned_8) is
   begin
      if not Is_Open (C) then
         Open (C, Eeprom_Cfg_File, Read_Only => False);
      end if;
      Write (C, "First_Empty", B);
      Close (C);
   end Store_DF_Empty_Addr;


   function Get_DF_Empty_Addr return Unsigned_8 is
      F : Unsigned_8;
   begin
      if not Is_Open (C) then
         Open (C, Eeprom_Cfg_File);
      end if;
      F := Read (C, "First_Empty", 0);
      Close (C);
      return (F);
   end Get_DF_Empty_Addr;


end Dataflash.Cfg;
