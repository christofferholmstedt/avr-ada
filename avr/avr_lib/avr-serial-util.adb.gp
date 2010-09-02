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
-- Modified by Warren W. Gay VE3WWG
---------------------------------------------------------------------------

with AVR.Strings;           use AVR.Strings;
with AVR.Int_Img;

package body AVR.Serial.Util is


   -- For Error Message (only)
   procedure Put_Error (S : AVR_String) is
      CR : constant := 16#0D#;
      LF : constant := 16#0A#;
   begin
      for I in S'Range loop
         AVR.Serial.Put (S (I));
      end loop;
      AVR.Serial.Put( Character'Val(CR) );
      AVR.Serial.Put( Character'Val(LF) );
   end Put_Error;


   procedure Put (Data : Unsigned_8;
                  Base : Unsigned_8 := 10)
   is
   begin
      if Base /= 16 then
         declare
            Img : AStr3;
            L   : Unsigned_8;
         begin
            AVR.Int_Img.U8_Img (Data, Img, L);
            for I in 1 .. L loop
               AVR.Serial.Put (Img (I));
            end loop;
         end;
      else
         declare
            Img : AStr2;
         begin
            AVR.Int_Img.U8_Hex_Img (Data, Img);
            AVR.Serial.Put (Img (1));
            AVR.Serial.Put (Img (2));
         end;
      end if;
   end Put;


   procedure Put (Data : Integer_16;
                  Base : Unsigned_8 := 10)
   is
      Img : AStr5;
      L   : Unsigned_8;
   begin
      if Base /= 16 then
         if Data < 0 then
            AVR.Serial.Put ('-');
            AVR.Int_Img.U16_Img (Unsigned_16 (-Data), Img, L);
         else
            AVR.Int_Img.U16_Img (Unsigned_16 (Data), Img, L);
         end if;
         for J in Unsigned_8'(1) .. L loop
            Put (Img (J));
         end loop;
      else
         Put_Error ("Put(int16, base=16) not yet implemented");
      end if;
   end Put;


   procedure Put (Data : Unsigned_16;
                  Base : Unsigned_8 := 10)
   is
      Img : AStr5;
      L   : Unsigned_8;
   begin
      if Base = 16 then
         Put (High_Byte (Data), 16);
         Put (Low_Byte (Data), 16);
      elsif Base = 10 then
         AVR.Int_Img.U16_Img (Data, Img, L);
         for J in Unsigned_8'(1) .. L loop
            Put (Img (J));
         end loop;
      else
         Put_Error ("Put(u16) not yet implemented");
      end if;
   end Put;


   procedure Put (Data : Unsigned_32;
                  Base : Unsigned_8 := 10)
   is
      -- Img : AStr5;
      -- L   : Unsigned_8;
--    pragma Not_Referenced (Base);
   begin
--      if Base = 16 then
         Put (Unsigned_8 (Data / 256 / 256 / 256), 16);
         Put (Unsigned_8 ((Data and 16#00FF0000#) / 256 / 256), 16);
         Put (Unsigned_8 ((Data and 16#0000FF00#) / 256), 16);
         Put (Unsigned_8 (Data and 16#000000FF#), 16);
--      end if;
   end Put;


   procedure Send_LIN_Break is
#if not UART = "UART" then
      Orig_Baud_Divider : constant Unsigned_16 := UBRR;
#else
      Orig_Baud_Divider : constant Unsigned_8 := UBRRL;
#end if;
   begin
      --  We send a 16#00#. That will pull the line low for 9 bit
      --  lengths.  In order to achieve a low of 13 bit times we have
      --  to increase the bit time by about 50%, i.e. reduce the baud
      --  rate by 2/3.
      --
      --  the Baud rate calculates as follows:
      --               Freq
      --  Baud = ---------------
      --          16 (UBBR + 1)
      --
      --  after transformation we get
      --
      --  UBBR (2/3Baud) = 1.5(UBBR + 1) - 1
      --
      --  I consider that formula too complicated for what we need.
      --  The pragmatic solution is to simply double the existing UBBR
      --  value.
      --
      --  The current setting is in UBBR
      --
      --  Freq [MHz] | Baud rate | UBBR |
      --      8.0    |      9600 |   51 |
      --
      UBRR := UBRR * 2;


#if UART = "USART" then
      -- Async. mode, 8N1
      UCSRC := +(UCSZ0_Bit => True,
                 UCSZ1_Bit => True,
                 URSEL_Bit => True,
                 others => False);

      --  at least on atmega8 UCSRC and UBRRH share the same address.
      --  When writing to the ACSRC register, the URSEL must be set,
      --  too.
#elsif UART = "USART0" then
      -- Async. mode, 8N1
      UCSRC := +(UCSZ0_Bit => True,
                 UCSZ1_Bit => True,
                 others => False);

#end if;

      --
      Put_Raw (16#00#);

      --  reset the baud divider
      UBRR := Orig_Baud_Divider;

   end Send_LIN_Break;


end AVR.Serial.Util;

-- Local Variables:
-- mode:ada
-- End:
