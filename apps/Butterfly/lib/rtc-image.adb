with AVR.Int_Img;

package body RTC.Image is


   function Set_Date (Target : AStr6; Form : Date_Format := DDMMYY) return Time
   is
      D : Time := Time_First;
   begin
      return D;
   end Set_Date;


   function Date_Image (D : Time;
                        Form : Date_Format := DDMMYY) return AStr6 is
      use AVR.Int_Img;
      Result : AStr6;
   begin
      case Form is
      when DDMMYY =>
         U8_Img_99_Right (D.Day,   Result (1 .. 2));
         U8_Img_99_Right (D.Month, Result (3 .. 4));
         U8_Img_99_Right (D.Year,  Result (5 .. 6));
      when YYMMDD =>
         U8_Img_99_Right (D.Year,  Result (1 .. 2));
         U8_Img_99_Right (D.Month, Result (3 .. 4));
         U8_Img_99_Right (D.Day,   Result (5 .. 6));
      when MMDDYY =>
         U8_Img_99_Right (D.Month, Result (1 .. 2));
         U8_Img_99_Right (D.Day,   Result (3 .. 4));
         U8_Img_99_Right (D.Year,  Result (5 .. 6));
      end case;
      return Result;
   end Date_Image;


   function Set_Time (Target : AStr6) return Time is
      T : Time := Time_First;
   begin
      return T;
   end Set_Time;


   function Time_Image (T : Time;
                        Form : Time_Format := Clock_24) return AStr6 is
      use AVR.Int_Img;
      Result : AStr6;
   begin
      U8_Img_99_Right (T.Hour, Result (1 .. 2));
      U8_Img_99_Right (T.Min,  Result (3 .. 4));
      U8_Img_99_Right (T.Sec,  Result (5 .. 6));
      return Result;
   end Time_Image;

end RTC.Image;
