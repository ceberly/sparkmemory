package body Sparkmemory with
   SPARK_Mode => On
is
   function Align_Forward
     (Addr : Address_Type; Align : Align_Type) return Address_Type with
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

   procedure Arena_Init (A : out Arena; Store : Address_Type; Size : Size_Type)
   is
   begin
      A.Buf         := Store;
      A.Buf_Length  := Size;
      A.Curr_Offset := 0;
   end Arena_Init;

   procedure Alloc_Align
     (A     : in out Arena; P : out Address_Type; Size : Size_Type;
      Align :        Align_Type := Default_Alignment)
   is
      UInt_Addr : Address_Type := A.Buf;
      Curr_Ptr  : Address_Type := UInt_Addr + A.Curr_Offset;
      Offset    : Offset_Type  := Align_Forward (Curr_Ptr, Align) - UInt_Addr;
   begin
      P := To_Integer (System.Null_Address);

      if Offset + Size <= A.Buf_Length then
         P             := UInt_Addr + Offset;
         A.Curr_Offset := Offset + Size;
      end if;
   end Alloc_Align;
end Sparkmemory;
