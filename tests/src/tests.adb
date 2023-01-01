with Sparkmemory; use Sparkmemory;

with System;
with System.Storage_Elements; use System.Storage_Elements;

with Ada.Text_IO; use Ada.Text_IO;

procedure Tests is
   A : Arena;
   Store : Storage_Array (0 .. 1024) := (others => 0);
   Addr : System.Address := System.Null_Address;
begin
   Arena_Init (A, Store'Address, Store'Length);

   Alloc_Align (A, Addr, Integer'Size, Integer'Size);

   declare
      V : Integer := 100 with Address => Addr;
   begin
      Put_Line (Integer_Address'Image (To_Integer (Addr)));
      Put_Line (Integer_Address'Image (To_Integer (V'Address)));
      Put_Line (Integer'Image (V));
   end;
end Tests;
