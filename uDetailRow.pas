unit uDetailRow;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, System.Skia,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, FMX.Layouts, FMX.Skia;

type
  TFrameDetailRow = class(TFrame)
    DetailImage: TSkAnimatedImage;
    lblTitle: TSkLabel;
    Layout1: TLayout;
  protected
    FImageFilename: string;
    procedure DetailImageClick(Sender: TObject);
    procedure DetailImageTap(Sender: TObject; const Point: TPointF);
    procedure ShowDetailFrame;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Bind(ImageFilename: string);
  end;

implementation

uses
  uCommon, Messaging;

{$R *.fmx}

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
  FImageFilename := ImageFilename;
  if not FileExists(FImageFilename) then
    ShowMessage('File not exists: ' + FImageFilename)
  else
    DetailImage.LoadFromFile(ImageFilename);
end;

procedure TFrameDetailRow.DetailImageClick(Sender: TObject);
begin
  ShowDetailFrame;
end;

procedure TFrameDetailRow.DetailImageTap(Sender: TObject; const Point: TPointF);
begin
  ShowDetailFrame;
end;

procedure TFrameDetailRow.ShowDetailFrame();
var
  Value: TShowDetailMsg;
  Msg: TMessage<TShowDetailMsg>;
begin
  Value.ImageFilename := FImageFilename;
  Msg := TMessage<TShowDetailMsg>.Create(Value);
  TMessageManager.DefaultManager.SendMessage(Self, Msg, True);
end;

end.
