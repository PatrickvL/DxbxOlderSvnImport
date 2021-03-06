program XBEExplorer;

{$R 'XBEExplorerResources.res' '..\..\resource\XBEExplorerResources.rc'}

uses
  Forms,
  SysUtils,
  uXBEExplorerMain in '..\..\src\XBEExplorer\uXBEExplorerMain.pas' {FormXBEExplorer},
  uXbe in '..\..\src\uXbe.pas',
  uTypes in '..\..\src\uTypes.pas',
  uConsts in '..\..\src\uConsts.pas',
  uDxbxUtils in '..\..\src\uDxbxUtils.pas',
  uLog in '..\..\src\uLog.pas',
  uTime in '..\..\src\uTime.pas',
  uEmuD3D8Types in '..\..\src\DxbxKrnl\uEmuD3D8Types.pas',
  uConsoleClass in '..\..\src\uConsoleClass.pas',
  uHexViewer in '..\..\src\XBEExplorer\uHexViewer.pas' {HexViewer: TFrame},
  uStringsViewer in '..\..\src\XBEExplorer\uStringsViewer.pas',
  uXDVDFS in '..\..\src\uXDVDFS.pas',
  uFileSystem in '..\..\src\uFileSystem.pas',
  uExploreFileSystem in '..\..\src\XBEExplorer\uExploreFileSystem.pas' {frmExploreFileSystem},
  uDisassembleViewer in '..\..\src\XBEExplorer\uDisassembleViewer.pas',
  BeaEngine in '..\..\Libraries\BeaEngine\BeaEngine.pas',
  uSectionViewer in '..\..\src\XBEExplorer\uSectionViewer.pas',
  uViewerUtils in '..\..\src\XBEExplorer\uViewerUtils.pas',
  uDisassembleUtils in '..\..\src\uDisassembleUtils.pas',
  VistaIconFix in '..\..\src\VistaIconFix.pas',
  uCRC16 in '..\..\src\uCRC16.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormXBEExplorer, FormXBEExplorer);
  Application.Title := FormXBEExplorer.Caption;
  if ParamCount > 0 then
    if FileExists(ParamStr(1)) then
      FormXBEExplorer.OpenFile(ParamStr(1));

  Application.Run;
end.

