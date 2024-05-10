unit uMain;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Dialogs,
  FMX.Controls.Presentation,
  FMX.StdCtrls,
  FMX.Layouts,
  FMX.TabControl,
  System.Generics.Collections,
  uDetailRow,
  uDetailShow,
  System.Actions,
  FMX.ActnList,
  FMX.ListView.Types,
  FMX.ListView.Appearances,
  FMX.ListView.Adapters.Base,
  FMX.ListView;

const
  nItems: Integer = 50;

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
    StyleBook1: TStyleBook;
    TabItemListView: TTabItem;
    ListView1: TListView;
    btnListview: TButton;
    btnClearList: TButton;
    procedure btnPlainVBoxClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnBackClick(Sender: TObject);
    procedure btnClearListClick(Sender: TObject);
    procedure btnListviewClick(Sender: TObject);
    procedure ListView1ItemClick(const Sender: TObject; const AItem: TListViewItem);
  private
    fPlainList: TObjectList<TFrameDetailRow>;
    fFrameShowDetail: TFrameShowDetail;
    procedure FillPlain();
    procedure FillListView();
    procedure ShowDetail(ImageFilename: string);
    function GetImageFolder(): string;
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

uses
  IOUtils,
  uCommon,
  Messaging;

{$R *.fmx}

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  btnBack.Visible := false;
  btnClearList.Visible := true;
  fPlainList := TObjectList<TFrameDetailRow>.Create();
  fFrameShowDetail := TFrameShowDetail.Create(self);
  fFrameShowDetail.Parent := TabItemDetail;
  fFrameShowDetail.Align := TAlignLayout.Client;
  TabControlMain.ActiveTab := TabItemVPlain;
  TabControlMain.TabPosition := TTabPosition.None;

  TMessageManager.DefaultManager.SubscribeToMessage(TMessage<TShowDetailMsg>,
    procedure(const Sender: TObject; const M: TMessage)
    begin
      var v := (M as TMessage<TShowDetailMsg>).Value;
      ShowDetail(v.ImageFilename);
    end);

end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  fPlainList.Free;
end;

function TfrmMain.GetImageFolder(): string;
begin
  result := '';
  {$IF Defined(MSWindows)}
  var exeFolder := ExtractFilePath(ParamStr(0));
  result := TPath.Combine(exeFolder, '..\..\resources\');
  {$ELSE if Defined(IOS)}
  result := TPath.GetDocumentsPath + '/';
  {$ELSE}
  raise Exception.Create('Platform not supported');
  {$ENDIF}
end;

procedure TfrmMain.FillPlain;
begin

  if fPlainList.Count > 0 then
    Exit;

  var imageFolder := GetImageFolder();
  var y := 0.0;
  var fi := 1;

  VertScrollBoxMain.BeginUpdate();
  try
    for var i := 0 to nItems do
    begin
      var detailframe := TFrameDetailRow.Create(nil);
      fPlainList.Add(detailframe);
      var imagename := imageFolder + fi.ToString() + '.jpg';
      detailframe.Bind(imagename);
      detailframe.Position.Y := y;
      detailframe.Align := TAlignLayout.Top;
      detailframe.Height := 500;
      detailframe.Parent := VertScrollBoxMain;
      if fi = 4 then
        fi := 0;
      inc(fi);
      y := y + detailframe.Height;
    end;
  finally
    VertScrollBoxMain.EndUpdate;
  end;

end;

procedure TfrmMain.FillListView();
begin

  if ListView1.Items.Count > 0 then
    Exit;

  var imageFolder := GetImageFolder();
  var fi := 1;
  ListView1.BeginUpdate();
  try
    for var i := 0 to nItems do
    begin
      var item := ListView1.Items.Add;
      var t1 := item.Objects.FindObjectT<TListItemText>('Text1');
      var t2 := item.Objects.FindObjectT<TListItemText>('Text2');
      var t3 := item.Objects.FindObjectT<TListItemText>('Text3');
      var i3 := item.Objects.FindObjectT<TListItemImage>('Image4');
      t1.Text := 'This is the title of a movie';
      t2.Text := 'Start: 20:00';
      t3.Text := 'Main room';
      var imagename := imageFolder + fi.ToString() + '.jpg';
      item.TagString := imagename;
      i3.Bitmap := TBitmap.CreateFromFile(imagename);
      if fi = 4 then
        fi := 0;
      inc(fi);
    end;
  finally
    ListView1.EndUpdate;
  end;
end;

procedure TfrmMain.ListView1ItemClick(const Sender: TObject; const AItem: TListViewItem);
begin
  ShowDetail(aItem.TagString);
end;

procedure TfrmMain.btnClearListClick(Sender: TObject);
begin
  if TabControlMain.ActiveTab = TabItemVPlain then
    fPlainList.Clear
  else if TabControlMain.ActiveTab = TabItemListView then
    ListView1.Items.Clear();
end;

procedure TfrmMain.btnListviewClick(Sender: TObject);
begin
  btnBack.Visible := false;
  btnClearList.Visible := true;
  TabControlMain.ActiveTab := TabItemListView;
  FillListView();
end;

procedure TfrmMain.btnPlainVBoxClick(Sender: TObject);
begin
  btnBack.Visible := false;
  btnClearList.Visible := true;
  TabControlMain.ActiveTab := TabItemVPlain;
  FillPlain();
end;

procedure TfrmMain.ShowDetail(ImageFilename: string);
begin
  btnBack.Visible := true;
  btnClearList.Visible := false;
  fFrameShowDetail.Bind(ImageFilename);
  TabControlMain.TagObject := TabControlMain.ActiveTab;
  TabControlMain.SetActiveTabWithTransitionAsync(TabItemDetail, TTabTransition.Slide, TTabTransitionDirection.Normal, nil);
end;

procedure TfrmMain.btnBackClick(Sender: TObject);
begin
  TabControlMain.SetActiveTabWithTransitionAsync(TTabItem(TabControlMain.TagObject), TTabTransition.Slide, TTabTransitionDirection.Reversed, nil);
  btnBack.Visible := false;
  btnClearList.Visible := true;
end;

end.

