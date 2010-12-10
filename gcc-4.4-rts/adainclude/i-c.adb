package body Interfaces.C is

   function To_C (Item : Character) return char
   is
   begin
      return char (Item);
   end To_C;

   function To_Ada (Item : char) return Character
   is
   begin
      return Character (Item);
   end To_Ada;

   function To_C (Item : Wide_Character) return wchar_t
   is
   begin
      return wchar_t (Item);
   end To_C;

   function To_Ada (Item : wchar_t) return Wide_Character
   is
   begin
      return Wide_Character (Item);
   end To_Ada;

   function To_C (Item : Wide_Character) return char16_t
   is
   begin
      return char16_t (Item);
   end To_C;

   function To_Ada (Item : char16_t) return Wide_Character
   is
   begin
      return Wide_Character (Item);
   end To_Ada;

   function To_C (Item : Wide_Wide_Character) return char32_t
   is
   begin
      return char32_t (Item);
   end To_C;

   function To_Ada (Item : char32_t) return Wide_Wide_Character
   is
   begin
      return Wide_Wide_Character (Item);
   end To_Ada;

end Interfaces.C;
