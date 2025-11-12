library XLSLoadAutoDataDLL;

uses
  ShareMem,
  System.SysUtils,
  System.Classes,
  auto_intf in '..\Common\auto_intf.pas',
  ComObj,
  ActiveX,
  Variants,
  System.Generics.Collections;

type
  TXLSLoadAutoData = class(TInterfacedObject, ILoadAutoList, IXLSLoadAutoList)
  private
    FList: TObjectList<TAuto>;
    FIsExcelInstalled: boolean;
    FFileName: WideString;
    function GetList: TObjectList<TAuto>; safecall;
    function GetFileName: WideString; safecall;
  public
    constructor Create;
    destructor Destroy; override;
    function CheckLoad(AParams: TArray<string>; out ErrorMessage: WideString): boolean;  safecall;
    function GetDescription: WideString; safecall;
    procedure LoadData; safecall;
    property FileName: WideString read GetFileName;
    property AutoList: TObjectList<TAuto> read GetList;
  end;

{$R *.res}

{ TXLSLoadAutoData }

function IsExcelInstalled: Boolean;
var
  ClassID: TCLSID;
  ResultCode: HRESULT;
begin
  // Инициализация COM-библиотеки (обязательно для работы с OLE)
  CoInitialize(nil);

  // Пытаемся получить CLSID для ProgID 'Excel.Application'
  ResultCode := CLSIDFromProgID(PWideChar(WideString('Excel.Application')), ClassID);

  // Если вызов вернул S_OK — Excel установлен
  Result := (ResultCode = S_OK);

  // Освобождаем ресурсы COM
  CoUninitialize;
end;

function TXLSLoadAutoData.CheckLoad(AParams: TArray<string>; out ErrorMessage: WideString): boolean;
begin
  Result := FIsExcelInstalled;
  ErrorMessage := '';
  if not Result then
    ErrorMessage := 'Не установлен Microsoft Office'
  else begin
    try
      FFileName := AParams[0];
      Result := FileExists(FFileName);
      if not Result then
        ErrorMessage := 'Файл не найден';
    except
      Result := false;
      ErrorMessage := 'Не указан путь к файлу';
    end;
  end;
end;

constructor TXLSLoadAutoData.Create;
begin
  FList := TObjectList<TAuto>.Create(false);
  FIsExcelInstalled := IsExcelInstalled;
end;

destructor TXLSLoadAutoData.Destroy;
begin
  FreeAndNil(FList);
  inherited;
end;

function TXLSLoadAutoData.GetDescription: WideString;
begin
  Result := 'Загрузка данных из Excel-файла.'#13#10;
  if not FIsExcelInstalled then
    Result := Result + 'На компьютере должен стоять Microsoft Office.'#13#10;

  Result := Result +
   'Для загрузки данных необходимо выбрать файл с требуемыми данными:'#13#10+
   'Столбец 1: название автомобиля; 2 - парковка; 3 - начало стоянки; 4 - конец стоянки'#13#10+
   'Убедитесь, что первая страница файла содержит именно эти данные';
end;

function TXLSLoadAutoData.GetFileName: WideString;
begin
  Result := FFileName;
end;

function TXLSLoadAutoData.GetList: TObjectList<TAuto>;
begin
  Result := FList;
end;

procedure TXLSLoadAutoData.LoadData;
var
  ExcelApp, Workbook, Worksheet: Variant;
  Row, RowCount: Integer;
  NewAuto: TAuto;
  CarValue, ParkingValue: WideString;
  DateFromValue, DateToValue: TDateTime;
  DateFromVar, DateToVar: Variant;
begin
  if FIsExcelInstalled and FileExists(FFileName) then
  begin
    try
      // Создание COM‑объекта Excel
      ExcelApp := CreateOleObject('Excel.Application');
      try
        ExcelApp.Visible := false;
        ExcelApp.DisplayAlerts := False;

        // Открытие книги
        Workbook := ExcelApp.Workbooks.Open(FFileName);
        Worksheet := Workbook.ActiveSheet;

        // Определение количества строк
        RowCount := Worksheet.UsedRange.Rows.Count;
        if RowCount < 2 then
          Exit; // Нет данных (предполагаем, что 1‑я строка — шапка)

        //очистим данные
        Flist.Clear;

        // Чтение данных построчно (начиная со 2‑й строки)
        for Row := 2 to RowCount do
        begin
          // Чтение значений из первых 4 колонок
          CarValue := Worksheet.Cells[Row, 1].Value;
          ParkingValue := Worksheet.Cells[Row, 2].Value;
          DateFromVar := Worksheet.Cells[Row, 3].Value;
          DateToVar := Worksheet.Cells[Row, 4].Value;
          try
            DateFromValue := VarToDateTime(DateFromVar);
            DateToValue := VarToDateTime(DateToVar)
          except
            DateFromValue := 0;
            DateToValue := 0;
          end;

          //Проверим, что все поля заполнены
          if not VarIsNull(CarValue) and
             not VarIsEmpty(CarValue) and
             not VarIsNull(ParkingValue) and
             not VarIsEmpty(ParkingValue) and
             (DateFromValue > 0) and
             (DateToValue > 0) then
          begin
            // Создание объекта IAuto
            NewAuto := TAuto.Create;
            try
              NewAuto.Car := VarToStr(CarValue);
              NewAuto.Parking := VarToStr(ParkingValue);
              NewAuto.DateFrom := DateFromValue;
              NewAuto.DateTo := DateToValue;
              // Добавление в список
              FList.Add(NewAuto);
            except
              FreeAndNil(NewAuto);
            end;
          end;
        end;
      finally
        // Закрытие книги и выход из Excel
        if VarIsType(Workbook, varDispatch) then
          Workbook.Close(False);
        if VarIsType(ExcelApp, varDispatch) then
          ExcelApp.Quit;
      end;
    except
      on E: Exception do
      begin
        // Освобождение ресурсов при ошибке
        if VarIsType(ExcelApp, varDispatch) then
        begin
          try
            ExcelApp.Quit;
          except
            // Игнорируем ошибки при закрытии
          end;
        end;
        raise; // Перевыбрасываем исходное исключение
      end;
    end;
  end;
end;

function LoadAutoList: ILoadAutoList;
begin
  Result := TXLSLoadAutoData.Create;
end;


exports
  LoadAutoList;

begin
end.
