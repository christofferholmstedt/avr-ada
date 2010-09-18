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

--  for now this is a simple minded implementation of the Put and Get
--  routines that transport a Word or an array.  See Atmel note AVR100
--  for explanation and sample assembler routines for accessing the
--  internal EEPROMs.


with System;                       use System;
with AVR.Interrupts;
with AVR.MCU;

use AVR;

package body AVR.EEprom is


#if Eeprom_WE = "eeprom_we" then
   EE_Master_Write_Enable : Boolean renames MCU.EECR_Bits (MCU.EEMWE_Bit);
   EE_Write_Enable        : Boolean renames MCU.EECR_Bits (MCU.EEWE_Bit);
#else
   EE_Master_Write_Enable : Boolean renames MCU.EECR_Bits (MCU.EEMPE_Bit);
   EE_Write_Enable        : Boolean renames MCU.EECR_Bits (MCU.EEPE_Bit);
#end if;
   EE_Read_Enable         : Boolean renames MCU.EECR_Bits (MCU.EERE_Bit);


   function Is_Ready return Boolean is
   begin
      return (EE_Write_Enable = Low);
   end Is_Ready;


   procedure Busy_Wait is
   begin
      while not Is_Ready loop
         null;
      end loop;
   end Busy_Wait;


   procedure Put (Address : EEprom_Address; Data : Unsigned_8) is
      use AVR.MCU;
   begin
      while not Is_Ready loop null; end loop;

#if Eeprom_Width = "eeprom_16bit" then
      EEARH := High_Byte (Unsigned_16 (Address));
      EEARL := Low_Byte  (Unsigned_16 (Address));
#else
      EEAR  := Unsigned_8 (Address);
#end if;

      EEDR := Data;
      -- no ints between setting EEMWE and EEWE
      AVR.Interrupts.Save_Disable;
      EE_Master_Write_Enable := True;
      EE_Write_Enable := True;
      AVR.Interrupts.Restore;
   end Put;


   procedure Put (Address : EEprom_Address; Data : Unsigned_16) is
   begin
      Put (Address,     AVR.Low_Byte (Data));
      Put (Address + 1, AVR.High_Byte (Data));
   end Put;


   procedure Put (Address : EEprom_Address; Data : Nat8_Array) is
      Local : EEprom_Address := Address;
   begin
      for J in Data'Range loop
         Put (Local, Data (J));
         Local := Local + 1;
      end loop;
   end Put;


   function Get (Address : EEprom_Address) return Unsigned_8 is
      use AVR.MCU;
   begin
      Busy_Wait;
#if Eeprom_Width = "eeprom_16bit" then
      EEARH := High_Byte (Unsigned_16 (Address));
      EEARL := Low_Byte  (Unsigned_16 (Address));
#else
      EEAR  := Unsigned_8 (Address);
#end if;

      EE_Read_Enable := True;
      return EEDR;
   end Get;


   function Get (Address : EEprom_Address) return Unsigned_16 is
      Low  : Unsigned_8;
      High : Unsigned_8;
   begin
      Low  := Get (Address);
      High := Get (Address+1);
      return Unsigned_16 (High) * 256 + Unsigned_16 (Low);
   end Get;


   procedure Get (Address : EEprom_Address; Data : out Nat8_Array) is
      Local : EEprom_Address := Address;
   begin
      for I in Data'Range loop
         Data (I) := Get (Local);
         Local := Local + 1;
      end loop;
   end Get;

end AVR.EEprom;

-- Local Variables:
-- mode:ada
-- End:
