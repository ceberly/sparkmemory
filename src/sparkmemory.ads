with System;                  use System;
with System.Storage_Elements; use System.Storage_Elements;

with Interfaces.C; use Interfaces.C;

package Sparkmemory with
   SPARK_Mode => On
is
   subtype Address_Type is Integer_Address;
   subtype Size_Type is Address_Type;
   subtype Offset_Type is Address_Type;

   -- 1KB alignment max? /shrug
   subtype Align_Type is Offset_Type range 1 .. 2**10 with
        Static_Predicate => Align_Type in 2**0 | 2**1 | 2**2 | 2**3 | 2**4 |
            2**5 | 2**6 | 2**7 | 2**8 | 2**9 | 2**10;

   function Align_Forward
     (Ptr : Address_Type; Align : Align_Type) return Address_Type with
      Pre => Ptr > 0 and then Align mod 2 = 0
      and then Address_Type'Last - Ptr >= Align,
      Post => Align_Forward'Result >= Ptr;

end Sparkmemory;
