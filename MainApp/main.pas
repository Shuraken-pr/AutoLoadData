unit main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, auto_intf, cxGraphics, cxControls,
  cxLookAndFeels, cxLookAndFeelPainters, dxLayoutContainer, cxStyles,
  cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit, cxNavigator,
  dxDateRanges, dxScrollbarAnnotations, Data.DB, cxDBData,
  cxGridCustomTableView, cxGridTableView, cxGridLevel, cxClasses,
  cxGridCustomView, cxGridDBTableView, cxGrid, dxLayoutControl,
  dxLayoutcxEditAdapters, cxContainer, cxTextEdit, cxMemo, dxCoreGraphics,
  cxMaskEdit, cxButtonEdit, dxLayoutControlAdapters, Vcl.Menus, Vcl.StdCtrls,
  cxButtons, System.Generics.Collections, cxGridRows;

type
  TForm1 = class(TForm)
    dxLayoutControl1Group_Root: TdxLayoutGroup;
    dxLayoutControl1: TdxLayoutControl;
    lgParams: TdxLayoutGroup;
    lgData: TdxLayoutGroup;
    lgExcelParams: TdxLayoutGroup;
    lgPostgreParams: TdxLayoutGroup;
    grAutoData: TcxGrid;
    ligrAutoData: TdxLayoutItem;
    glAutoData: TcxGridLevel;
    tvAutoData: TcxGridTableView;
    gcAuto: TcxGridColumn;
    gcParking: TcxGridColumn;
    mXLSDescription: TcxMemo;
    dxLayoutItem1: TdxLayoutItem;
    mPGDescription: TcxMemo;
    dxLayoutItem2: TdxLayoutItem;
    beXLSPath: TcxButtonEdit;
    liXLSPath: TdxLayoutItem;
    odXLSLoad: TOpenDialog;
    btnXLSLoadData: TcxButton;
    dxLayoutItem3: TdxLayoutItem;
    cxStyleRepository1: TcxStyleRepository;
    stGroupSummary: TcxStyle;
    edServer: TcxTextEdit;
    liServer: TdxLayoutItem;
    edPort: TcxTextEdit;
    liPort: TdxLayoutItem;
    edNameDB: TcxTextEdit;
    liNameDB: TdxLayoutItem;
    edLogin: TcxTextEdit;
    liLogin: TdxLayoutItem;
    edPassword: TcxTextEdit;
    liPassword: TdxLayoutItem;
    mSQL: TcxMemo;
    dxLayoutItem4: TdxLayoutItem;
    btnPGLoadData: TcxButton;
    dxLayoutItem5: TdxLayoutItem;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure beXLSPathPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure btnXLSLoadDataClick(Sender: TObject);
    procedure btnPGLoadDataClick(Sender: TObject);
    procedure gcAutoCustomDrawFooterCell(Sender: TcxGridTableView;
      ACanvas: TcxCanvas; AViewInfo: TcxGridColumnHeaderViewInfo;
      var ADone: Boolean);
  private
    { Private declarations }
    FCarParkingList: TStringList;
    FDateList: TList<TDate>;
    FDllManager: TDllManager<ILoadAutoList>;
    FXLSLoadAutoDataDLL: ILoadAutoList;
    FPGLoadAutoDataDLL: ILoadAutoList;
    procedure FillGrid(AutoList: ILoadAutoList);
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.beXLSPathPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if odXLSLoad.Execute then
    beXLSPath.Text := odXLSLoad.FileName;
end;

procedure TForm1.btnPGLoadDataClick(Sender: TObject);
var
  server, port, db_name, login, password, SQLText, ErrMsg: string;
begin
  ErrMsg := '';
  server := edServer.Text;
  port := edPort.Text;
  db_name := edNameDB.Text;
  login := edLogin.Text;
  password := edPassword.Text;
  SQLText := mSQL.Lines.Text;
  if (trim(server) = '') or
     (trim(port) = '') or
     (trim(db_name) = '') or
     (trim(login) = '') or
     (trim(password) = '') or
     (trim(SQLText) = '') then
     ShowMessage('Необходимо заполнить все параметры')
  else begin
    if FPGLoadAutoDataDLL.CheckLoad([server, port, db_name, login, password, sqlText], ErrMsg) then
      FillGrid(FPGLoadAutoDataDLL)
    else
      ShowMessage(errMsg);
  end;
end;

procedure TForm1.btnXLSLoadDataClick(Sender: TObject);
var
  FXLSFileName, ErrMsg: string;
begin
  FXLSFileName := beXLSPath.Text;
  ErrMsg := '';
  if trim(FXLSFileName) <> '' then
  begin
    if FileExists(FXLSFileName) then
    begin
      if FXLSLoadAutoDataDLL.CheckLoad([FXLSFileName], ErrMsg) then
      begin
        FillGrid(FXLSLoadAutoDataDLL);
      end
        else
        ShowMessage(ErrMsg);
    end
      else
      ShowMessage('Файл не найден');
  end
    else
    ShowMessage('Укажите путь к файлу загрузки');
end;

procedure TForm1.FillGrid(AutoList: ILoadAutoList);
var
  i, curValue: integer;
  car, parking: string;
  date_from: TDate;
  gcDate: TcxGridColumn;
  rowIndex, colIndex: integer;
begin
  with tvAutoData.DataController do
  begin
    BeginFullUpdate;
    try
      RecordCount := 0;
      for i := tvAutoData.ColumnCount - 1 downto 0 do
      begin
        if pos('gcDate_', tvAutoData.Columns[i].Name) > 0 then
          tvAutoData.Columns[i].Free;
      end;

      AutoList.LoadData;
      //очищаем список для записей
      FCarParkingList.Clear;
      //очищаем список для колонок
      FDateList.Clear;
      //сначала заполним списки
      for i := 0 to AutoList.Count - 1 do
      begin
        car := AutoList[i].Car;
        parking := AutoList[i].Parking;
        date_from := Trunc(AutoList[i].DateFrom);
        if FDateList.IndexOf(date_from) < 0 then
          FDateList.Add(date_from);
        if FCarParkingList.IndexOf(car + ';' + parking) < 0 then
          FCarParkingList.Add(car + ';' + parking);
      end;

      //отсортируем список дат
      FDateList.Sort;

      //создадим колонки
      for i := 0 to FDateList.Count - 1 do
      begin
        gcDate := tvAutoData.CreateColumn;
        with gcDate do
        begin
          Width := 64;
          Caption := FormatDateTime('dd.mm.yyyy', FDateList[i]);
          Name := Format('gcDate_%d', [i]);
          DataBinding.ValueType := 'Integer';
          with options do
          begin
            filtering := false;
            Grouping := false;
            Moving := false;
          end;

          with Summary do
          begin
            FooterFormat := '0';
            FooterKind := skSum;
            GroupFooterFormat := '0';
            GroupFooterKind := skSum;
          end;

          OnCustomDrawFooterCell := gcAutoCustomDrawFooterCell;
        end;
      end;

      //создадим записи
      for i := 0 to FCarParkingList.Count - 1 do
        AppendRecord;

      //заполним записи.
      for i := 0 to AutoList.Count - 1 do
      begin
        car := AutoList[i].Car;
        parking := AutoList[i].Parking;
        date_from := Trunc(AutoList[i].DateFrom);
        colIndex := FDateList.IndexOf(date_from);
        RowIndex := FCarParkingList.IndexOf(car + ';' + parking);
        if (colIndex >= 0) and (RowIndex >= 0) then
        begin
          if VarIsNull(Values[RowIndex, 2 + colIndex]) then
            curValue := 0
          else
            curValue := Values[RowIndex, 2 + colIndex];
          Values[RowIndex, 2 + colIndex] := curValue + 1;
          Values[RowIndex, gcAuto.Index] := car;
          Values[RowIndex, gcParking.Index] := parking;
        end;
      end;
    finally
      EndFullUpdate;
    end;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  FCarParkingList := TStringList.Create;
  FDateList := TList<TDate>.Create;
  FDllManager := TDllManager<ILoadAutoList>.Create;
  if FDllManager.Load('XLSLoadAutoDataDLL', 'XLSLoadAutoDataDLL.dll', ILoadAutoList) then
  begin
    FDllManager.GetProvider('XLSLoadAutoDataDLL', FXLSLoadAutoDataDLL);
    mXLSDescription.Lines.Text := FXLSLoadAutoDataDLL.GetDescription;
    lgExcelParams.Visible := true;
  end;
  if FDllManager.Load('PGLoadAutoDataDLL', 'PGLoadAutoDataDLL.dll', ILoadAutoList) then
  begin
    FDllManager.GetProvider('PGLoadAutoDataDLL', FPGLoadAutoDataDLL);
    mPGDescription.Lines.Text := FPGLoadAutoDataDLL.GetDescription;
    lgPostgreParams.Visible := true;
  end;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FCarParkingList);
  FreeAndNil(FDateList);
  if Assigned(FXLSLoadAutoDataDLL) then
    FXLSLoadAutoDataDLL := nil;
  if Assigned(FPGLoadAutoDataDLL) then
    FPGLoadAutoDataDLL := nil;
end;

procedure TForm1.gcAutoCustomDrawFooterCell(Sender: TcxGridTableView;
  ACanvas: TcxCanvas; AViewInfo: TcxGridColumnHeaderViewInfo;
  var ADone: Boolean);
var
  s: string;
  v: double;
begin
  if AViewInfo.Column.DataBinding.ValueType = 'Integer' then
  begin
    s := AViewInfo.Text;
    if TryStrToFloat(s, v) then
    begin
      if v > 0 then
      begin
        ACanvas.Brush.Color := clAqua;
        ACanvas.FillRect(AViewInfo.Bounds);
        ACanvas.TextOut(AViewInfo.Bounds.Left + 4,
          AViewInfo.Bounds.Top + (AViewInfo.Bounds.Height - ACanvas.TextHeight(s)) div 2,
          s);
        ADone := true;
      end;
    end;
  end;
end;

end.
