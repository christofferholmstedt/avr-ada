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

--  read and write the on-chip EEprom.

with System;
with AVR.MCU;

package AVR.EEprom is
   pragma Preelaborate;


   --  indicate, if EEprom is ready for a new read/write operation
   function Is_Ready return Boolean;
   --  ??? is it necessary to make this public?


   --  loops until EEprom is no longer busy
   procedure Busy_Wait;
   --  ??? is it necessary to make this public?


   subtype EEprom_Address is System.Address
     range 0 .. AVR.MCU.E2end;


   --  read a value from the specified address
   function Get (Address : EEprom_Address) return Unsigned_8;
   function Get (Address : EEprom_Address) return Unsigned_16;
   procedure Get (Address : EEprom_Address; Data : out Nat8_Array);

   --  store a value at the address
   procedure Put (Address : EEprom_Address; Data : Unsigned_8);
   procedure Put (Address : EEprom_Address; Data : Unsigned_16);
   procedure Put (Address : EEprom_Address; Data : Nat8_Array);

private
   --  dirty hack to force 8-bit EEprom_address if E2end fits in 8 bit
   --   Ee_Addr_Size : constant := Boolean'Pos (not MCU.EEprom_8bit_Addr) * 8 + 8;
   --   for EEprom_Address'Size use Ee_Addr_Size;
   --  does only work if EEprom_Address is separate type, not a subtype

   pragma Inline (Is_Ready);
   pragma Inline (Busy_Wait);

end AVR.EEprom;
