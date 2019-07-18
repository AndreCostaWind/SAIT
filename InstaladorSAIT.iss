; SAIT
; Inno Setup file

#define MyAppName "SAIT"
#define MyAppVersion "0.0.0"
#define MyAppPublisher "Wind Net"
#define MyAppURL "http://www.wind.net.br"

#define MyEXEName "SAIT"
#define MyAppExeName "SAIT.exe"

#define MyAppUnistall "Unistall"
#define MyAppUnistallName "unins000.exe"

[Setup]
AppId = {{3A77DF7F-1ADA-4D6A-8BC9-83068B2CD1D5}
AppName = {#MyAppName}
AppVersion = {#MyAppVersion}
AppVerName = {#MyAppName} {#MyAppVersion}
AppPublisher = {#MyAppPublisher}
AppPublisherURL = {#MyAppURL}
AppSupportURL = {#MyAppURL}
AppUpdatesURL = {#MyAppURL}
DefaultDirName = {pf}\{#MyAppName}
DisableProgramGroupPage = no
;LicenseFile = C:\Deposito\Projetos\Produtos\SAIT\Fontes\licensa.txt
OutputDir = C:\Deposito\Projetos\Produtos\SAIT\Fontes
OutputBaseFilename = SAIT_Installer
SetupIconFile = C:\Deposito\Projetos\Produtos\SAIT\Fontes\SAIT.ico
Compression = lzma
SolidCompression = yes
PrivilegesRequired = admin
MinVersion = 5
DisableDirPage=false
AllowUNCPath=false

[Languages]
Name: "en"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; 

[Files]
Source: "C:\Deposito\Projetos\Produtos\SAIT\Fontes\SAIT.exe"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{#MyAppName}\{cm:ProgramOnTheWeb,{#MyAppPublisher}}"; Filename: "{#MyAppURL}"

Name: "{commonprograms}\{#MyAppName}\{#MyEXEName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{commondesktop}\{#MyEXEName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

Name: "{commonprograms}\{#MyAppName}\{#MyAppUnistall}"; Filename: "{app}\{#MyAppUnistallName}"

[Run]
;Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange({#MyAppExeName}, '&', '&&')}}"; Flags: nowait postinstall skipifsilent

[Registry]
Root: HKCU; SubKey: {#MyAppPublisher}; ValueType: dword; ValueName: {#MyAppName}; ValueData: 1;

[UninstallDelete]
Type: files; Name: "{app}";

[Code]
// o nome do método define a ordem de inicialização. Tem que usar os nomes já pre programados no inno.
function InitializeSetup(): Boolean;
begin
  try    
    DelTree('{app}\*', False, True, True);
    MsgBox('Welcome to the Simple Annotation Image Tool (SAIT) installer.', mbInformation, MB_OK);   

   except
    MsgBox('Failed to delete old files. Please close the current version of SAIT...', mbInformation, MB_OK);
  end;
  Result := True;
end;

