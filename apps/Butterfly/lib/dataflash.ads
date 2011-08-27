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

--  This file is a re-write in Ada of the information contained in
--  dataflash.h as distributed by ATMEL, therefor their copyright
--  notice.

--*****************************************************************************
--
--      COPYRIGHT (c) ATMEL Norway, 1996-2001
--
--      The copyright to the document(s) herein is the property of
--      ATMEL Norway, Norway.
--
--      The document(s) may be used  and/or copied only with the written
--      permission from ATMEL Norway or in accordance with the terms and
--      conditions stipulated in the agreement/contract under which the
--      document(s) have been supplied.
--
--*****************************************************************************
--
--  File........: DATAFLASH.H
--
--  Author(s)...: ATMEL Norway
--
--  Target(s)...: Independent
--
--  Description.: Defines and prototypes for AT45Dxxx
--
--  Revisions...:
--
--  YYYYMMDD - VER. - COMMENT                                       - SIGN.
--
--  20010117 - 0.10 - Generated file                                -  RM
--
--*****************************************************************************

with AVR;                          use AVR;

package Dataflash is
   --  pragma Preelaborate (Dataflash);

   --  The butterfly has a AT45DB041B with 512kB
   Page_Bits : constant := 9;
   Page_Size : constant := 264;


   --  the AT45DB041B dataflash has 2048 pages of 264 bytes each
   type Page_Address is range 0 .. 2047;
   for Page_Address'Size use 16;

   --  one page consists of 264 bytes (2**8 + 8)
   type Byte_Address is range 0 .. Page_Size - 1;
   for Byte_Address'Size use 16;

   --  select between the two RAM buffers
   type Buffer_Index is range 1 .. 2;
   for Buffer_Index'Size use 8;


   --  Dataflash opcodes
   package Commands is
      FlashPageRead       : constant := 16#52#; -- Main memory page read
      FlashToBuf1Transfer : constant := 16#53#; -- Main memory page to buffer 1
                                                --  transfer
      Buf1Read            : constant := 16#54#; -- Buffer 1 read
      FlashToBuf2Transfer : constant := 16#55#; -- Main memory page to buffer 2
                                                --  transfer
      Buf2Read            : constant := 16#56#; -- Buffer 2 read
      StatusReg           : constant := 16#57#; -- Status register
      AutoPageReWrBuf1    : constant := 16#58#; -- Auto page rewrite through
                                                --  buffer 1
      AutoPageReWrBuf2    : constant := 16#59#; -- Auto page rewrite through
                                                --  buffer 2
      FlashToBuf1Compare  : constant := 16#60#; -- Main memory page to buffer 1
                                                --  compare
      FlashToBuf2Compare  : constant := 16#61#; -- Main memory page to buffer 2
                                                --  compare
      ContArrayRead       : constant := 16#68#; -- Continuous Array Read
                                                --  (Only A/B-parts supported)
      FlashProgBuf1       : constant := 16#82#; -- Main memory page program
                                                --  through buffer 1
      Buf1ToFlashWE       : constant := 16#83#; -- Buffer 1 to main memory page
                                                --  program with built-in erase
      Buf1Write           : constant := 16#84#; -- Buffer 1 write
      FlashProgBuf2       : constant := 16#85#; -- Main memory page program
                                                --  through buffer 2
      Buf2ToFlashWE       : constant := 16#86#; -- Buffer 2 to main memory page
                                                --  program with built-in erase
      Buf2Write           : constant := 16#87#; -- Buffer 2 write
      Buf1ToFlash         : constant := 16#88#; -- Buffer 1 to main memory page
                                                --  program without built-in erase
      Buf2ToFlash         : constant := 16#89#; -- Buffer 2 to main memory page
                                                --  program without built-in erase
   end Commands;


   --  procedure CS_Active;
   --  pragma Inline (CS_Active);
   --  procedure CS_Inactive;
   --  pragma Inline (CS_Inactive);


   --  --  Set up the HW SPI in Master mode, Mode 3.
   --  --  Note -> Uses the SS line to control the DF CS-line.
   --  procedure DF_SPI_Init;

   --  --  Read and write one byte from/to SPI master
   --  function DF_SPI_RW (Output : Nat8) return Nat8;

   --  --  Write one byte from SPI master
   --  procedure DF_SPI_Write (Output : Nat8);
   --  pragma Inline (DF_SPI_Write);

   --  Status info concerning the Dataflash is busy or not.
   --  Status info concerning compare between buffer and flash page.
   function Read_DF_Status return Nat8;

   --  Transfers a page from flash to dataflash SRAM buffer
   procedure Page_To_Buffer (Page     : Page_Address;
                             BufferNo : Buffer_Index);

   --  Reads one byte from one of the dataflash internal SRAM buffers
   function Buffer_Read_Byte (BufferNo   : Buffer_Index;
                              IntPageAdr : Byte_Address)
                             return Nat8;

   --  Reads bytes from one of the internal SRAM buffers,
   --  and puts read bytes into buffer Data.
   procedure Buffer_Read_Array (BufferNo   :        Buffer_Index;
                                IntPageAdr :        Byte_Address;
                                Data       : in out AVR.Nat8_Array);

   --  Reads bytes directly from a flash page starting at Offset
   --  bypassing the internal SRAM buffers, and puts read bytes into
   --  buffer Data.
   procedure Memory_Read_Array (Page   :     Page_Address;
                                Offset :     Byte_Address;
                                Data   : out AVR.Nat8_Array);

   --  Enables continous write functionality to one of the dataflash.
   --  NOTE : User must ensure that CS goes high to terminate this
   --  mode before accessing other dataflash functionalities.
   procedure Buffer_Write_Enable (BufferNo   : Buffer_Index;
                                  IntPageAdr : Byte_Address);

   --  Writes one byte to one of the dataflash internal SRAM buffers.
   procedure Buffer_Write_Byte (BufferNo   : Buffer_Index;
                                IntPageAdr : Byte_Address;
                                Data       : Nat8);

   --  Copies the bytes from array Data to one of the dataflash
   --  internal SRAM buffers.
   procedure Buffer_Write_Array (BufferNo   : Buffer_Index;
                                 IntPageAdr : Byte_Address;
                                 Data       : AVR.Nat8_Array);

   --  Transfers a page from dataflash SRAM buffer to flash.
   procedure Buffer_To_Page (BufferNo : Buffer_Index;
                             Page     : Page_Address);

   --  Initiates a continuous read from a location in the DataFlash.
   procedure Cont_Flash_Read_Enable (Page       : Page_Address;
                                     IntPageAdr : Byte_Address);

end Dataflash;
