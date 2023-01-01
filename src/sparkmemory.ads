with System;                  use System;
with System.Storage_Elements; use System.Storage_Elements;

package Sparkmemory with
   SPARK_Mode => On
is
   type Arena is private;

   subtype Address_Type is Integer_Address range 0 .. Integer_Address'Last;
   -- type Address_Type is mod System.Memory_Size;

   subtype Size_Type is Address_Type;
   subtype Offset_Type is Address_Type;
   subtype Align_Type is Address_Type range 1 .. Address_Type'Last;

   Default_Alignment : constant Align_Type := System.Address'Size * 2;

   procedure Arena_Init
     (A : out Arena; Store : Address_Type; Size : Size_Type) with
      Pre => Store /= To_Integer (System.Null_Address) and then Size > 0;

   procedure Alloc_Align
     (A     : in out Arena; P : out Address_Type; Size : Size_Type;
      Align :        Align_Type := Default_Alignment) with
      Pre => Align mod 2 = 0;

private
   type Arena is record
      Buf         : Address_Type := To_Integer (System.Null_Address);
      Buf_Length  : Size_Type    := 0;
      Curr_Offset : Offset_Type  := 0;

   end record;
end Sparkmemory;
