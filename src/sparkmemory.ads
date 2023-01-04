with System;                  use System;
with System.Storage_Elements; use System.Storage_Elements;

with Interfaces.C; use Interfaces.C;

package Sparkmemory with
   SPARK_Mode => On
is
   type Arena is private;

   subtype Address_Type is Integer_Address;
   -- type Address_Type is mod System.Memory_Size;

   subtype Size_Type is Interfaces.C.size_t;
   subtype Offset_Type is Integer_Address;
   subtype Align_Type is Integer_Address range 1 .. Integer_Address'Last;

   -- XXX: gnatprove issues a warning about the initial value of A not being
   -- used. Which is true, but I need to create it in C and I can't get
   -- just out (vs in out) params to work right with Ada <-> C.
   procedure Arena_Init
     (A : in out Arena; Store : Address_Type; Size : Size_Type);

   procedure Alloc_Align
     (A     : in out Arena; P : out Address_Type; Size : Size_Type;
      Align :        Align_Type) with
      Pre => Align mod 2 = 0 and then Size > 0;

   package C with
      -- respect the C idiom of returning a pointer and modifying a state,
      -- for better or worse :)
      SPARK_Mode => Off
   is
      -- XXX This function can actually be done through SPARK, come back.
      procedure Arena_Init
        (A    : in out Arena; Store : Address_Type;
         Size :        Interfaces.C.size_t) with
         Export        => True,
         Convention    => C,
         External_Name => "arena_init";

      function Arena_Alloc
        (A     : in out Arena; Size : Interfaces.C.size_t;
         Align :        Interfaces.C.size_t) return System.Address with
         Export        => True,
         Convention    => C,
         External_Name => "arena_alloc";
   end C;

private
   type Arena is record
      Buf         : Address_Type := To_Integer (System.Null_Address);
      Buf_Length  : Size_Type    := 0;
      Curr_Offset : Offset_Type  := 0;
   end record with
      Convention => C;
end Sparkmemory;
