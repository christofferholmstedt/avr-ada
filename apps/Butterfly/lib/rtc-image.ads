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

--   Real Time Clock
--   generate output strings

with AVR.Strings;                  use AVR.Strings;

package RTC.Image is


   type Time_Format is (Clock_12, Clock_24);
   type Date_Format is (MMDDYY,  --  American: month day year
                        DDMMYY,  --  European: day month year
                        YYMMDD); --  ISO:      year month day


   --  set the date in the internal clock to Target
   function Set_Date (Target : AStr6;
                      Form   : Date_Format := DDMMYY)
                      return Time;
   function Date_Image (D : Time;
                        Form : Date_Format := DDMMYY)
                        return AStr6;


   --  set the time always in 24h format of HHMMSS
   function Set_Time (Target : AStr6) return Time;
   function Time_Image (T : Time;
                        Form : Time_Format := Clock_24)
                        return AStr6;


end RTC.Image;
