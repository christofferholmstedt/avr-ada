package body RTC is


   package Clock_Imp is
      procedure Init;
   end Clock_Imp;

   package body Clock_Imp is separate;


   procedure Init renames Clock_Imp.Init;


   function Clock return Time is
   begin
      return Int_Clock;
   end Clock;


   function Seconds (Date : Time) return Second_Range is
   begin
      return Date.Sec;
   end Seconds;

   function Minute  (Date : Time) return Minute_Range is
   begin
      return Date.Min;
   end Minute;

   function Hour    (Date : Time) return Hour_Range is
   begin
      return Date.Hour;
   end Hour;

   function Day     (Date : Time) return Day_Range is
   begin
      return Date.Day;
   end Day;

   function Month   (Date : Time) return Month_Range is
   begin
      return Date.Month;
   end Month;

   function Year    (Date : Time) return Year_Range is
   begin
      return Date.Year;
   end Year;


   --  constructor function
   function Time_Of (Year    : Year_Range;
                     Month   : Month_Range;
                     Day     : Day_Range;
                     Hour    : Hour_Range   := 0;
                     Minute  : Minute_Range := 0;
                     Seconds : Second_Range := 0)
                    return Time
   is
   begin
      return Time'(Sec   => Seconds,
                   Min   => Minute,
                   Hour  => Hour,
                   Day   => Day,
                   Month => Month,
                   Year  => Year);
   end Time_Of;


   procedure Set_Internal_Date_Part (Target : Time)
   is
   begin
      Int_Clock.Day   := Target.Day;
      Int_Clock.Month := Target.Month;
      Int_Clock.Year  := Target.Year;
   end Set_Internal_Date_Part;


   procedure Set_Internal_Time_Part (Target : Time)
   is
   begin
      Int_Clock.Sec  := Target.Sec;
      Int_Clock.Min  := Target.Min;
      Int_Clock.Hour := Target.Hour;
   end Set_Internal_Time_Part;


   --  set all fields of the internal clock
   procedure Set_Internal_Clock (Target : Time)
   is
   begin
      Set_Internal_Date_Part (Target);
      Set_Internal_Time_Part (Target);
   end Set_Internal_Clock;

end RTC;

