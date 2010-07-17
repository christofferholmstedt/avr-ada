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


--  test body for dataflash that emulates dataflash on a PC

with Interfaces;                   use Interfaces;
with Ada.Text_IO;                  use Ada.Text_IO;
with Ada.Direct_IO;

with Strings_Edit.U8;
with Strings_Edit.U16;


package body Dataflash is

   --  keep an image of the current values in an appropriate disk file
   Disk_Image : constant Boolean := True;


   --  emulated registers and buffers
   SPDR : AVR.Byte;
   Status_Register : AVR.Byte := 0;

   type Page_Of_Bytes is array (Byte_Address) of Unsigned_8;

   RAM_Buffer : array (Buffer_Index) of Page_Of_Bytes :=
     (others => (others => 0));


   type Page_Array is array (Page_Address) of Page_Of_Bytes;

   Dataflash : Page_Array := (others => (others => 0));

   Cont_Access_Buffer : Buffer_Index := 1;
   Cont_Access_Page : Page_Address := 0;
   Cont_Access_Byte : Byte_Address := 0;



   --
   --  disk image
   --
   package Page_IO is new Ada.Direct_IO (Page_Of_Bytes);

   procedure Save_Page (P : Page_Address) is
      Img_File : Page_IO.File_Type;
      P_Str_Blank : constant String := P'Img;
      P_Str : constant String := P_Str_Blank (2 .. P_Str_Blank'Last);
      Filename : constant String := "df." & P_Str & ".img";
      use Page_IO;
   begin
      Create (Img_File, Out_File, Filename);
      Write (Img_File, Dataflash (P));
      Close (Img_File);
   end Save_Page;

   procedure Save_RAM_Buffer (B : Buffer_Index) is
      Img_File : Page_IO.File_Type;
      B_Str_Blank : constant String := B'Img;
      B_Str : constant String := B_Str_Blank (2 .. B_Str_Blank'Last);
      Filename : constant String := "ram." & B_Str & ".img";
      use Page_IO;
   begin
      Create (Img_File, Out_File, Filename);
      Write (Img_File, RAM_Buffer (B));
      Close (Img_File);
   end Save_RAM_Buffer;



   procedure CS_Active is
   begin
      null;
   end CS_Active;


   procedure CS_Inactive is
   begin
      null;
   end CS_Inactive;


   procedure DF_SPI_Init is
   begin
      null;
   end DF_SPI_Init;


   --  ***********************************************************************
   --  * Returns :       Byte read from SPI data register (any value)
   --  * Parameters :    Byte to be written to SPI data register (any value)
   --  * Purpose :       Read and writes one byte from/to SPI master
   --  ***********************************************************************
   function DF_SPI_RW (Output : Unsigned_8) return Unsigned_8 is
      Input : Unsigned_8;
   begin
      Input := SPDR;
      SPDR := Output;
      return Input;
   end DF_SPI_RW;


   procedure DF_SPI_Write (Output : Unsigned_8) is
   begin
      SPDR := Output;
   end DF_SPI_Write;


   --  ***********************************************************************
   --  * Returns :       One status byte. Consult Dataflash datasheet for
   --  *                 further decoding info
   --  * Purpose :       Status info concerning the Dataflash is busy or not.
   --  *                 Status info concerning compare between buffer and
   --  *                 flash page
   --  *                 Status info concerning size of actual device
   --  ***********************************************************************
   function Read_DF_Status return Unsigned_8 is
   begin
      return Status_Register;
   end Read_DF_Status;


   --  ************************************************************************
   --  * Parameters :    BufferNo -> Decides usage of either buffer 1 or 2
   --  *                 Page     -> Address of page to be transferred to
   --  *                             buffer
   --  * Purpose :       Transfers a page from flash to dataflash SRAM buffer
   --  ************************************************************************
   procedure Page_To_Buffer (Page : Page_Address; BufferNo : Buffer_Index) is
   begin
      RAM_Buffer (BufferNo) := Dataflash (Page);
   end Page_To_Buffer;


   --  ***********************************************************************
   --  * Returns :       One read byte (any value)
   --  * Parameters :    BufferNo   -> Decides usage of either buffer 1 or 2
   --  *                 IntPageAdr -> Internal page address
   --  * Purpose :       Reads one byte from one of the dataflash
   --  *                 internal SRAM buffers
   --  ************************************************************************
   function Buffer_Read_Byte (BufferNo   : Buffer_Index;
                              IntPageAdr : Byte_Address)
                             return Unsigned_8
   is
   begin
      return RAM_Buffer (BufferNo)(IntPageAdr);
   end Buffer_Read_Byte;


   --  ************************************************************************
   --  * Parameters :    BufferNo   -> Decides usage of either buffer 1 or 2
   --  *                 IntPageAdr -> Internal page address
   --  *                 Data       -> address of buffer to be used for read
   --  *                               bytes
   --  * Purpose :       Reads one or more bytes from one of the dataflash
   --  *                 internal SRAM buffers, and puts read bytes into
   --  *                 buffer pointed to by *BufferPtr
   --  ************************************************************************
   procedure Buffer_Read_Array (BufferNo   :        Buffer_Index;
                                IntPageAdr :        Byte_Address;
                                Data       : in out AVR.Byte_Array)
   is
      Page_Addr : Byte_Address := IntPageAdr;
   begin
      for J in Data'Range loop
         Data (J) := Buffer_Read_Byte (BufferNo, Page_Addr);
         Page_Addr := Page_Addr + 1;
      end loop;
   end Buffer_Read_Array;


   --  ************************************************************************
   --  * Parameters :    IntPageAdr -> Internal page address to start writing
   --  *                               from
   --  *                 BufferNo   -> Decides usage of either buffer 1 or 2
   --  * Purpose :       Enables continous write functionality to one of the
   --  *                 dataflash.  NOTE : User must ensure that CS goes high
   --  *                 to terminate this mode before accessing other
   --  *                 dataflash functionalities.
   --  ************************************************************************
   procedure Buffer_Write_Enable (BufferNo : Buffer_Index;
                                  IntPageAdr : Byte_Address)
   is
   begin
      Cont_Access_Buffer := BufferNo;
      Cont_Access_Byte := IntPageAdr;
   end Buffer_Write_Enable;


   --  ************************************************************************
   --  * Parameters :    IntPageAdr -> Internal page address to write byte to
   --  *                 BufferNo   -> Decides usage of either buffer 1 or 2
   --  *                 Data       -> Data byte to be written
   --  * Purpose :       Writes one byte to one of the dataflash
   --  *                 internal SRAM buffers
   --  ************************************************************************
   procedure Buffer_Write_Byte (BufferNo   : Buffer_Index;
                                IntPageAdr : Byte_Address;
                                Data       : Unsigned_8)
   is
   begin
      RAM_Buffer (BufferNo)(IntPageAdr) := Data;
   end Buffer_Write_Byte;



   --  ************************************************************************
   --  * Parameters :    BufferNo    -> Decides usage of either buffer 1 or 2
   --  *                 IntPageAdr  -> Internal page address
   --  *                 Data        -> address of buffer to be used for copy
   --  *                                of bytes from AVR buffer to dataflash
   --  *                                buffer 1 (or 2)
   --  * Purpose :       Copies one or more bytes to one of the dataflash
   --  *                 internal SRAM buffers from AVR SRAM buffer
   --  *                 pointed to by *BufferPtr
   --  ************************************************************************
   procedure Buffer_Write_Array (BufferNo   : Buffer_Index;
                                 IntPageAdr : Byte_Address;
                                 Data       : AVR.Byte_Array)
   is
   begin
      for J in Data'Range loop
         declare
            Idx : constant Byte_Address := IntPageAdr
              + Unsigned_16 (J - Data'First);
         begin
            RAM_Buffer (BufferNo) (Idx) := Data (J);
         end;
      end loop;
      if Disk_Image then
         Save_Ram_Buffer (BufferNo);
      end if;
   end Buffer_Write_Array;


   --  ************************************************************************
   --  * Parameters :    BufferNo -> Decides usage of either buffer 1 or 2
   --  *                 Page     -> Address of flash page to be programmed
   --  * Purpose :       Transfers a page from dataflash SRAM buffer to flash
   --  ************************************************************************
   procedure Buffer_To_Page (BufferNo : Buffer_Index;
                             Page     : Page_Address) is
   begin
      Dataflash (Page) := RAM_Buffer (BufferNo);
      if Disk_Image then
         Save_Page (Page);
      end if;
   end Buffer_To_Page;



   --  ************************************************************************
   --  * Parameters :    Page       -> Address of flash page where cont.read
   --  *                               starts from
   --  *                 IntPageAdr -> Internal page address where cont.read
   --  *                               starts from
   --  * Purpose :       Initiates a continuous read from a location in the
   --  *                 DataFlash
   --  ************************************************************************
   procedure Cont_Flash_Read_Enable (Page       : Page_Address;
                                     IntPageAdr : Byte_Address)
   is
   begin
      Cont_Access_Page := Page;
      Cont_Access_Byte := IntPageAdr;
   end Cont_Flash_Read_Enable;


   --
   --  Dump
   --
   procedure Dump (P : Page_Of_Bytes) is
      use Ada.Text_IO;

      Data : Unsigned_8;

      procedure Put (Data : Unsigned_8; Base : Natural := 10) is
         use Strings_Edit;
         use Strings_Edit.U8;
         Str : String (1..3);
         P   : Integer := Str'First;
      begin
         Put (Str, P, Data, Base, False, Str'Last, Right, '0');
         Ada.Text_IO.Put (Str (2 .. 3));
      end Put;

      procedure Put (Data : Unsigned_16; Base : Natural := 10) is
         use Strings_Edit;
         use Strings_Edit.U16;
         Str : String (1 .. 5);
         P   : Integer := Str'First;
      begin
         Put (Str, P, Data, Base, False, Str'Last, Right, '0');
         Ada.Text_IO.Put (Str (2 .. 5));
      end Put;

   begin
      for B in Byte_Address loop
         Data := P (B);

         if (B mod 16) = 0 then
            New_Line;
            Put (B, 16);
            Put (": ");
         end if;
         Put (Data, 16);
         Put (' ');

      end loop;
      New_Line (2);
   end Dump;


   procedure Dump_RAM_Buffer (Index : Buffer_Index) is
   begin
      Ada.Text_IO.Put_Line ("--- RAM Buffer" & Index'Img & " ---");
      Dump (RAM_Buffer (Index));
   end Dump_RAM_Buffer;


   procedure Dump_Page (Page : Page_Address) is
   begin
      Ada.Text_IO.Put_Line ("--- DF Page" & Page'Img & " ---");
      Dump (Dataflash (Page));
   end Dump_Page;

end Dataflash;
