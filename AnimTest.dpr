program AnimTest;

uses
  System.StartUpCopy,
  FMX.Forms,
  FMX.Types,
  FMX.Skia,
  uMain in 'uMain.pas' {frmMain},
  uDetailRow in 'uDetailRow.pas' {FrameDetailRow: TFrame},
  uDetailShow in 'uDetailShow.pas' {FrameShowDetail: TFrame},
  uCommon in 'uCommon.pas';

{$R *.res}

begin

  {$IF Defined(MSWINDOWS)}
    GlobalUseSkia := true;
  {$ELSEIF Defined(IOS)}
    GlobalUseSkia := true;
    GlobalUseMetal := true;
  {$ELSEIF Defined(MACOS)}
    GlobalUseSkia := true;
    GlobalUseMetal := true;
  {$ELSEIF Defined(ANDROID)}
    GlobalUseSkia := true;
    GlobalUseVulkan := true;
  {$ENDIF}


  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
