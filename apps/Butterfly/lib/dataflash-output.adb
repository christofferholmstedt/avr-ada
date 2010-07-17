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

with AVR;                         use AVR;

with Dataflash.Cfg;
pragma Elaborate_All (Dataflash.Cfg);

with Interfaces;                   use type Interfaces.Unsigned_8;
with Debug;
with AVR.Int_Img;
with AVR.Strings;

package body Dataflash.Output is

   Debug_Init         : constant Boolean := False;
   Debug_Read         : constant Boolean := False;
   Debug_Write        : constant Boolean := False;
   Debug_Page_Switch  : constant Boolean := False;



   --   the storage space for application data is from the
   --   First_Storage_Page to the end of the dataflash.
   First_Storage_Page : constant Page_Address := 4;

   subtype Storage_Page_Address is Page_Address
     range First_Storage_Page .. Page_Address'Last;


   Data_Buffer : constant Buffer_Index := 1;
   Comm_Buffer : constant Buffer_Index := 2;
   First_Empty : Nat8                  := 0; -- we require overflow of a 8bit unsigned
   Page        : Storage_Page_Address  := First_Storage_Page;


   procedure Print_Loc is
      use Interfaces;
   begin
      Debug.Put ("First_Empty :");
      Debug.Put (Unsigned_16 (First_Empty));
      Debug.Put (", Page :");
      Debug.Put (Unsigned_16 (Page));
      Debug.New_Line;
   end Print_Loc;


   --  set up the internal data structures, get the first empty
   --  location from the configuration area
   procedure Init is
   begin
      if Debug_Init then Debug.Put ("(DF.Out.Init)"); end if;


      First_Empty := Nat8 (Cfg.Get_DF_Empty_Addr);
      Page        := Cfg.Get_DF_Page;


      if Debug_Init then Print_Loc; end if;
   end Init;


   --  reset all internal data structures.  Write procedures will
   --  overwrite all existing contents.
   procedure Reset is
   begin
      First_Empty := 0;
      Page        := First_Storage_Page;

      Cfg.Store_DF_Empty_Addr (Byte_Address (First_Empty));
      Cfg.Store_DF_Page (Page);

      if Debug_Init then
         Debug.Put ("(DF.Out.Reset) ");
         Print_Loc;
      end if;
   end Reset;


   --  flush out the internal RAM buffers to actual dataflash memory
   --  and store the current write pointers in the config area.
   procedure Flush is
   begin
      --  store the RAM buffer to the DF
      Buffer_To_Page (Data_Buffer, Page);
      Cfg.Store_DF_Empty_Addr (Byte_Address (First_Empty));
      Cfg.Store_DF_Page (Page);
   end Flush;


   procedure Complete_Page is

      procedure Debug_Out_Page is
         use Interfaces;
      begin
         Debug.Put ("Completed page #");
         Debug.Put (Unsigned_16(Page));
         Debug.New_Line;
      end Debug_Out_Page;

   begin
      if Debug_Page_Switch then
         Dump_RAM_Buffer (Data_Buffer);
         Debug_Out_Page;
      end if;

      Buffer_To_Page (Data_Buffer, Page);
      -- increment the address pointers
      First_Empty := 0;
      Page := Page + 1;
      -- store the new address in eeprom
      Cfg.Store_DF_Empty_Addr (Byte_Address (First_Empty));
      Cfg.Store_DF_Page (Page);

   end Complete_Page;


   Arbitrary_Max_Len : constant := 20;
   subtype Data_Index is Nat8 range 1 .. Arbitrary_Max_Len;
   subtype Constrained_Byte_Array is AVR.Nat8_Array (Data_Index);
   Static_W_Data : Constrained_Byte_Array;
   Static_R_Data : Constrained_Byte_Array;

   procedure Debug_Out_Static_Data (Len : Data_Index; Is_Write_Data : Boolean)
   is
      use Debug;
      use AVR.Int_Img;
      use AVR.Strings;
      Img : AStr2;
   begin
      Put ("Static_");
      if Is_Write_Data then Put ('W'); else Put ('R'); end if;
      Put ("_Data=");

      for I in 1 .. Len loop
         if Is_Write_Data then
            U8_Hex_Img (Static_W_Data (I), Img);
         else
            U8_Hex_Img (Static_R_Data (I), Img);
         end if;
         Put (' ');
         Put (Img);
      end loop;
      New_Line;
   end Debug_Out_Static_Data;


   procedure Write (Len : Data_Index)
   is
      R : Nat8  := Len; -- remaining elements in Item to be stored
      F : Nat8  := 1;   -- index of the first element in Item
      L : Nat8;         -- index of the last element

      --  we make heavy use of the overflow semantics of unsigned
      --  types.  The variable First_Empty points to the first empty
      --  cell in the page. -First_Empty is essentially (256 -
      --  First_Empty), i.e. it gives the remaining space in the page.
   begin
      --  if the object is bigger (R) than the remaining space in this
      --  page, first fill in the available space in the old page
      if First_Empty /= 0 and then R > (- First_Empty) then
         L := F - First_Empty - 1;

         for I in F .. L loop
            Buffer_Write_Byte (Data_Buffer,
                               Byte_Address (First_Empty + I - F),
                               Data => Static_W_Data (I));
         end loop;

         R := R + First_Empty;
         F := F - First_Empty;
         -- switch page
         Complete_Page;
      end if;

      if R > 0 then
         L := F + R - 1;

         for I in F .. L loop
            Buffer_Write_Byte (Data_Buffer,
                               Byte_Address (First_Empty + I - F),
                               Data => Static_W_Data (I));
--              declare
--                 Img : AVR.Strings.AStr2;
--              begin
--                 Debug.Put (" DF_Out @=");
--                 AVR.Int_Img.U8_Hex_Img (Unsigned_8 (First_Empty+I-F), Img);
--                 Debug.Put (Img);
--                 Debug.Put ("data=");
--                 AVR.Int_Img.U8_Hex_Img (Static_W_Data (I), Img);
--                 Debug.Put (' ');
--                 Debug.Put AVR.Strings(Img);
--              end;
         end loop;


         if First_Empty > Nat8'Last - R then
            Complete_Page;
         else
            First_Empty := First_Empty + R;
         end if;
      end if;

      if Debug_Write then
         Flush;
         Print_Loc;
      end if;
   end Write;


   procedure Generic_Write (Item : Element_Type) is

      Len : constant Nat8 := Element_Type'Object_Size / 8;
      D   : Nat8_Array (1 .. Len);
      for D'Address use Item'Address;
      --  treat the Item as a Byte_Array.
   begin
      Static_W_Data (1 .. Len) := D;

      if Debug_Write then Debug_Out_Static_Data (Len, True); end if;

      Write (Len);

   end Generic_Write;

--     procedure Generic_Write (Item : Element_Type) is

--        Len : constant Unsigned_8 := Element_Type'Object_Size / 8;
--        D   : Byte_Array (1 .. Len);
--        for D'Address use Item'Address;
--        --  treat the Item as a Byte_Array.

--        R : Unsigned_8  := Len; -- remaining elements in Item to be stored
--        F : Unsigned_8  := 1;   -- index of the first element in Item
--        L : Unsigned_8;         -- index of the last element

--        --  we make heavy use of the overflow semantic of unsigned
--        --  types.  The variable First_Empty points to the first empty
--        --  cell in the page. -First_Empty is essentially (256 -
--        --  First_Empty), i.e. it gives the remaining space in the page.
--     begin
--  --        Debug.Put ("(DF.Out.Write) ");
--  --        Print_Loc;
--  --        Debug.Put ("Avail :");
--  --        Debug.Put (-First_Empty);
--  --        Debug.Put (", Item remain :");
--  --        Debug.Put (R);
--  --        Debug.New_Line;

--        --  if the object is bigger (R) than the remaining space in this
--        --  page, first fill in the available space in the old page
--        if (First_Empty /= 0) and (R > - First_Empty) then
--           L := F - First_Empty - 1;

--  --           Debug.Put ("(r>a) first:"); Debug.Put (F);
--  --           Debug.Put (" last:");       Debug.Put (L);
--  --           Debug.New_Line;

--           --Buffer_Write_Array (Data_Buffer,
--           --                    Unsigned_16 (First_Empty),
--           --                    D (F .. L));
--           for I in F .. L loop
--              Buffer_Write_Byte (Data_Buffer,
--                                 Unsigned_16 (First_Empty + I - F),
--                                 Data => D (I));
--           end loop;

--           R := R + First_Empty;
--           F := F - First_Empty;
--           -- switch page
--           Complete_Page;
--        end if;

--        --  write the remaining part into the new page
--  --        Debug.Put (" avail :");
--  --        Debug.Put (-First_Empty);
--  --        Debug.Put (" remain :");
--  --        Debug.Put (R);
--  --        Debug.Put (" first : ");
--  --        Debug.Put (F);
--  --        Debug.New_Line;

--        if R > 0  then
--           L := F + R - 1;

--           -- Buffer_Write_Array (Data_Buffer,
--           -- Unsigned_16 (First_Empty),
--           --                     D (F .. L));

--           for I in F .. L loop
--              Buffer_Write_Byte (Data_Buffer,
--                                 Unsigned_16 (First_Empty),
--                                 Data => D (I));
--           end loop;


--           if First_Empty > Unsigned_8'Last - R then
--              Complete_Page;
--           else
--              First_Empty := First_Empty + R;
--           end if;
--        end if;
--  --        Debug.Put ("wrote ");
--  --        Debug.Put (L-F+1);
--  --        Debug.Put (" bytes to DF");
--  --        Debug.New_Line;
--     end Generic_Write;


   procedure Read (Len : Nat8) is
   begin
      for I in 1 .. Len loop
         Static_R_Data (I) := 0;
      end loop;
   end Read;


   procedure Generic_Read (Item : in out Element_Type)
   is
      Len : constant Nat8 := Element_Type'Object_Size / 8;
      D   : Nat8_Array (1 .. Len);
      for D'Address use Item'Address;
      --  treat the Item as a Byte_Array.
   begin
      Read (Len);
      D := Static_R_Data (1 .. Len);

      if Debug_Read then Debug_Out_Static_Data (Len, False); end if;
   end Generic_Read;


   procedure Start_Download
   is
   begin
      -- Start_Download (First_Storage_Page, Page);
      Start_Download (First_Storage_Page, Page_Address'Last);
      null;
   end Start_Download;


   --  write contents of pages to the debug channel (i.e. uart)
   procedure Start_Download (From : Page_Address;
                             To   : Page_Address)
   is
      use Debug;
      use Interfaces;
   begin
      for P in From .. To loop
         Put ("--- DF Page ");
         Put (Unsigned_16 (P));
         Put (" ---");
         New_Line;

         Page_To_Buffer (P, Comm_Buffer);
         Dump_RAM_Buffer (Comm_Buffer);
      end loop;

   end Start_Download;


      --  debug routines
   procedure Dump_RAM_Buffer (Index : Buffer_Index) is
      use Debug;
      use Interfaces;
      Data        : Nat8;
      B_Mod_8     : Nat8;
      Text        : AVR.Strings.AStr8;
      Unprintable : constant Character := '.';
   begin
      Put ("--- Dump_RAM_Buffer #");
      Put (Unsigned_8 (Index));
      New_Line;
      for B in Byte_Address loop
         Data := Buffer_Read_Byte (BufferNo => Index, IntPageAdr => B);
         B_Mod_8 := Nat8 (B mod 8);
         if B_Mod_8 = 0 then
            Put (Unsigned_16(B), 16);
            Put (": ");
         end if;

         Put (Unsigned_8 (Data), 16);
         Put (' ');

         if Data >= 32 and then Data <= 126 then
            Text (B_Mod_8 + 1) := Character'Val (Data);
         else
            Text (B_Mod_8 + 1) := Unprintable;
         end if;

         if B_Mod_8 = 7 then
            Put ('"');
            Put (Text);
            Put ('"');
            New_Line;
         end if;
      end loop;
      New_Line;
      null;
   end Dump_RAM_Buffer;


   --  debug routines
   procedure Display_RAM_Buffer (Index : Buffer_Index) is
      use Debug;
      Data : Nat8;
   begin
      Put ("--- Display_RAM_Buffer # ");
      Put (Interfaces.Unsigned_8 (Index));
      New_Line;
      for B in Byte_Address loop
         Data := Buffer_Read_Byte (BufferNo => Index, IntPageAdr => B);
         Put (Character'Val (Data));
      end loop;
      New_Line;
   end Display_RAM_Buffer;


--  begin
--     Init;
end Dataflash.Output;
