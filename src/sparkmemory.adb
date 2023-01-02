package body Sparkmemory with
   SPARK_Mode => On
is
   procedure Arena_Init (A : out Arena; Store : Address_Type; Size : Size_Type)
   is
   begin
      A.Buf         := Store;
      A.Buf_Length  := Size;
      A.Curr_Offset := 0;
   end Arena_Init;

   procedure Alloc_Align
     (A     : in out Arena; P : out Address_Type; Size : Size_Type;
      Align :        Align_Type)
   is
      UInt_Addr : Address_Type := A.Buf;
      Curr_Ptr  : Address_Type := UInt_Addr + A.Curr_Offset;
      M         : Address_Type := Curr_Ptr mod Align;
      Offset    : Offset_Type;
   begin
      P := To_Integer (System.Null_Address);

      if M /= 0 then
         Curr_Ptr := Curr_Ptr + Align - M;
      end if;

      Offset := Curr_Ptr - UInt_Addr;

      if Offset + Size <= A.Buf_Length then
         P             := UInt_Addr + Offset;
         A.Curr_Offset := Offset + Size;
      end if;
   end Alloc_Align;

   procedure Alloc
     (A : in out Arena; Addr : out System.Address; Size : Interfaces.C.size_t;
      Align :        Interfaces.C.size_t)
   is
      P : Address_Type;
   begin
      Addr := System.Null_Address;

      if Align < 1 or else Align mod 2 /= 0 then
         return;
      end if;

      Alloc_Align (A, P, Size_Type (Size), Align_Type (Align));
      Addr := To_Address (P);
   end Alloc;

end Sparkmemory;
