unit uDetailRow;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  FMX.Types,
  FMX.Graphics,
  FMX.Controls,
  FMX.Forms,
  FMX.Dialogs,
  FMX.StdCtrls,
  System.Skia,
  FMX.Layouts,
  FMX.Skia;

type
  TFrameDetailRow = class(TFrame)
    DetailImage: TSkAnimatedImage;
    lblTitle: TSkLabel;
    Layout1: TLayout;
  private
    fImageFilename: string;
    procedure DetailImageClick(Sender: TObject);
    procedure DetailImageTap(Sender: TObject; const Point: TPointF);
    procedure ShowDetailFrame();
  public
    constructor Create(AOwner: TComponent); override;
    procedure Bind(ImageFilename: string);
  end;

implementation

uses
  uCommon,
  Messaging;

{$R *.fmx}

{ TFrameDetail }

constructor TFrameDetailRow.Create(AOwner: TComponent);
begin
  inherited;
  {$IF Defined(MSWindows)}
  DetailImage.OnClick := DetailImageClick;
  {$ELSE if Defined(IOS)}
  DetailImage.OnTap := DetailImageTap;
  {$ELSE}
  raise Exception.Create('Platform not supported');
  {$ENDIF}
end;

procedure TFrameDetailRow.Bind(ImageFilename: string);
begin
  fImageFilename := ImageFilename;
  if not FileExists(fImageFilename) then
  begin
    ShowMessage('File not exists: ' + fImageFilename);
    Exit;
  end;


  DetailImage.LoadFromFile(ImageFilename);
end;

procedure TFrameDetailRow.DetailImageClick(Sender: TObject);
begin
  ShowDetailFrame();
end;

procedure TFrameDetailRow.DetailImageTap(Sender: TObject; const Point: TPointF);
begin
  ShowDetailFrame() ;
end;

procedure TFrameDetailRow.ShowDetailFrame();
begin
  var v:TShowDetailMsg;
  v.ImageFilename := fImageFilename;
  var msg := TMessage<TShowDetailMsg>.Create(v);
  TMessageManager.DefaultManager.SendMessage(self, msg, true)
end;

end.

