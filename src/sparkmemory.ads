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

   procedure Arena_Init
     (A : out Arena; Store : Address_Type; Size : Size_Type);

   procedure Alloc_Align
     (A     : in out Arena; P : out Address_Type; Size : Size_Type;
      Align :        Align_Type) with
      Pre => Align mod 2 = 0;

   procedure C_Arena_Init
     (A : out Arena; Store : Address_Type; Size : Interfaces.C.size_t) with
      Export        => True,
      Convention    => C,
      External_Name => "arena_init";

   procedure C_Arena_Alloc
     (A : in out Arena; Addr : out System.Address; Size : Interfaces.C.size_t;
      Align :        Interfaces.C.size_t) with
      Export        => True,
      Convention    => C,
      External_Name => "arena_alloc";

private
   type Arena is record
      Buf         : Address_Type := To_Integer (System.Null_Address);
      Buf_Length  : Size_Type    := 0;
      Curr_Offset : Offset_Type  := 0;
   end record;
end Sparkmemory;
