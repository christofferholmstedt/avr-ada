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

--  provide generic write procedures for continouos writing to the
--  data area of the dataflash memory.

package Dataflash.Output is
   --   pragma Preelaborate (Output);

   --  set up the internal data structures, get the first empty
   --  location from the configuration area
   procedure Init;

   --  reset all internal data structures.  Consecutive calls to Write
   --  will overwrite the existing contents.
   procedure Reset;

   --  flush out the internal RAM buffers to actual dataflash memory
   --  and store the current write pointers in the config area.
   procedure Flush;


   generic
      type Element_Type is private;
   procedure Generic_Write (Item : Element_Type);

   generic
      type Element_Type is private;
   procedure Generic_Read (Item : in out Element_Type);


   --  write contents of pages to the debug channel (i.e. uart)
   procedure Start_Download;
   procedure Start_Download (From : Page_Address; To : Page_Address);


   --  debug routines
   procedure Dump_RAM_Buffer (Index : Buffer_Index);
   procedure Display_RAM_Buffer (Index : Buffer_Index);

end Dataflash.Output;
