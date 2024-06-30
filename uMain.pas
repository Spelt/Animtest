unit uMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, System.Generics.Collections, System.Actions,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts,
  FMX.TabControl, FMX.ActnList, FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListView.Adapters.Base, FMX.ListView,
  uDetailRow, uDetailShow, FMX.ListBox, FMX.Edit, FMX.EditBox, FMX.NumberBox,
   FMX.Platform, FMX.Objects;

type
  TfrmMain = class(TForm)
    VertScrollBoxMain: TVertScrollBox;
    ToolbarTop: TToolBar;
    btnLoadPlainVertbox: TToolBar;
    btnPlainVBox: TButton;
    TabControlMain: TTabControl;
    TabItemVPlain: TTabItem;
    TabItemDetail: TTabItem;
    btnBack: TButton;
    TabItemListbox: TTabItem;
    btnListbox: TButton;
    btnClearList: TButton;
    ListBox1: TListBox;
    ListBoxItem1: TListBoxItem;
    GridPanelLayout1: TGridPanelLayout;
    SpeedButtonWaikaLight: TSpeedButton;
    Label1: TLabel;
    Rectangle2: TRectangle;
    SpeedButtonWaikaDark: TSpeedButton;
    Label2: TLabel;
    Rectangle1: TRectangle;
    ListBoxItem2: TListBoxItem;
    LayoutCategorySelection: TLayout;
    btnCatPositionLeft: TButton;
    btnCatPositionAsButton: TButton;
    Label5: TLabel;
    liVisitorSummaryOptions: TListBoxItem;
    Layout1: TLayout;
    BOButtonVisitorHistoryUnDocked: TButton;
    BOButtonVisitorHistoryDocked: TButton;
    Label6: TLabel;
    ListBoxItemProgramView: TListBoxItem;
    Layout2: TLayout;
    BOButtonGridView: TButton;
    BOButtonListView: TButton;
    Label7: TLabel;
    ListBoxItem3: TListBoxItem;
    nbHoursPastShow: TNumberBox;
    ListboxItemReservationPreference: TListBoxItem;
    Layout3: TLayout;
    btnAutoSelectReservationYes: TButton;
    btnAutoSelectReservationNo: TButton;
    Label3: TLabel;
    ListBoxItemPrintDefaultHorecaRetail: TListBoxItem;
    Layout4: TLayout;
    btnPrintHorecaYes: TButton;
    btnPrintHorecaNo: TButton;
    Label4: TLabel;
    Timer1: TTimer;
    lblFps: TLabel;
    StyleBook1: TStyleBook;
    procedure btnPlainVBoxClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnBackClick(Sender: TObject);
    procedure btnClearListClick(Sender: TObject);
    procedure btnListboxClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    FRenderTime: Single;
    FFrameCount: Integer;
    FUpdateRects: array of TRectF;
    FTimerService: IFMXTimerService;
    FFps: Single;
  protected const
    ItemsCount: Integer = 50;
  protected
    FPlainList: TObjectList<TFrameDetailRow>;
    FFrameShowDetail: TFrameShowDetail;
    ToScrollListView, ToScrollVertBox: Integer;
    procedure FillPlain;
    procedure ShowDetail(const aImageFilename: string);
    function GetImageFolder: string;
    procedure PaintRects(const UpdateRects: array of TRectF); override;
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

uses
  IOUtils, uCommon, Messaging;

{$R *.fmx}

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  ToScrollListView := 0;
  ToScrollVertBox := 0;
  btnBack.Visible := False;
  btnClearList.Visible := True;
  FPlainList := TObjectList<TFrameDetailRow>.Create();
  FFrameShowDetail := TFrameShowDetail.Create(self);
  FFrameShowDetail.Parent := TabItemDetail;
  FFrameShowDetail.Align := TAlignLayout.Client;
  TabControlMain.ActiveTab := TabItemVPlain;
  TabControlMain.TabPosition := TTabPosition.None;

  TMessageManager.DefaultManager.SubscribeToMessage(TMessage<TShowDetailMsg>,
    procedure(const Sender: TObject; const M: TMessage)
    begin
      ShowDetail((M as TMessage<TShowDetailMsg>).Value.ImageFilename);
    end);

  TPlatformServices.Current.SupportsPlatformService(IFMXTimerService, FTimerService);
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  FPlainList.Free;
end;

procedure TfrmMain.PaintRects(const UpdateRects: array of TRectF);
begin
  var c := FTimerService.GetTick;
  inherited;
  FRenderTime := FRenderTime + FTimerService.GetTick - c;
  FFrameCount := FFrameCount + 1;
end;

procedure TfrmMain.Timer1Timer(Sender: TObject);
begin
  if FFrameCount > 0 then
  begin
    FFps := 1 / (FRenderTime / FFrameCount);
    lblFps.Text := Round(FFps).ToString + ' render time';
    FRenderTime := 0;
    FFrameCount := 0;
  end;
end;

function TfrmMain.GetImageFolder: string;
begin
  Result := '';
{$IF Defined(MSWindows)}
  var
  ExeFolder := ExtractFilePath(ParamStr(0));
  Result := TPath.Combine(ExeFolder, '..\..\resources\');
{$ELSE if Defined(IOS)}
  Result := TPath.GetDocumentsPath + '/';
{$ELSE}
  raise Exception.Create('Platform not supported');
{$ENDIF}
end;

procedure TfrmMain.FillPlain;
var
  ImageFolder, ImageName: string;
  i, fi: Integer;
  y: Single;
  Detailframe: TFrameDetailRow;
begin
  if FPlainList.Count > 0 then
    Exit;

  ImageFolder := GetImageFolder;
  y := 0.0;
  fi := 1;

  VertScrollBoxMain.BeginUpdate;
  try
    for i := 0 to ItemsCount - 1 do
    begin
      Detailframe := TFrameDetailRow.Create(nil);
      FPlainList.Add(Detailframe);
      ImageName := ImageFolder + fi.ToString + '.jpg';
      Detailframe.Bind(ImageName);
      Detailframe.Position.y := y;
      Detailframe.Align := TAlignLayout.Top;
      Detailframe.Height := 500;
      Detailframe.Parent := VertScrollBoxMain;

      if fi = 4 then
        fi := 0;
      Inc(fi);
      y := y + Detailframe.Height;
    end;
  finally
    VertScrollBoxMain.EndUpdate;
  end;
end;

procedure TfrmMain.btnClearListClick(Sender: TObject);
begin
  if TabControlMain.ActiveTab = TabItemVPlain then
    FPlainList.Clear
end;

procedure TfrmMain.btnListboxClick(Sender: TObject);
begin
  TabControlMain.SetActiveTabWithTransitionAsync(TabItemListbox, TTabTransition.Slide, TTabTransitionDirection.Normal, nil);
end;

procedure TfrmMain.btnPlainVBoxClick(Sender: TObject);
begin
  btnBack.Visible := False;
  btnClearList.Visible := True;
  TabControlMain.ActiveTab := TabItemVPlain;
  FillPlain;
end;

procedure TfrmMain.ShowDetail(const aImageFilename: string);
begin
  btnBack.Visible := True;
  btnClearList.Visible := False;
  FFrameShowDetail.Bind(aImageFilename);
  TabControlMain.TagObject := TabControlMain.ActiveTab;
  TabControlMain.SetActiveTabWithTransitionAsync(TabItemDetail, TTabTransition.Slide, TTabTransitionDirection.Normal, nil);
end;

procedure TfrmMain.btnBackClick(Sender: TObject);
begin
  TabControlMain.SetActiveTabWithTransitionAsync(TTabItem(TabControlMain.TagObject), TTabTransition.Slide, TTabTransitionDirection.Reversed, nil);
  btnBack.Visible := False;
  btnClearList.Visible := True;
end;

end.
