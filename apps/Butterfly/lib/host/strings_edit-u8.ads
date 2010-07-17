with Interfaces;
with Strings_Edit.Modular_Edit;
pragma Elaborate_All (Strings_Edit.Modular_Edit);

package Strings_Edit.U8 is
   new Strings_Edit.Modular_Edit (Interfaces.Unsigned_8);
