package body Sparkmemory with
   SPARK_Mode => On
is
   procedure Arena_Init
     (A : in out Arena; Store : Address_Type; Size : Size_Type)
   is
   begin
      A.Buf         := Store;
      A.Buf_Length  := Size;
      A.Curr_Offset := 0;
   end Arena_Init;

   procedure Arena_Free_All (A : in out Arena) is
   begin
      A.Curr_Offset := 0;
   end Arena_Free_All;

   procedure Alloc_Align
     (A     : in out Arena; P : out Address_Type; Size : Size_Type;
      Align :        Align_Type) with
      Refined_Post =>
      (P = To_Integer (System.Null_Address)
       or else P > A'Old.Buf + A'Old.Curr_Offset)
   is
      Curr_Ptr : Address_Type         := A.Buf + A.Curr_Offset;
      M        : constant Offset_Type := Curr_Ptr mod Align;
      Offset   : Offset_Type;
   begin
      P := To_Integer (System.Null_Address);

      if M /= 0 then
         Curr_Ptr := Curr_Ptr + Align - M;
      end if;

      Offset := Curr_Ptr - A.Buf;

      if Size_Type (Offset_Type'Last - Offset) <= Size then
         return;
      end if;

      if Size_Type (Offset) + Size <= A.Buf_Length then
         P             := A.Buf + Offset;
         A.Curr_Offset := Offset_Type (Size_Type (Offset) + Size);
      end if;

   end Alloc_Align;

   package body C with
      SPARK_Mode => Off
   is
      procedure Arena_Free_All (A : in out Arena) is
      begin
         Sparkmemory.Arena_Free_All (A);
      end Arena_Free_All;

      procedure Arena_Init
        (A : in out Arena; Store : Address_Type; Size : Interfaces.C.size_t)
      is
      begin

         Sparkmemory.Arena_Init (A, Store, Size);
      end Arena_Init;

      function Arena_Alloc
        (A     : in out Arena; Size : Interfaces.C.size_t;
         Align :        Interfaces.C.size_t) return System.Address
      is
         Int_Addr : Integer_Address;
      begin
         if Align > 0 and then Align mod 2 = 0 and then Size > 0 then
            Sparkmemory.Alloc_Align (A, Int_Addr, Size, Align_Type (Align));

            return To_Address (Int_Addr);
         end if;

         return System.Null_Address;
      end Arena_Alloc;
   end C;
end Sparkmemory;
