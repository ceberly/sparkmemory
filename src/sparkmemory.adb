package body Sparkmemory with
   SPARK_Mode => On
is
   function Align_Forward
     (Addr : Address_Type; Align : Align_Type) return Address_Type
     with
     Pre => Align mod 2 = 0
   is
      P : Address_Type := Addr;
      M : Address_Type := P mod Align;
   begin
      if M /= 0 then
         P := P + Align - M;
      end if;

      return P;
   end Align_Forward;

   procedure Arena_Init
     (A : out Arena; Store : System.Address; Size : Size_Type)
   is
   begin
      A.Buf         := Store;
      A.Buf_Length  := Size;
      A.Curr_Offset := 0;
   end Arena_Init;

   procedure Alloc_Align
     (A     : in out Arena; P : out System.Address; Size : Size_Type;
      Align :        Align_Type := Default_Alignment)
   is
      UIntAddr : Address_Type := Address_Type (To_Integer (A.Buf));
      Curr_Ptr : Address_Type := UIntAddr + A.Curr_Offset;
      Offset   : Offset_Type  := Align_Forward (Curr_Ptr, Align) - UIntAddr;
   begin
      P := System.Null_Address;

      if Offset + Size <= A.Buf_Length then
         P             := To_Address (Integer_Address (UIntAddr + Offset));
         A.Curr_Offset := Offset + Size;
      end if;

   end Alloc_Align;
end Sparkmemory;
