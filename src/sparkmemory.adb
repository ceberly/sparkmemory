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

   function Align_Forward
     (Ptr : Address_Type; Align : Align_Type) return System.Address with
      Pre  => Ptr mod 2 = 0,
      Post => Align_Forward'Result >= Ptr
   is
      P : constant Integer_Address := To_Integer (Ptr);
      A : constant Integer_Address := Integer_Address (Align);
      M : constant Integer_Address := P mod A;
   begin
      if M = 0 then
         return To_Address (P);
      else
         return To_Address (P + A - M);
      end if;
   end Align_Forward;

   procedure Alloc_Align
     (A     : in out Arena; P : out Address_Type; Size : Size_Type;
      Align :        Align_Type)
   is
      Aligned_Ptr : constant System.Address :=
        Align_Forward (A.Buf + A.Curr_Offset, Align);
      Aligned_Offset : constant Offset_Type := Aligned_Ptr - A.Buf;
      New_Offset     : constant Offset_Type := Aligned_Offset + Size;
   begin
      P := System.Null_Address;

      if New_Offset <= A.Buf_Length then
         P             := A.Buf + Aligned_Offset;
         A.Curr_Offset := New_Offset;
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

         Sparkmemory.Arena_Init (A, Store, Size_Type (Size));
      end Arena_Init;

      function Arena_Alloc
        (A     : in out Arena; Size : Interfaces.C.size_t;
         Align :        Interfaces.C.size_t) return System.Address
      is
         Addr : Address_Type;
      begin
         if Align > 0 and then Align mod 2 = 0 and then Size > 0 then
            Sparkmemory.Alloc_Align
              (A, Addr, Size_Type (Size), Align_Type (Align));

            return Addr;
         end if;

         return System.Null_Address;
      end Arena_Alloc;
   end C;
end Sparkmemory;
