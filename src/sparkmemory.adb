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
      Curr_Ptr : Address_Type := A.Buf + A.Curr_Offset;
      M        : Offset_Type  := Curr_Ptr mod Align;
      Offset   : Offset_Type;
   begin
      P := To_Integer (System.Null_Address);

      if M /= 0 then
         Curr_Ptr := Curr_Ptr + Align - M;
      end if;

      Offset := Curr_Ptr - A.Buf;

      if Offset < 0 or else Size_Type (Offset_Type'Last - Offset) <= Size then
         return;
      end if;

      if Size_Type (Offset) + Size <= A.Buf_Length then
         P             := A.Buf + Offset;
         A.Curr_Offset := Offset_Type (Size_Type (Offset) + Size);
      end if;
   end Alloc_Align;

   procedure C_Arena_Init
     (A : out Arena; Store : Address_Type; Size : Interfaces.C.size_t)
   is
   begin
      Arena_Init (A, Store, Size);
   end C_Arena_Init;

   procedure C_Arena_Alloc
     (A : in out Arena; Addr : out System.Address; Size : Interfaces.C.size_t;
      Align :        Interfaces.C.size_t)
   is
      Int_Addr : Integer_Address;
   begin
      Addr := System.Null_Address;

      if Align > 0 and then Align mod 2 = 0 then
         Alloc_Align (A, Int_Addr, Size, Align_Type (Align));

         Addr := To_Address (Int_Addr);
      end if;
   end C_Arena_Alloc;
end Sparkmemory;
