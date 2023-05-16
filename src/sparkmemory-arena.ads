package Sparkmemory.Arena with
   SPARK_Mode => On
is
   type Arena is private;

   -- XXX: gnatprove issues a warning about the initial value of A not being
   -- used. Which is true, but I need to create it in C and I can't get
   -- just out (vs in out) params to work right with Ada <-> C.
   procedure Init (A : out Arena; Store : Address_Type; Size : Size_Type) with
      Global => null,
      Pre    => Store /= 0;

   function Is_Initialized (A : Arena) return Boolean with
      Ghost;

   procedure Alloc_Align
     (A     : in out Arena; P : out Address_Type; Size : Size_Type;
      Align :        Align_Type) with
      Global => null,
      Pre    => Is_Initialized (A) and then Align mod 2 = 0 and then Size /= 0;

   procedure Free_All (A : in out Arena);

   package C with
      -- respect the C idiom of returning a pointer and modifying a state,
      -- for better or worse :)
      SPARK_Mode => Off
   is
      -- XXX This function can actually be done through SPARK, come back.
      procedure Arena_Init
        (A    : in out Arena; Store : Address_Type;
         Size :        Interfaces.C.size_t) with
         Export        => True,
         Convention    => C,
         External_Name => "arena_init";

      procedure Arena_Free_All (A : in out Arena) with
         Export        => True,
         Convention    => C,
         External_Name => "arena_free_all";

      function Arena_Alloc
        (A     : in out Arena; Size : Interfaces.C.size_t;
         Align :        Interfaces.C.size_t) return System.Address with
         Export        => True,
         Convention    => C,
         External_Name => "arena_alloc";
   end C;

private
   type Arena is record
      Buf         : Address_Type := 0;
      Buf_Length  : Size_Type    := 0;
      Curr_Offset : Offset_Type  := 0;
   end record with
      Convention => C;
end Sparkmemory.Arena;
