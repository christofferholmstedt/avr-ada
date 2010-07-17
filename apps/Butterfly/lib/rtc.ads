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
--   modelled a bit after Ada.Real_Time and Ada.Calendar

with Interfaces;                   use Interfaces;

package RTC is

   type Time is private;
   Time_First : constant Time;

   Time_Unit  : constant := 1.0;  -- we count only whole seconds


   function Clock return Time;


   --  set up timer 2
   procedure Init;


   subtype Second_Range is Unsigned_8 range 0 .. 59;
   subtype Minute_Range is Unsigned_8 range 0 .. 59;
   subtype Hour_Range   is Unsigned_8 range 0 .. 23;
   subtype Day_Range    is Unsigned_8 range 1 .. 31;
   subtype Month_Range  is Unsigned_8 range 1 .. 12;
   subtype Year_Range   is Unsigned_8; --  biased to 2000

   --  split functions
   function Seconds (Date : Time) return Second_Range;
   function Minute  (Date : Time) return Minute_Range;
   function Hour    (Date : Time) return Hour_Range;
   function Day     (Date : Time) return Day_Range;
   function Month   (Date : Time) return Month_Range;
   function Year    (Date : Time) return Year_Range;

   --  constructor function
   function Time_Of (Year    : Year_Range;
                     Month   : Month_Range;
                     Day     : Day_Range;
                     Hour    : Hour_Range   := 0;
                     Minute  : Minute_Range := 0;
                     Seconds : Second_Range := 0)
     return Time;

   --  set the date and time parts separately in the internal clock to
   --  Target.
   procedure Set_Internal_Date_Part (Target : Time);
   procedure Set_Internal_Time_Part (Target : Time);
   --  set all fields of the internal clock
   procedure Set_Internal_Clock (Target : Time);


private

   type Time is record
      Sec   : Second_Range;
      Min   : Minute_Range;
      Hour  : Hour_Range;
      Day   : Day_Range;
      Month : Month_Range;
      Year  : Year_Range;
   end record;


   Time_First : constant Time :=
     (Sec   => 0,
      Min   => 0,
      Hour  => 0,
      Day   => 1,
      Month => 1,
      Year  => 4); -- Jan 1st 2004 midnight


   --  the single time object is the internal clock.  We put it in the
   --  private part of the spec to make it visible to children of this
   --  package.
   Int_Clock : Time := Time_First;
   -- pragma Atomic (Int_Clock);
   pragma Volatile (Int_Clock);


   pragma Inline (Seconds);
   pragma Inline (Minute);
   pragma Inline (Hour);
   pragma Inline (Day);
   pragma Inline (Month);
   pragma Inline (Year);
   pragma Inline (Time_Of);


end RTC;
