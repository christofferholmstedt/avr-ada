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
-- Written by Warren W. Gay VE3WWG
---------------------------------------------------------------------------

with Interfaces;
with System;
with Ada.Unchecked_Conversion;
with AVR.MCU;
with AVR.Timer2;
with AVR.Interrupts;

use Interfaces;
use AVR;

package body AVR.Threads is

    Ticks : Unsigned_32;

    ------------------------------------------------------------------
    --                        T H R E A D S
    ------------------------------------------------------------------

    ------------------------------------------------------------------
    -- Initialize the Threading Library and Timer
    ------------------------------------------------------------------
    procedure Thread_Init is
        procedure avr_thread_init;
        pragma import(C,avr_thread_init,"avr_thread_init");

    begin

        AVR.Interrupts.Disable_Interrupts;
        AVR.Timer2.Init_CTC(AVR.Timer2.Scale_By_1024,255);
        Ticks := 0;
        avr_thread_init;
        AVR.Interrupts.Enable_Interrupts;

    end;

    pragma inline(Thread_Init);

    ------------------------------------------------------------------
    -- Change Timer Resolution
    ------------------------------------------------------------------
    procedure Set_Timer(Prescale : AVR.Timer2.Scale_Type; Compare : Unsigned_8) is
    begin

        AVR.Interrupts.Disable_Interrupts;
        AVR.Timer2.Stop;
        AVR.Timer2.Init_CTC(Prescale,Compare);
        AVR.Interrupts.Enable_Interrupts;

    end Set_Timer;

    ------------------------------------------------------------------
    -- Timer2 ISR
    ------------------------------------------------------------------
    
    procedure Timer2_ISR;
    pragma Machine_Attribute (Entity => Timer2_ISR, Attribute_Name => "naked");
    pragma Export(C,Timer2_ISR,MCU.Sig_TIMER2_COMPA_String);

    procedure Timer2_ISR is
        procedure avr_thread_isr_start;
        procedure avr_thread_isr_end;

        pragma Import(C,avr_thread_isr_start,"avr_thread_isr_start");
        pragma Import(C,avr_thread_isr_end,"avr_thread_isr_end");
    begin

	avr_thread_isr_start;
	Ticks := Ticks + 1;
	avr_thread_isr_end;

    end Timer2_ISR;

    ------------------------------------------------------------------
    -- Return the # Ticks from the Timer
    ------------------------------------------------------------------
    function Get_Timer_Ticks return Unsigned_32 is
        R : Unsigned_32;
    begin

        AVR.Interrupts.Disable_Interrupts;
        R := Ticks;
        AVR.Interrupts.Enable_Interrupts;
        return R;

    end;

    ------------------------------------------------------------------
    -- INTERNAL - Return Access to the Current Thread's Context Object
    ------------------------------------------------------------------
    function Get_Context return Thread_Context_Ptr is
        type C_Context_Ptr is access all Thread_Context;
        pragma Convention(Convention => C, Entity => C_Context_Ptr);

        type Ada_Context_Ptr is access all Thread_Context;
        pragma Convention(Convention => Ada, Entity => Ada_Context_Ptr);

        function To_Thread_Context_Ptr is
            new Ada.Unchecked_Conversion(Ada_Context_Ptr,Thread_Context_Ptr);

        C_Context : C_Context_Ptr;
        pragma Volatile(C_Context);
        pragma Import(C,C_Context,"avr_thread_active");

        A_Context : Ada_Context_Ptr;
    begin

        A_Context := Ada_Context_Ptr(C_Context);
        return To_Thread_Context_Ptr(A_Context);

    end Get_Context;

    ------------------------------------------------------------------
    -- INTERNAL - Trampoline from C code into Ada procedure
    ------------------------------------------------------------------
    procedure Thread_Thunk;
    pragma export(C,Thread_Thunk,"thread_thunk");

    procedure Thread_Thunk is
        Context : Thread_Context_Ptr := Get_Context;
    begin

        Context.Ada_Proc.all;   -- Start Ada proc
        Thread_Stop;            -- Stop it if it returns

    end Thread_Thunk;

    ------------------------------------------------------------------
    -- Start a new Thread
    ------------------------------------------------------------------
    procedure Thread_Start(Context : in out Thread_Context; Proc : Thread_Proc) is
        type Func_Ptr is access procedure;
        pragma Convention(C,Func_Ptr);

        procedure avr_thread_start(
                    Context : System.Address;
                    Func : Func_Ptr;
                    Stack : System.Address;
                    Size : Interfaces.Unsigned_16);
        pragma import(C,avr_thread_start,"avr_thread_start");
    begin

        for X in Context.Stack'Range loop
            Context.Stack(X) := 16#BE#;     -- Write signature bytes into stack
        end loop;

        Context.Ada_Proc := Proc;   -- Tell Thread_Thunk what to start

        avr_thread_start(
            Context     => Context.C_Context'Address,
            Func        => Thread_Thunk'Access,
            Stack       => Context.Stack'Address,
            Size        => Context.Stack_Size
        );

    end Thread_Start;

    ------------------------------------------------------------------
    -- Return the # of Stack Bytes Used or Zero if Corrupted
    ------------------------------------------------------------------
    function Stack_Used(Context : Thread_Context) return Unsigned_16 is
    begin

        if Context.Stack(Context.Stack'First) /= 16#BE# then
            return 0;               -- Full stack used, & likely overrun
        end if;

        for X in Context.Stack'Range loop
            if Context.Stack(X) /= 16#BE# then
                return Context.Stack'Last - X + 1;
            end if;
        end loop;

        return 0;                   -- This exit should never happen

    end Stack_Used;

    ------------------------------------------------------------------
    -- Stop the Current Thread
    ------------------------------------------------------------------
    procedure Thread_Stop is
        procedure avr_thread_stop;
        pragma import(C,avr_thread_stop,"avr_thread_stop");
    begin

        avr_thread_stop;

    end Thread_Stop;

    ------------------------------------------------------------------
    -- Yield for Some Milliseconds
    ------------------------------------------------------------------
    procedure Thread_Sleep(Ticks : Natural) is
        procedure avr_thread_sleep(ticks : Unsigned_16);
        pragma import(C,avr_thread_sleep,"avr_thread_sleep");
    begin
    
        avr_thread_sleep(Unsigned_16(Ticks));

    end;

    ------------------------------------------------------------------
    -- Just Yield
    ------------------------------------------------------------------
    procedure Thread_Yield is
    begin
        Thread_Sleep(0);
    end;

    
    ------------------------------------------------------------------
    --                         M U T E X
    ------------------------------------------------------------------


    ------------------------------------------------------------------
    -- Acquire a Mutex
    ------------------------------------------------------------------
    procedure Mutex_Acquire(Mutex : in out Thread_Mutex) is
        procedure avr_thread_mutex_basic_gain(Mutex : System.Address);
        pragma import(C,avr_thread_mutex_basic_gain,"avr_thread_mutex_basic_gain");
    begin
        avr_thread_mutex_basic_gain(Mutex.C_Mutex'Address);
    end;

    ------------------------------------------------------------------
    -- Test and Acquire a Mutex
    ------------------------------------------------------------------
    procedure Mutex_Acquire(Mutex : in out Thread_Mutex; Success : out Boolean) is
        use Interfaces;

        function avr_thread_mutex_basic_test_and_gain(Mutex : System.Address) return Unsigned_8;
        pragma import(C,avr_thread_mutex_basic_test_and_gain,"avr_thread_mutex_basic_test_and_gain");
    begin
        Success := avr_thread_mutex_basic_test_and_gain(Mutex.C_Mutex'Address) /= 0;
    end;

    ------------------------------------------------------------------
    -- Release a Mutex
    ------------------------------------------------------------------
    procedure Mutex_Release(Mutex : in out Thread_Mutex) is
        procedure avr_thread_mutex_basic_release(Mutex : System.Address);
        pragma import(C,avr_thread_mutex_basic_release,"avr_thread_mutex_basic_release");
    begin
        avr_thread_mutex_basic_release(Mutex.C_Mutex'Address);
    end;

    ------------------------------------------------------------------
    -- Nested Mutex Acquire
    --
    -- When Timeout_Ticks = 0, will block indefinitely
    -- When task already owns mutex, ownership is incremented (nested lock)
    --
    ------------------------------------------------------------------
    procedure Mutex_Acquire(Mutex : in out Nested_Mutex; Success : out Boolean; Timeout_Ticks : Natural := 0) is
        use Interfaces;

        function avr_thread_mutex_gain(Mutex : System.Address; Ticks : Unsigned_16) return Unsigned_8;
        pragma import(C,avr_thread_mutex_gain,"avr_thread_mutex_gain");
    begin
        Success := avr_thread_mutex_gain(Mutex'Address,Unsigned_16(Timeout_Ticks)) /= 0;
    end Mutex_Acquire;

    ------------------------------------------------------------------
    -- Nested Mutex Release
    --
    -- Must be released as many times as Acquired to free Mutex
    ------------------------------------------------------------------
    procedure Mutex_Release(Mutex : in out Nested_Mutex; Success : out Boolean) is
        use Interfaces;

        function avr_thread_mutex_release(Mutex : System.Address) return Unsigned_8;
        pragma import(C,avr_thread_mutex_release,"avr_thread_mutex_release");
    begin
        Success := avr_thread_mutex_release(Mutex'Address) /= 0;
    end Mutex_Release;


    ------------------------------------------------------------------
    --                        E V E N T S
    ------------------------------------------------------------------


    ------------------------------------------------------------------
    -- Clear the Event
    --
    -- This does not release any waiting threads.
    ------------------------------------------------------------------
    procedure Event_Clear(Event : in out Thread_Event) is
        procedure avr_thread_event_clear(Event : System.Address);
        pragma Import(C,avr_thread_event_clear,"avr_thread_event_clear");
    begin
        avr_thread_event_clear(Event.C_State'Address);
    end;
    
    ------------------------------------------------------------------
    -- Wake only one waiting thread
    ------------------------------------------------------------------
    procedure Event_Wake_One(Event : in out Thread_Event) is
        procedure avr_thread_event_set_wake_one(Event : System.Address);
        pragma Import(C,avr_thread_event_set_wake_one,"avr_thread_event_set_wake_one");
    begin
        avr_thread_event_set_wake_one(Event.C_State'Address);
    end;

    ------------------------------------------------------------------
    -- Wake all waiting threads
    ------------------------------------------------------------------
    procedure Event_Wake_All(Event : in out Thread_Event) is
        procedure avr_thread_event_set_wake_all(Event : System.Address);
        pragma Import(C,avr_thread_event_set_wake_all,"avr_thread_event_set_wake_all");
    begin
        avr_thread_event_set_wake_all(Event.C_State'Address);
    end;

    ------------------------------------------------------------------
    -- Wait for the event to be signaled
    ------------------------------------------------------------------
    procedure Event_Wait(Event : in out Thread_Event; Success : out Boolean; Timeout_Ticks : Natural := 0) is
        function avr_thread_event_wait(Event : System.Address; Ticks : Unsigned_16) return Unsigned_8;
        pragma Import(C,avr_thread_event_wait,"avr_thread_event_wait");
    begin
        Success := avr_thread_event_wait(Event.C_State'Address,Unsigned_16(Timeout_Ticks)) /= 0;
    end;

    ------------------------------------------------------------------
    -- Wait and Clear event when it is signaled
    ------------------------------------------------------------------
    procedure Event_Wait_And_Clear(Event : in out Thread_Event; Success : out Boolean; Timeout_Ticks : Natural := 0) is
        function avr_thread_event_wait_and_clear(Event : System.Address; Ticks : Unsigned_16) return Unsigned_8;
        pragma Import(C,avr_thread_event_wait_and_clear,"avr_thread_event_wait_and_clear");
    begin
        Success := avr_thread_event_wait_and_clear(Event.C_State'Address,Unsigned_16(Timeout_Ticks)) /= 0;
    end;

begin
    Thread_Init;
end AVR.Threads;
