--   some routines to set the internal clock
--
--  the increment routines also increment the next higher digit at
--  overflow, the decrement routes simply underflow without carry over
--  from the higher digit.

package body RTC.Set_Clock is

   Max_Day : constant array (Month_Range) of Day_Range :=
     ( 1 => 31,
       2 => 28,
       3 => 31,
       4 => 30,
       5 => 31,
       6 => 30,
       7 => 31,
       8 => 31,
       9 => 30,
      10 => 31,
      11 => 30,
      12 => 31);


   procedure Inc_Sec is
   begin
      if Int_Clock.Sec /= 59 then
         Int_Clock.Sec := Int_Clock.Sec + 1;

      else
         Int_Clock.Sec := 0;

         Inc_Min;
      end if;
   end Inc_Sec;


   procedure Dec_Sec is
   begin
      if Int_Clock.Sec = 0 then
         Int_Clock.Sec := 59;
      else
         Int_Clock.Sec := Int_Clock.Sec - 1;
      end if;
   end Dec_Sec;


   procedure Inc_Min is
   begin
      if Int_Clock.Min /= 59 then
         Int_Clock.Min := Int_Clock.Min + 1;

      else
         Int_Clock.Min := 0;

         Inc_Hour;
      end if;
   end Inc_Min;


   procedure Dec_Min is
   begin
      if Int_Clock.Min = 0 then
         Int_Clock.Min := 59;
      else
         Int_Clock.Min := Int_Clock.Min - 1;
      end if;
   end Dec_Min;


   procedure Inc_Hour is
   begin
      if Int_Clock.Hour /= 23 then
         Int_Clock.Hour := Int_Clock.Hour + 1;

      else
         Int_Clock.Hour := 0;

         Inc_Day;
      end if;
   end Inc_Hour;


   procedure Dec_Hour is
   begin
      if Int_Clock.Hour = 0 then
         Int_Clock.Hour := 23;
      else
         Int_Clock.Hour := Int_Clock.Hour - 1;
      end if;
   end Dec_Hour;


   procedure Inc_Day is
   begin
      --  first handle leap years
      if Int_Clock.Year mod 4 = 0 and then Int_Clock.Month = 2 then
         if Int_Clock.Day = 29 then
            Int_Clock.Day := 1;
            Int_Clock.Month := 3;

         else
            Int_Clock.Day := Int_Clock.Day + 1;

         end if;

      elsif Int_Clock.Day = Max_Day (Int_Clock.Month) then
         Int_Clock.Day := 1;

         Inc_Month;
      else
         Int_Clock.Day := Int_Clock.Day + 1;

      end if;
   end Inc_Day;


   procedure Dec_Day is
   begin
      if Int_Clock.Day = 1 then
         Int_Clock.Day := 31;
      else
         Int_Clock.Day := Int_Clock.Day - 1;
      end if;
   end Dec_Day;


   procedure Inc_Month is
   begin
      if Int_Clock.Month /= 12 then
         Int_Clock.Month := Int_Clock.Month + 1;

      else
         Int_Clock.Month := 1;
         Inc_Year;

      end if;
   end Inc_Month;


   procedure Dec_Month is
   begin
      if Int_Clock.Month = 1 then
         Int_Clock.Month := 12;
      else
         Int_Clock.Month := Int_Clock.Month - 1;
      end if;
   end Dec_Month;


   procedure Inc_Year is
   begin
      Int_Clock.Year := Int_Clock.Year + 1;
   end Inc_Year;


   procedure Dec_Year is
   begin
      Int_Clock.Year := Int_Clock.Year - 1;
   end Dec_Year;

end RTC.Set_Clock;
