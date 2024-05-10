unit uDetailShow;

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
  FMX.Controls.Presentation,
  FMX.Skia,
  FMX.Layouts;

type
  TFrameShowDetail = class(TFrame)
    DetailImage: TSkAnimatedImage;
    Layout1: TLayout;
    lblTitle: TSkLabel;
    Button1: TButton;
    VertScrollBox1: TVertScrollBox;
    SkLabel1: TSkLabel;
  private
  public
    procedure Bind(ImageFilename: string);
  end;

implementation

{$R *.fmx}

procedure TFrameShowDetail.Bind(ImageFilename: string);
begin
  DetailImage.LoadFromFile(ImageFilename);
end;

end.

