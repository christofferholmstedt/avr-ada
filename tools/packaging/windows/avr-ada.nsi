;  Copyright (c) 2006 Bernd Trog <berndtrog@yahoo.com>

;  This program is free software; you can redistribute it and/or Modify
;  it under the terms of the GNU General Public License as published By
;  the Free Software Foundation; either version 2 of the License, or
;  (at your option) any later version.

;  !define PREFIX "$%PREFIX%"
  !define READ_PATH "c:\temp\avr-ada-dist\"
  !define date "$%DATE%"
  !define VERSION "0.5.0"
  !define VERSION_EXT " (pre1)"

  Name "AVR-Ada ${VERSION}${VERSION_EXT}"

  OutFile "avr-ada-V${VERSION}.exe"
  InstallDir "$PROGRAMFILES\AVR-Ada-V${VERSION}"
  

SetDatablockOptimize on
SetCompressor /SOLID LZMA
SetCompressorDictSize 70
SetDateSave OFF


  !include "MUI.nsh"
  !insertmacro MUI_PAGE_WELCOME
  !insertmacro MUI_PAGE_LICENSE "${READ_PATH}/COPYING.txt"
  !insertmacro MUI_PAGE_COMPONENTS
  !insertmacro MUI_PAGE_DIRECTORY
  !insertmacro MUI_PAGE_INSTFILES
  !insertmacro MUI_PAGE_FINISH
  
  !insertmacro MUI_UNPAGE_WELCOME
  !insertmacro MUI_UNPAGE_CONFIRM
  !insertmacro MUI_UNPAGE_INSTFILES
  !insertmacro MUI_UNPAGE_FINISH

  !insertmacro MUI_LANGUAGE "English" # first language is the default language
  !insertmacro MUI_LANGUAGE "French"
  !insertmacro MUI_LANGUAGE "German"
  !insertmacro MUI_LANGUAGE "Spanish"
  !insertmacro MUI_LANGUAGE "SimpChinese"
  !insertmacro MUI_LANGUAGE "TradChinese"
  !insertmacro MUI_LANGUAGE "Japanese"
  !insertmacro MUI_LANGUAGE "Korean"
  !insertmacro MUI_LANGUAGE "Italian"
  !insertmacro MUI_LANGUAGE "Dutch"
  !insertmacro MUI_LANGUAGE "Danish"
  !insertmacro MUI_LANGUAGE "Swedish"
  !insertmacro MUI_LANGUAGE "Norwegian"
  !insertmacro MUI_LANGUAGE "Finnish"
  !insertmacro MUI_LANGUAGE "Greek"
  !insertmacro MUI_LANGUAGE "Russian"
  !insertmacro MUI_LANGUAGE "Portuguese"
  !insertmacro MUI_LANGUAGE "PortugueseBR"
  !insertmacro MUI_LANGUAGE "Polish"
  !insertmacro MUI_LANGUAGE "Ukrainian"
  !insertmacro MUI_LANGUAGE "Czech"
  !insertmacro MUI_LANGUAGE "Slovak"
  !insertmacro MUI_LANGUAGE "Croatian"
  !insertmacro MUI_LANGUAGE "Bulgarian"
  !insertmacro MUI_LANGUAGE "Hungarian"
  !insertmacro MUI_LANGUAGE "Thai"
  !insertmacro MUI_LANGUAGE "Romanian"
  !insertmacro MUI_LANGUAGE "Latvian"
  !insertmacro MUI_LANGUAGE "Macedonian"
  !insertmacro MUI_LANGUAGE "Estonian"
  !insertmacro MUI_LANGUAGE "Turkish"
  !insertmacro MUI_LANGUAGE "Lithuanian"
  !insertmacro MUI_LANGUAGE "Slovenian"
  !insertmacro MUI_LANGUAGE "Serbian"
  !insertmacro MUI_LANGUAGE "SerbianLatin"
  !insertmacro MUI_LANGUAGE "Arabic"
  !insertmacro MUI_LANGUAGE "Farsi"
  !insertmacro MUI_LANGUAGE "Hebrew"
  !insertmacro MUI_LANGUAGE "Indonesian"
  !insertmacro MUI_LANGUAGE "Mongolian"
  !insertmacro MUI_LANGUAGE "Luxembourgish"
  !insertmacro MUI_LANGUAGE "Albanian"
  !insertmacro MUI_LANGUAGE "Breton"

  !insertmacro MUI_RESERVEFILE_LANGDLL

  !define MUI_ABORTWARNING
  
  !insertmacro MUI_RESERVEFILE_INSTALLOPTIONS

Section "Compiler & Tools" SecMain 
  SetOutPath $INSTDIR
  
  WriteUninstaller "$INSTDIR\Uninstall.exe"
  WriteRegStr HKCU "Software\AVR-Ada" "" $INSTDIR
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\AVR-Ada" "DisplayName" "AVR-Ada"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\AVR-Ada" "UninstallString" '"$INSTDIR\Uninstall.exe"'

  File /r ${READ_PATH}\*

  Push "$INSTDIR\avr\ada\avr.gpr" 
    Push "   RTS_BASE :="
    Push '   RTS_BASE := "$INSTDIR\lib\gcc\avr\4.2.0";' 
  Call ReplaceLineStr
 
  Push "$INSTDIR\setpath.bat" 
    Push "set Path=xyz;"
    Push "set Path=$INSTDIR\bin;$INSTDIR\utils\bin;%Path%" 
  Call ReplaceLineStr
 
  Exec '"$SYSDIR\attrib.exe" +R $INSTDIR\avr\ada\*.* /S /D'
SectionEnd

Section "Add Directories to Path" SecPath

  SetOutPath "$INSTDIR"
  
  push "$INSTDIR\bin;$INSTDIR\utils\bin"
  Call AddToPath

SectionEnd

Function .onInit
  !insertmacro MUI_LANGDLL_DISPLAY
FunctionEnd

Function un.onInit
  !insertmacro MUI_UNGETLANGUAGE
FunctionEnd

LangString TEXT_IO_TITLE ${LANG_ENGLISH} "InstallOptions page"
LangString TEXT_IO_SUBTITLE ${LANG_ENGLISH} "This is a page created using the InstallOptions plug-in."


  LangString DESC_SecMain ${LANG_ENGLISH} "Ada, C, C++ Compiler and Tools"
  LangString DESC_SecPath ${LANG_ENGLISH} "Add the installed bin/ directories to the Path Environment Variable"

  !insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
    !insertmacro MUI_DESCRIPTION_TEXT ${SecMain} $(DESC_SecMain)
    !insertmacro MUI_DESCRIPTION_TEXT ${SecPath} $(DESC_SecPath)
  !insertmacro MUI_FUNCTION_DESCRIPTION_END

Section "Uninstall"
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\AVR-Ada"

  Delete "$INSTDIR\Uninstall.exe"

  Exec '"$SYSDIR\attrib.exe" -R $INSTDIR\avr\ada\*.* /S /D'
  RMDir /r "$INSTDIR"
  Delete "$INSTDIR"

  DeleteRegKey /ifempty HKCU "Software\AVR-Ada"

  push "$INSTDIR\bin;$INSTDIR\utils\bin"
  Call un.RemoveFromPath
SectionEnd


Function ReplaceLineStr
 Exch $R0
 Exch
 Exch $R1
 Exch
 Exch 2
 Exch $R2
 Push $R3
 Push $R4
 Push $R5
 Push $R6
 Push $R7
 Push $R8
 Push $R9
 
  StrLen $R7 $R1
 
  GetTempFileName $R4
 
  FileOpen $R5 $R4 w
  FileOpen $R3 $R2 r
 
  ReadLoop:
  ClearErrors
   FileRead $R3 $R6
    IfErrors Done
 
   StrLen $R8 $R6
   StrCpy $R9 $R6 $R7 -$R8
   StrCmp $R9 $R1 0 +3
 
    FileWrite $R5 "$R0$\r$\n"
    Goto ReadLoop
 
    FileWrite $R5 $R6
    Goto ReadLoop
 
  Done:
 
  FileClose $R3
  FileClose $R5
 
  SetDetailsPrint none
   Delete $R2
   Rename $R4 $R2
  SetDetailsPrint both
 
 Pop $R9
 Pop $R8
 Pop $R7
 Pop $R6
 Pop $R5
 Pop $R4
 Pop $R3
 Pop $R2
 Pop $R1
 Pop $R0
FunctionEnd


!macro select_NT_profile UN
Function ${UN}select_NT_profile

   MessageBox MB_YESNO|MB_ICONQUESTION "Change the environment for all users? \
Saying no here will change the environment for the current user only. \
(Administrator permissions required for all users)" \
      IDNO environment_single
      DetailPrint "Selected environment for all users"
      Push "all"
      Return
   environment_single:
      DetailPrint "Selected environment for current user only."
      Push "current"
      Return
FunctionEnd
!macroend

!insertmacro select_NT_profile ''

!define NT_current_env 'HKCU "Environment"'
!define NT_all_env     'HKLM "SYSTEM\CurrentControlSet\Control\Session Manager\Environment"'


!macro IsNT UN
Function ${UN}IsNT
  Push $0
  ReadRegStr $0 HKLM "SOFTWARE\Microsoft\Windows NT\CurrentVersion" CurrentVersion
  StrCmp $0 "" 0 IsNT_yes
  Pop $0
  Push 0
  Return
 
  IsNT_yes:
    Pop $0
    Push 1
FunctionEnd

!macroend
!insertmacro IsNT ""
!insertmacro IsNT "un."

Function AddToPath
   Exch $0
   Push $1
   Push $2
  
   Call IsNT
   Pop $1
   StrCmp $1 1 AddToPath_NT
      StrCpy $1 $WINDIR 2
      FileOpen $1 "$1\autoexec.bat" a
      FileSeek $1 0 END
      GetFullPathName /SHORT $0 $0
      FileWrite $1 "$$SET PATH=%PATH%;$0$$"
      FileClose $1
      Goto AddToPath_done
 
   AddToPath_NT:
      Push $4
      Call select_NT_profile
      Pop  $4
 
      AddToPath_NT_selection_done:
      StrCmp $4 "current" read_path_NT_current
         ReadRegStr $1 ${NT_all_env} "PATH"
         Goto read_path_NT_resume
      read_path_NT_current:
         ReadRegStr $1 ${NT_current_env} "PATH"
      read_path_NT_resume:
         StrCpy $2 "$0;$1"
      AddToPath_NTdoIt:
         StrCmp $4 "current" write_path_NT_current
            ClearErrors
            WriteRegExpandStr ${NT_all_env} "PATH" $2
            IfErrors 0 write_path_NT_resume
            MessageBox MB_YESNO|MB_ICONQUESTION "The path could not be set for all users$$Should I try for the current user?" \
               IDNO write_path_NT_failed

            StrCpy $4 "current"
            Goto AddToPath_NT_selection_done
         write_path_NT_current:
            ClearErrors
            WriteRegExpandStr ${NT_current_env} "PATH" $2
            IfErrors 0 write_path_NT_resume
            MessageBox MB_OK|MB_ICONINFORMATION "The path could not be set for the current user."
            Goto write_path_NT_failed
         write_path_NT_resume:
         SendMessage ${HWND_BROADCAST} ${WM_WININICHANGE} 0 "STR:Environment" /TIMEOUT=5000
         DetailPrint "added path for user ($4), $0"
         write_path_NT_failed:
      
      Pop $4
   AddToPath_done:
   Pop $2
   Pop $1
   Pop $0
FunctionEnd
 
Function un.RemoveFromPath
   Exch $0
   Push $1
   Push $2
   Push $3
   Push $4
   
   Call un.IsNT
   Pop $1
   StrCmp $1 1 unRemoveFromPath_NT

      StrCpy $1 $WINDIR 2
      FileOpen $1 "$1\autoexec.bat" r
      GetTempFileName $4
      FileOpen $2 $4 w
      GetFullPathName /SHORT $0 $0
      StrCpy $0 "SET PATH=%PATH%;$0"
      SetRebootFlag true
      Goto unRemoveFromPath_dosLoop
     
      unRemoveFromPath_dosLoop:
         FileRead $1 $3
         StrCmp $3 "$0$$" unRemoveFromPath_dosLoop
         StrCmp $3 "$0$" unRemoveFromPath_dosLoop
         StrCmp $3 "$0" unRemoveFromPath_dosLoop
         StrCmp $3 "" unRemoveFromPath_dosLoopEnd
         FileWrite $2 $3
         Goto unRemoveFromPath_dosLoop
 
      unRemoveFromPath_dosLoopEnd:
         FileClose $2
         FileClose $1
         StrCpy $1 $WINDIR 2
         Delete "$1\autoexec.bat"
         CopyFiles /SILENT $4 "$1\autoexec.bat"
         Delete $4
         Goto unRemoveFromPath_done
 
   unRemoveFromPath_NT:
      StrLen $2 $0
 
      StrCmp $4 "current" un_read_path_NT_current
         ReadRegStr $1 ${NT_all_env} "PATH"
         Goto un_read_path_NT_resume
      un_read_path_NT_current:
         ReadRegStr $1 ${NT_current_env} "PATH"
      un_read_path_NT_resume:
 
      Push $1
      Push $0
      Call un.StrStr
      Pop $0 
      IntCmp $0 -1 unRemoveFromPath_done
         
         StrCpy $3 $1 $0 
         IntOp $2 $2 + $0
         IntOp $2 $2 + 1 
         StrLen $0 $1
         StrCpy $1 $1 $0 $2
         StrCpy $3 "$3$1"
 
         StrCmp $4 "current" un_write_path_NT_current
            WriteRegExpandStr ${NT_all_env} "PATH" $3
            Goto un_write_path_NT_resume
         un_write_path_NT_current:
            WriteRegExpandStr ${NT_current_env} "PATH" $3
         un_write_path_NT_resume:
         SendMessage ${HWND_BROADCAST} ${WM_WININICHANGE} 0 "STR:Environment" /TIMEOUT=5000
   unRemoveFromPath_done:
   Pop $4
   Pop $3
   Pop $2
   Pop $1
   Pop $0
FunctionEnd


Function un.StrStr
  Push $0
  Exch
  Pop $0 
  Push $1
  Exch 2
  Pop $1 
  Exch
  Push $2
  Push $3
  Push $4
  Push $5
 
  StrCpy $2 -1
  StrLen $3 $0
  StrLen $4 $1
  IntOp $4 $4 - $3
 
  unStrStr_loop:
    IntOp $2 $2 + 1
    IntCmp $2 $4 0 0 unStrStrReturn_notFound
    StrCpy $5 $1 $3 $2
    StrCmp $5 $0 unStrStr_done unStrStr_loop
 
  unStrStrReturn_notFound:
    StrCpy $2 -1
 
  unStrStr_done:
    Pop $5
    Pop $4
    Pop $3
    Exch $2
    Exch 2
    Pop $0
    Pop $1
FunctionEnd
