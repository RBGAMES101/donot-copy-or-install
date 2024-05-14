!include "MUI2.nsh"
!define MUI_ICON "icon.ico"
!define MUI_UNICON "icon.ico"
!define MUI_COMPONENTSPAGE_SMALLDESC
!define MUI_FINISHPAGE_NOAUTOCLOSE
!define MUI_UNFINISHPAGE_NOAUTOCLOSE
!define MUI_INSTFILESPAGE_COLORS "FFFFFF 000000"
RequestExecutionLevel user
Name "SandPile"
Icon "icon.ico"
!define MUI_PAGE_HEADER_TEXT "SandPile Installer"
!define MUI_WELCOMEPAGE_TITLE "SandPile Installer"
!define MUI_WELCOMEPAGE_TEXT "Click the install button below to install the SandPile client!"
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH
!insertmacro MUI_UNPAGE_WELCOME
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH
!insertmacro MUI_LANGUAGE "English"
Function .onInit
    SetShellVarContext all
FunctionEnd

Section
    SetRegView 64

    ; Create registry key
    WriteRegStr HKCU "Software\Classes\sandpile.legacy" "URL Protocol" ""

    ; Set registry value
    WriteRegStr HKCU "Software\Classes\sandpile.legacy\shell\open\command" "" "$PROFILE\AppData\Local\Programs\SandPile\autoupdater.exe %1"
    ; Create directories

    CreateDirectory "$PROFILE\AppData\Local\Programs\SandPile"
    CreateDirectory "$PROFILE\AppData\Roaming\SandPile"
    DetailPrint "Writing registry keys..."
    WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\SandPile" \
                 "DisplayName" "SandPile Client"
    WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\SandPile" \
                 "UninstallString" "$\"$PROFILE\AppData\Local\Programs\SandPile\uninstall.exe$\""
    WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\SandPile" \
                 "DisplayIcon" "$\"$PROFILE\AppData\Local\Programs\SandPile\uninstall.exe$\""
    WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\SandPile" \
                 "Publisher" "SandPile"
    WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\SandPile" \
                 "URLInfoAbout" "https://sandpile.xyz"
    WriteRegDword HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\SandPile" \
                 "NoModify" 1
    WriteRegDword HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\SandPile" \
                 "NoRepair" 1
    WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\SandPile" \
                 "Comments" "The SandPile Client."
    DetailPrint "Successfully wrote registry keys."
    ; Download file
    DetailPrint "Downloading autoupdater.exe..."
    inetc::get "https://sandpile.xyz/static/autoupdater.exe" "$PROFILE\AppData\Local\Programs\SandPile\autoupdater.exe"
    Pop $R0
    StrCmp $R0 "OK" 0 +2
    DetailPrint "Download successful."
    WriteUninstaller "$PROFILE\AppData\Local\Programs\SandPile\uninstall.exe"

SectionEnd

Section Uninstall
    FindProcDLL::FindProc "Player.exe"
    IntCmp $R0 1 0 notRunning
        MessageBox MB_OK|MB_ICONEXCLAMATION "The SandPile client is running. Please close it first" /SD IDOK
        Abort
    notRunning:
    FindProcDLL::FindProc "autoupdater.exe"
    IntCmp $R0 1 0 notRunning2
        MessageBox MB_OK|MB_ICONEXCLAMATION "The SandPile autoupdater is running. Please close it first" /SD IDOK
        Abort
    notRunning2:
    SetRegView 64
    DetailPrint "Deleting autoupdater directory..."
    RMDir /r /REBOOTOK "$PROFILE\AppData\Local\Programs\SandPile"
    DetailPrint "Successfully deleted autoupdater directory."
    DetailPrint "Deleting client directory..."
    RMDir /r /REBOOTOK "$PROFILE\AppData\Roaming\SandPile"
    DetailPrint "Successfully deleted client directory."
    DetailPrint "Deleting registry keys..."
    DeleteRegKey HKCU "Software\Classes\sandpile.legacy"
    DeleteRegKey HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\SandPile"
    DetailPrint "Successfully removed registry keys."



SectionEnd