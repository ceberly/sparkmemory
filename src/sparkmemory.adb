package body Sparkmemory is
   -- Computes A mod B, quickly, if B is a power of 2.
   function Fast_Mod
     (A : Integer_Address; B : Align_Type) return Integer_Address is
     (A and (B - 1)) with
      Inline => True,
      Pre    => B >= 2 and then B mod 2 = 0,
      Post   => Fast_Mod'Result >= 0 and then Fast_Mod'Result < B
      and then Fast_Mod'Result = A mod B;

   function Align_Forward
     (Ptr : Address_Type; Align : Align_Type) return Address_Type
   is
      M : constant Integer_Address := Fast_Mod (Ptr, Align);
   begin
      if M = 0 then
         return Ptr;
      else
         return Ptr + Align - M;
      end if;
   end Align_Forward;
end Sparkmemory;
