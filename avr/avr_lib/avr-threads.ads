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
-- Resources Used:
-- 
--  (1) Uses AVR 8-bit timer2
--  (2) -lavr-threads
-- 
-- Notes:
--
--  (1) Stack_Size must be >= approx 41 bytes minimum, to allow
--      the save of all regs, return address & status etc., in
--      addition to your thread's own additional needs. Interrupt
--      service routines will also use your stacks.
--
--  (2) Timer2 defaults to Scale_by_1024, with a compare count 255.
--      Invoke procedure Set_Timer to change the time slice.
--
----------------------------------------------------------------------

with Interfaces;
use Interfaces;

with AVR.Timer2;

package AVR.Threads is

    ------------------------------------------------------------------
    -- Thread API Types
    ------------------------------------------------------------------
    type Thread_Context(Stack_Size : Unsigned_16) is private;
    type Thread_Proc is access procedure;

    ------------------------------------------------------------------
    -- Thread API
    ------------------------------------------------------------------
    procedure Thread_Start(Context : in out Thread_Context; Proc : Thread_Proc);
    procedure Thread_Stop;
    procedure Thread_Sleep(Ticks : Natural);
    procedure Thread_Yield;

    ------------------------------------------------------------------
    -- Return the # of Stack Bytes Used, or Zero if Overrun
    ------------------------------------------------------------------
    function Stack_Used(Context : Thread_Context) return Unsigned_16;

    ------------------------------------------------------------------
    -- Timer 
    ------------------------------------------------------------------
    function Get_Timer_Ticks return Unsigned_32;

    procedure Set_Timer(Prescale : AVR.Timer2.Scale_Type; Compare : Unsigned_8);

    ------------------------------------------------------------------
    -- Mutexes
    ------------------------------------------------------------------

    type Thread_Mutex is private;
    type Nested_Mutex is private;

    procedure Mutex_Acquire(Mutex : in out Thread_Mutex);
    procedure Mutex_Acquire(Mutex : in out Thread_Mutex; Success : out Boolean);
    procedure Mutex_Release(Mutex : in out Thread_Mutex);

    procedure Mutex_Acquire(Mutex : in out Nested_Mutex; Success : out Boolean; Timeout_Ticks : Natural := 0);
    procedure Mutex_Release(Mutex : in out Nested_Mutex; Success : out Boolean);

    ------------------------------------------------------------------
    -- Events
    ------------------------------------------------------------------
    type Thread_Event is private;

    procedure Event_Clear(Event : in out Thread_Event);
    procedure Event_Wake_All(Event : in out Thread_Event);
    procedure Event_Wake_One(Event : in out Thread_Event);
    procedure Event_Wait(Event : in out Thread_Event; Success : out Boolean; Timeout_Ticks : Natural := 0);
    procedure Event_Wait_And_Clear(Event : in out Thread_Event; Success : out Boolean; Timeout_Ticks : Natural := 0);

private

    Align :     constant := 4;

    type Thread_Context_Ptr is access all Thread_Context;

----------------------------------------------------------------------
-- The AVR_Threads Context Object is declared Thusly in C
----------------------------------------------------------------------
--  typedef enum {
--      ats_normal,
--      ats_wait,
--      ats_clear = 0x40,
--      ats_tick = 0x80
--  } __attribute__((packed)) avr_thread_state;
--  
--  typedef struct avr_thread_context {
--      volatile avr_thread_state state;
--      uint8_t* stack_ptr;
--      volatile struct avr_thread_context* next;
--      volatile int16_t timeout;
--      volatile void* waiting_for;
--      volatile struct avr_thread_context* next_waiting;
--      volatile struct avr_thread_context* prev_waiting;
--  } avr_thread_context;

    ------------------------------------------------------------------
    -- It is critical, that the C_Context_Type be declared
    -- 64-bit aligned (in Thread_Context).
    ------------------------------------------------------------------
    type C_Context_Type is array(1..16) of Unsigned_8;
    for C_Context_Type'Component_Size use 8;
    for C_Context_Type'Object_Size use 16 * 8;

    ------------------------------------------------------------------
    -- Stack space for the thread
    ------------------------------------------------------------------
    type Stack_Type is array(Unsigned_16 range <>) of Unsigned_8;
    for Stack_Type'Component_Size use 8;

    ------------------------------------------------------------------
    -- This is the Ada version of the Thread Context
    --
    -- C_Context    for AVR_Threads library.
    -- Ada_Proc     for the Thread_Thunk procedure
    -- Stack_Size   determines the size of the stack used.
    -- Stack        the new thread's stack area.
    ------------------------------------------------------------------
    type Thread_Context(Stack_Size : Unsigned_16) is
        record
            C_Context :     aliased C_Context_Type;
            Ada_Proc :      Thread_Proc;
            Stack :         aliased Stack_Type(1..Stack_Size);
        end record;

    pragma Volatile(Thread_Context);

    for Thread_Context use
        record
            C_Context       at  0 range 0 .. 16 * 8 -1;     -- Must be first to be 64-bit aligned
            Ada_Proc        at 16 range 0 .. 15;            -- Non critical placement
            Stack_Size      at 18 range 0 .. 15;            -- Moved here - non critical
        --  Stack           at 20 range 0 .. Stack_Size * 8 - 1;
        end record;

    for Thread_Context'Alignment use Align;

--  typedef struct {
--          uint8_t locked;
--  } avr_thread_mutex_basic;

    type Thread_Mutex is
        record
            C_Mutex :   Unsigned_8 := 0;
        end record;

    pragma Volatile(Thread_Mutex);

    for Thread_Mutex'Alignment use Align;

--  typedef struct {
--      uint8_t lock_count;
--      avr_thread_context* owner;
--  } avr_thread_mutex;

    ------------------------------------------------------------------
    -- Ada Version of the Thread_Mutex
    ------------------------------------------------------------------
    type Nested_Mutex is
        record
            Lock_Count :    Unsigned_8  := 0;
            Thread_Owner :  Unsigned_16 := 0;
        end record;

    for Nested_Mutex use
        record
            Lock_Count      at  0 range 0 ..  7;
            Thread_Owner    at  1 range 0 .. 15;
        end record;

    pragma Volatile(Nested_Mutex);

    for Nested_Mutex'Alignment use Align;

--  typedef struct {
--      volatile uint8_t state;
--  } avr_thread_event;

    ------------------------------------------------------------------
    -- Ada Version of the AVR-Thread Event Object
    ------------------------------------------------------------------
    type Thread_Event is
        record
            C_State :       Unsigned_8  := 0;
        end record;

    for Thread_Event use
        record
            C_State         at 0 range 0 .. 7;
        end record;

    pragma Volatile(Thread_Event);

    for Thread_Event'Alignment use Align;


    pragma inline(Thread_Sleep);
    pragma inline(Thread_Yield);
    pragma inline(Thread_Stop);

    pragma inline(Mutex_Acquire);
    pragma inline(Mutex_Release);

    pragma inline(Event_Clear);
    pragma inline(Event_Wake_All);
    pragma inline(Event_Wake_One);
    pragma inline(Event_Wait);
    pragma inline(Event_Wait_And_Clear);

    pragma Linker_Options("-lavr-thread");

end AVR.Threads;
