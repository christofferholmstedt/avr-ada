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

--
--  copyright notice of the C implementation file that provided good
--  input for the Ada implementation
--
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
--  File........: DATAFLASH.C
--
--  Author(s)...: ATMEL Norway
--
--  Target(s)...: All AVRs with built-in HW SPI
--
--  Description.: Functions to access the Atmel AT45Dxxx dataflash series
--                Supports 512Kbit - 64Mbit
--
--  Revisions...:
--
--  YYYYMMDD - VER. - COMMENT                                       - SIGN.
--
--  20011017 - 1.00 - Beta release                                  -  RM
--  20011017 - 0.10 - Generated file                                -  RM
--
--*****************************************************************************

with Interfaces;                   use type Interfaces.Unsigned_8;
with AVR;                          use AVR;
with AVR.MCU;
with AVR.SPI;
with AVR.SPI.Master;
-- with Debug;
-- with AVR.Strings;
-- with AVR.Int_Img;

package body Dataflash is


   procedure CS_Active;
   pragma Inline (CS_Active);
   procedure CS_Inactive;
   pragma Inline (CS_Inactive);


   --  Set up the HW SPI in Master mode, Mode 3.
   --  Note -> Uses the SS line to control the DF CS-line.
   procedure DF_SPI_Init;

   --  Read and write one byte from/to SPI master
   function DF_SPI_RW (Output : Nat8) return Nat8
     renames SPI.Master.Read_Write;

   --  Write one byte from SPI master
   procedure DF_SPI_Write (Output : Nat8)
     renames SPI.Master.Write;


   --
   --  pin equivalence atmega169
   --
   --  B.0 = /SS
   --  B.1 = SCK
   --  B.2 = MOSI
   --  B.3 = MISO

--     procedure Debug_Out (B : Nat8) is
--        use Debug;
--        use AVR.Int_Img;
--        Img : AVR.Strings.AStr2;
--     begin
--        U8_Hex_Img (B, Img);
--        Put ("§=");
--        Put (Img);
--     end;

   USE_BUFFER2 : constant Boolean := True;


   procedure CS_Active is
   begin
      MCU.PORTB_Bits (0) := Low;
   end CS_Active;


   procedure CS_Inactive is
   begin
      MCU.PORTB_Bits (0) := High;
   end CS_Inactive;


   function Shift_Left   (Value : Page_Address; Amount : Natural) return Page_Address;
   function Shift_Right  (Value : Page_Address; Amount : Natural) return Page_Address;
   -- function Shift_Left   (Value : Byte_Address; Amount : Natural) return Byte_Address;
   function Shift_Right  (Value : Byte_Address; Amount : Natural) return Byte_Address;
   pragma Import (Intrinsic, Shift_Left);
   pragma Import (Intrinsic, Shift_Right);


   --  ***********************************************************************
   --  *
   --  * Purpose :       Sets up the HW SPI in Master mode, Mode 3
   --  *                 Note -> Uses the SS line to control the DF CS-line.
   --  *
   --  ***********************************************************************
   procedure DF_SPI_Init is
   begin
      --  PORTB |= (1<<PORTB3) | (1<<PORTB2) | (1<<PORTB1) | (1<<PORTB0);
      MCU.PORTB := MCU.PORTB or 16#0F#;

      --  Set MOSI, SCK AND SS as outputs
      --  DDRB |= (1<<PORTB2) | (1<<PORTB1) | (1<<PORTB0);
      MCU.DDRB := MCU.DDRB or 16#07#;
      MCU.DDRB_Bits := MCU.DDRB_Bits or (MOSI => DD_Output,
                                         SCK  => DD_Output,
                                         SS   => DD_Output,
                                         others => False);

      --  SPI double speed settings
      --  SPSR = (1<<SPI2X);
      MCU.SPSR := MCU.SPI2X_Mask;

      --  Enable SPI in Master mode, mode 3, Fosc/2
      --  SPCR = (1<<SPE) | (1<<MSTR) | (1<<CPHA) | (1<<CPOL);
      MCU.SPCR := MCU.SPE_Mask or MCU.MSTR_Mask or MCU.CPHA_Mask or MCU.CPOL_Mask;

      --  Enable SPI in Master mode, mode 3, Fosc/2
      --  SPCR = (1<<SPE) | (1<<MSTR) | (1<<CPHA) | (1<<CPOL)
      --         | (1<<SPR1) | (1<<SPR0);
      SPI.Startup
        (Clock_Divisor => SPI.By_2;
         Clock_Mode    => SPI.Setup_Rising_Sample_Falling;
         Use_SS_Pin    => True);

   end DF_SPI_Init;


   --  **********************************************************************
   --  *
   --  * Returns :       Byte read from SPI data register (any value)
   --  *
   --  * Parameters :    Byte to be written to SPI data register (any value)
   --  *
   --  * Purpose :       Read and writes one byte from/to SPI master
   --  *
   --  ***********************************************************************
   --  function DF_SPI_RW (Output : Nat8) return Nat8 is
   --     Input : Nat8;
   --  begin
   --     --  put byte 'output' in SPI data register
   --     MCU.SPDR := Output;

   --     --  wait for transfer complete, poll SPIF-flag
   --     while (MCU.SPSR and 16#80#) = 0 loop null; end loop;

   --     --  read value in SPI data reg.
   --     Input := MCU.SPDR;

   --     --  return the byte clocked in from SPI slave
   --     return Input;
   --  end DF_SPI_RW;

   --  procedure DF_SPI_Write (Output : Nat8) is
   --     Dummy : Nat8;
   --  begin
   --     Dummy := DF_SPI_RW (Output);
   --  end DF_SPI_Write;



   --  ***********************************************************************
   --  *
   --  * Returns :       One status byte. Consult Dataflash datasheet for
   --  *                 further decoding info
   --  *
   --  * Purpose :       Status info concerning the Dataflash is busy or not.
   --  *                 Status info concerning compare between buffer and
   --  *                 flash page
   --  *                 Status info concerning size of actual device
   --  *
   --  ***********************************************************************
   function Read_DF_Status return Nat8 is
      Result : Nat8;
   begin
      --  make sure to toggle CS signal in order to reset dataflash command
      --  decoder
      CS_Inactive;
      CS_Active;

      --  send status register read op-code
      DF_SPI_Write (Commands.StatusReg);
      --  dummy write to get result
      Result := DF_SPI_RW (0);

      --  get the size info from status register (for use as index add lower
      --  bound in Ada)
      -- Index_Copy := Shift_Right (Result and 16#38#, 3) + 1;

      --  get number of internal page address bits from look-up table
      -- Page_Bits   := DF_Pagebits (Index_Copy);
      --  get the size of the page (in bytes)
      -- Page_Size   := DF_Pagesize (Index_Copy);
      --  return the read status register value
      return Result;
   end Read_DF_Status;


   --  ************************************************************************
   --  *
   --  * Parameters :    BufferNo -> Decides usage of either buffer 1 or 2
   --  *                 PageAdr  -> Address of page to be transferred to
   --  *                             buffer
   --  *
   --  * Purpose :       Transfers a page from flash to dataflash SRAM buffer
   --  *
   --  ************************************************************************
   procedure Page_To_Buffer (Page : Page_Address; BufferNo : Buffer_Index) is
   begin
      --  make sure to toggle CS signal in order to reset dataflash command
      --  decoder
      CS_Inactive;
      CS_Active;

      if 1 = BufferNo then
         --  transfer flash page to buffer 1
         DF_SPI_Write (Commands.FlashToBuf1Transfer);
      elsif USE_BUFFER2 and then 2 = BufferNo then
         --  transfer flash page to buffer 2
         DF_SPI_Write (Commands.FlashToBuf2Transfer);
      else
         return;
      end if;

      --  upper part of page address
      DF_SPI_Write (Nat8 (Shift_Right (Page, 16 - Page_Bits)));
      --  lower part of page address
      DF_SPI_Write (Nat8 (Shift_Left (Page, Page_Bits - 8)));
      --  don't cares
      DF_SPI_Write (0);

      --  initiate the transfer
      CS_Inactive;
      CS_Active;

      --  monitor the status register, wait until busy-flag is high
      while (Read_DF_Status and 16#80#) = 0 loop null; end loop;
   end Page_To_Buffer;



   --  ***********************************************************************
   --  *
   --  * Returns :       One read byte (any value)
   --  *
   --  * Parameters :    BufferNo   -> Decides usage of either buffer 1 or 2
   --  *                 IntPageAdr -> Internal page address
   --  *
   --  * Purpose :       Reads one byte from one of the dataflash
   --  *                 internal SRAM buffers
   --  *
   --  ************************************************************************
   function Buffer_Read_Byte (BufferNo   : Buffer_Index;
                              IntPageAdr : Byte_Address)
                             return Nat8
   is
      Data : Nat8;
   begin
      --  make sure to toggle CS signal in order to reset dataflash command
      --  decoder
      CS_Inactive;
      CS_Active;

      if 1 = BufferNo then
         --  read byte from buffer 1
         --  buffer 1 read op-code
         DF_SPI_Write (Commands.Buf1Read);

      elsif USE_BUFFER2 and then 2 = BufferNo then
            --  read byte from buffer 2
            --  buffer 2 read op-code
         DF_SPI_Write (Commands.Buf2Read);
      else
         return 0;
      end if;

      --  don't cares
      DF_SPI_Write (0);
      --  upper part of internal buffer address
      DF_SPI_Write (Nat8 (Shift_Right (IntPageAdr, 8)));
      --  lower part of internal buffer address
      DF_SPI_Write (Nat8 (IntPageAdr));
      --  don't cares
      DF_SPI_Write (0);
      --  read byte
      Data := DF_SPI_RW (0);

      --  return the read data byte
      return Data;
   end Buffer_Read_Byte;


   --  Reads bytes directly from a flash page starting at Offset
   --  bypassing the internal SRAM buffers, and puts read bytes into
   --  buffer Data.
   procedure Memory_Read_Array (Page   :     Page_Address;
                                Offset :     Byte_Address;
                                Data   : out AVR.Nat8_Array)
   is
   begin
      --  make sure to toggle CS signal in order to reset dataflash command
      --  decoder
      CS_Inactive;
      CS_Active;

      null;
   end Memory_Read_Array;



   --  ************************************************************************
   --  *
   --  * Parameters :    BufferNo    -> Decides usage of either buffer 1 or 2
   --  *                 IntPageAdr  -> Internal page address
   --  *                 No_of_bytes -> Number of bytes to be read
   --  *                 *BufferPtr  -> address of buffer to be used for read
   --  *                                bytes
   --  *
   --  * Purpose :       Reads one or more bytes from one of the dataflash
   --  *                 internal SRAM buffers, and puts read bytes into
   --  *                 buffer pointed to by *BufferPtr
   --  *
   --  ************************************************************************
   procedure Buffer_Read_Array (BufferNo   :        Buffer_Index;
                                IntPageAdr :        Byte_Address;
                                Data       : in out AVR.Nat8_Array)
   is
   begin
      --  make sure to toggle CS signal in order to reset dataflash command
      --  decoder
      CS_Inactive;
      CS_Active;

      if 1 = BufferNo then
         --  read byte(s) from buffer 1
         --  buffer 1 read op-code
         DF_SPI_Write (Commands.Buf1Read);
      elsif USE_BUFFER2 and then 2 = BufferNo then
         --  read byte(s) from buffer 2
         --  buffer 2 read op-code
         DF_SPI_Write (Commands.Buf2Read);
      else
         return;
      end if;

      --  don't cares
      DF_SPI_Write (0);
      --  upper part of internal buffer address
      DF_SPI_Write (Nat8 (Shift_Right (IntPageAdr, 8)));
      --  lower part of internal buffer address
      DF_SPI_Write (Nat8 (IntPageAdr));
      --  don't cares
      DF_SPI_Write (0);

      for I in Data'Range loop
         --  read byte and put it in buffer Data
         Data (I) := DF_SPI_RW (0);
      end loop;

   end Buffer_Read_Array;
   --  NB : Sjekk at (IntAdr + No_of_bytes) < buffersize, hvis ikke blir
   --  det bare ball..



   --  ************************************************************************
   --  *
   --  * Parameters :    IntPageAdr -> Internal page address to start writing
   --  *                               from
   --  *                 BufferAdr  -> Decides usage of either buffer 1 or 2
   --  *
   --  * Purpose :       Enables continous write functionality to one of the
   --  *                 dataflash.  NOTE : User must ensure that CS goes high
   --  *                 to terminate this mode before accessing other
   --  *                 dataflash functionalities.
   --  *
   --  ************************************************************************
   procedure Buffer_Write_Enable (BufferNo : Buffer_Index;
                                  IntPageAdr : Byte_Address)
   is
   begin
      --  make sure to toggle CS signal in order to reset dataflash command
      --  decoder
      CS_Inactive;
      CS_Active;

      if 1 = BufferNo then
         --  write enable to buffer 1
         DF_SPI_Write (Commands.Buf1Write);

      elsif USE_BUFFER2 and then 2 = BufferNo then
         --  write enable to buffer 2
         DF_SPI_Write (Commands.Buf2Write);

      else
         return;
      end if;

      --  don't cares
      DF_SPI_Write (0);
      --  upper part of internal buffer address
      DF_SPI_Write (Nat8 (Shift_Right (IntPageAdr, 8)));
      --  lower part of internal buffer address
      DF_SPI_Write (Nat8 (IntPageAdr));

   end Buffer_Write_Enable;




   --  ************************************************************************
   --  *
   --  * Parameters :    IntPageAdr -> Internal page address to write byte to
   --  *                 BufferAdr  -> Decides usage of either buffer 1 or 2
   --  *                 Data       -> Data byte to be written
   --  *
   --  * Purpose :       Writes one byte to one of the dataflash
   --  *                 internal SRAM buffers
   --  *
   --  ************************************************************************
   procedure Buffer_Write_Byte (BufferNo   : Buffer_Index;
                                IntPageAdr : Byte_Address;
                                Data       : Nat8)
   is
   begin
      --  make sure to toggle CS signal in order to reset dataflash
      --  command decoder
      CS_Inactive;
      CS_Active;

      if 1 = BufferNo then
         --  write byte to buffer 1
         DF_SPI_Write (Commands.Buf1Write);

      elsif USE_BUFFER2 and then 2 = BufferNo then
         --  write byte to buffer 2

         DF_SPI_Write (Commands.Buf2Write);
      else
         return;
      end if;

      --  don't cares
      DF_SPI_Write (0);
      --  upper part of internal buffer address
      DF_SPI_Write (Nat8 (Shift_Right (IntPageAdr, 8)));
      --  lower part of internal buffer address
      DF_SPI_Write (Nat8 (IntPageAdr));
      --  write data byte
--      Debug_Out (Data);
      DF_SPI_Write (Data);

--        Debug.Put ("Buffer_Write_Byte, @=");
--        Debug_Out (Nat8 (IntPageAdr));
--        Debug_Out (Data);
--        Debug.New_Line;
   end Buffer_Write_Byte;



   --  ************************************************************************
   --  *
   --  * Parameters :    BufferNo    -> Decides usage of either buffer 1 or 2
   --  *                 IntPageAdr  -> Internal page address
   --  *                 No_of_bytes -> Number of bytes to be written
   --  *                 *BufferPtr  -> address of buffer to be used for copy
   --  *                                of bytes from AVR buffer to dataflash
   --  *                                buffer 1 (or 2)
   --  *
   --  * Purpose :       Copies one or more bytes to one of the dataflash
   --  *                 internal SRAM buffers from AVR SRAM buffer
   --  *                 pointed to by *BufferPtr
   --  *
   --  ************************************************************************
   procedure Buffer_Write_Array (BufferNo   : Buffer_Index;
                                 IntPageAdr : Byte_Address;
                                 Data       : AVR.Nat8_Array)
   is
   begin
      --  make sure to toggle CS signal in order to reset dataflash
      --  command decoder.
      CS_Inactive;
      CS_Active;

      if 1 = BufferNo then
         --  write byte(s) to buffer 1
         DF_SPI_Write (Commands.Buf1Write);

      elsif USE_BUFFER2 and then 2 = BufferNo then
         --  write byte(s) to buffer 2

         DF_SPI_Write (Commands.Buf2Write);
      else
         return;
      end if;

      --  don't cares
      DF_SPI_Write (0);
      --  upper part of internal buffer address
      DF_SPI_Write (Nat8 (Shift_Right (IntPageAdr, 8)));
      --  lower part of internal buffer address
      DF_SPI_Write (Nat8 (IntPageAdr));
      for I in Data'Range loop
         --  write byte pointed at by *BufferPtr to dataflash buffer 1 location
         DF_SPI_Write (Data (I));
      end loop;
   end Buffer_Write_Array;

   --  NB : Monitorer busy-flag i status-reg.
   --  NB : Sjekk at (IntAdr + No_of_bytes) < buffersize, hvis ikke blir det
   --       bare ball..



   --  ************************************************************************
   --  *
   --  * Parameters :    BufferAdr  -> Decides usage of either buffer 1 or 2
   --  *                 PageAdr    -> Address of flash page to be programmed
   --  *
   --  * Purpose :       Transfers a page from dataflash SRAM buffer to flash
   --  *
   --  ************************************************************************
   procedure Buffer_To_Page (BufferNo : Buffer_Index;
                             Page     : Page_Address) is
   begin
      --  make sure to toggle CS signal in order to reset dataflash
      --  command decoder
      CS_Inactive;
      CS_Active;

      if 1 = BufferNo then
         --  program flash page from buffer 1
         DF_SPI_Write (Commands.Buf1ToFlashWE);

      elsif USE_BUFFER2 and then 2 = BufferNo then
         --  program flash page from buffer 2
         DF_SPI_Write (Commands.Buf2ToFlashWE);

      else
         return;
      end if;

      --  upper part of page address
      DF_SPI_Write (Nat8 (Shift_Right (Page, 16 - Page_Bits)));
      --  lower part of page address
      DF_SPI_Write (Nat8 (Shift_Left (Page, Page_Bits - 8)));
      --  don't cares
      DF_SPI_Write (0);

      --  initiate flash page programming
      CS_Inactive;
      CS_Active;

      --  monitor the status register, wait until busy-flag is high
      while (Read_DF_Status and 16#80#) = 0 loop null; end loop;
   end Buffer_To_Page;



   --  ************************************************************************
   --  * Parameters :    PageAdr    -> Address of flash page where cont.read
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
      --  make sure to toggle CS signal in order to reset dataflash
      --  command decoder
      CS_Inactive;
      CS_Active;

      --  Continuous Array Read op-code
      DF_SPI_Write (Commands.ContArrayRead);
      --  upper part of page address
      DF_SPI_Write (Nat8 (Shift_Right (Page, 16 - Page_Bits)));
      --  lower part of page address and MSB of int.page adr.
      DF_SPI_Write (Nat8 (Shift_Left (Page, Page_Bits - 8))
                    + Nat8 (Shift_Right (IntPageAdr, 8)));
      --  LSB byte of internal page address
      DF_SPI_Write (Nat8 (IntPageAdr));
      --  perform 4 dummy writes in order to intiate DataFlash address
      --  pointers
      DF_SPI_Write (0);
      DF_SPI_Write (0);
      DF_SPI_Write (0);
      DF_SPI_Write (0);
   end Cont_Flash_Read_Enable;

end Dataflash;
