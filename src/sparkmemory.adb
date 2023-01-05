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

   -- Computes A mod B, quickly, if B is a power of 2.
   function Fast_Mod
     (A : Integer_Address; B : Integer_Address) return Integer_Address is
     (A and (B - 1)) with
      Inline => True,
      Pre    => B >= 2 and then B mod 2 = 0,
      Post   => Fast_Mod'Result >= 0 and then Fast_Mod'Result < B;
      -- XXX and then Fast_Mod'Result == A mod B

   function Align_Forward
     (Ptr : Address_Type; Align : Align_Type) return Address_Type with
      Pre => Ptr > 0 and then Align mod 2 = 0
      and then Address_Type'Last - Ptr >= Align,
      Post => Align_Forward'Result >= Ptr
   is
      M : constant Integer_Address := Fast_Mod (Ptr, Align);
   begin
      if M = 0 then
         return Ptr;
      else
         return Ptr + Align - M;
      end if;
   end Align_Forward;

   function Is_Initialized (A : Arena) return Boolean is -- Ghost
     (A.Buf > 0 and then A.Buf_Length > 0);

   function Address_Is_Reasonable
     (A : Arena; Align : Align_Type) return Boolean is
     (Address_Type'Last - A.Buf >= A.Curr_Offset
      and then Address_Type'Last - (A.Buf + A.Curr_Offset) >= Align) with
      Inline => True;

   procedure Alloc_Align
     (A     : in out Arena; P : out Address_Type; Size : Size_Type;
      Align :        Align_Type) with
      Refined_Post => P = 0 or else (P >= A.Buf + A'Old.Curr_Offset)
   is
      Curr_Ptr       : Address_Type;
      Aligned_Offset : Offset_Type;
      New_Offset     : Offset_Type;
   begin
      P := 0;

      if not Address_Is_Reasonable (A, Align) then
         return;
      end if;

      Curr_Ptr       := A.Buf + A.Curr_Offset;
      Aligned_Offset := Align_Forward (Curr_Ptr, Align) - A.Buf;

      if Offset_Type'Last - Aligned_Offset < Size then
         return;
      end if;

      New_Offset := Aligned_Offset + Size;

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

            if Addr = 0 then
               return System.Null_Address;
            end if;

            return To_Address (Addr);
         end if;

         return System.Null_Address;
      end Arena_Alloc;
   end C;
end Sparkmemory;
