unit auto_intf;

interface

uses
  SysUtils, Classes,
  Generics.Collections,
  Threading,
  Winapi.Windows,
  System.UITypes,
  Vcl.Dialogs;

  //Интерфейс для работы с данными
type
  IAuto = interface
    ['{7B6480FC-2751-4799-8D6C-B73975560708}']
    function GetCar: WideString; safecall;
    procedure SetCar(const Value: WideString); safecall;
    function GetParking: WideString; safecall;
    procedure SetParking(const Value: WideString); safecall;
    function GetDateFrom: TDateTime; safecall;
    procedure SetDateFrom(const Value: TDateTime); safecall;
    function GetDateTo: TDateTime; safecall;
    procedure SetDateTo(const Value: TDateTime); safecall;

    property Car: WideString read GetCar write SetCar;
    property Parking: WideString read GetParking write SetParking;
    property DateFrom: TDateTime read GetDateFrom write SetDateFrom;
    property DateTo: TDateTime read GetDateTo write SetDateTo;
  end;

  //базовый класс для загрузки. Для расширения функциональности наследоваться от него
  TAuto = class(TInterfacedObject, IAuto)
  private
    fCar: WideString;
    fParking: WideString;
    fDateFrom: TDateTime;
    fDateTo: TDateTime;
    function GetCar: WideString;  safecall;
    procedure SetCar(const Value: WideString); safecall;
    function GetParking: WideString; safecall;
    procedure SetParking(const Value: WideString); safecall;
    function GetDateFrom: TDateTime;  safecall;
    procedure SetDateFrom(const Value: TDateTime); safecall;
    function GetDateTo: TDateTime;  safecall;
    procedure SetDateTo(const Value: TDateTime);  safecall;
  public
    property Car: WideString read GetCar write SetCar;
    property Parking: WideString read GetParking write SetParking;
    property DateFrom: TDateTime read GetDateFrom write SetDateFrom;
    property DateTo: TDateTime read GetDateTo write SetDateTo;
  end;

  //интерфейс для загрузки данных
  ILoadAutoList = interface
    ['{EC01835B-4F59-43A1-BBA3-6C50AABAD1E2}']
    //функция проверяет, возможна ли загрузка с указанными параметрами.
    //Для загрузки из xls-файла требуется наличие офиса на компьютере и файл, из которого будут загружаться данные.
    //Для загрузки из PostGre требуются параметры подключения и запрос, который вернёт нужные данные.
    function CheckLoad(AParams: TArray<string>; out ErrorMessage: WideString): boolean;  safecall;
    //В описании будут указаны необходимые параметры
    function GetDescription: WideString; safecall;
    //сама загрузка данных.
    procedure LoadData; safecall;
    function GetList: TList<IAuto>; safecall;
    property AutoList: TList<IAuto> read GetList;
  end;

  IXLSLoadAutoList = interface(ILoadAutoList)
    ['{BA704998-6F71-417B-8969-436FCD08D5EC}']
    function GetFileName: WideString; safecall;
    procedure SetFileName(const Value: WideString); safecall;
    property FileName: WideString read GetFileName write SetFileName;
  end;

  IPGLoadAutoList = interface(ILoadAutoList)
    ['{071A3D19-41F3-4ED2-A14E-7524D83900A1}']
    function GetDatabase: WideString; safecall;
    function GetLogin: WideString; safecall;
    function GetPassword: WideString;  safecall;
    function GetPort: integer; safecall;
    function GetServer: WideString; safecall;
    function GetSqlText: WideString; safecall;
    procedure SetDatabase(const Value: WideString); safecall;
    procedure SetLogin(const Value: WideString); safecall;
    procedure SetPassword(const Value: WideString); safecall;
    procedure SetPort(const Value: integer); safecall;
    procedure SetServer(const Value: WideString); safecall;
    procedure SetSqlText(const Value: WideString); safecall;

    property Database: WideString read GetDatabase write SetDatabase;
    property Port: integer read GetPort write SetPort;
    property Server: WideString read GetServer write SetServer;
    property Login: WideString read GetLogin write SetLogin;
    property Password: WideString read GetPassword write SetPassword;
    property SQLText: WideString read GetSqlText write SetSqlText;
  end;

  //Реализацию интерфейсов вынесем в dll. Класс будет отвечать за корректную работу с dll.
  TDllManager<T: ILoadAutoList> = class
  private
    FProviders: TDictionary<string, T>;    // key -> интерфейс
    FModules: TDictionary<string, THandle>; // key -> HMODULE
  public
    constructor Create;
    destructor Destroy; override;

    // Загружает DLL по пути FileName и сохраняет под ключом Key.
    // Возвращает True при успешной загрузке и проверке на ITaskProvider и GUID.
    function Load(const Key, FileName: string; GUID: TGUID): Boolean;

    // Получить интерфейс по ключу
    function GetProvider(const Key: string; out Provider): Boolean;

    // Выгрузить DLL по ключу (освобождает интерфейс и FreeLibrary)
    function Unload(const Key: string): Boolean;

    // Выгрузить все
    procedure UnloadAll;

    // Проверка, загружен ли key
    function IsLoaded(const Key: string): Boolean;
  end;

implementation

{ TDllManager<T> }
type
  // тип экспортируемой функции в DLL:
  // возвращаем общий IInterface — далее мы проверим поддержку ILoadAutoList и T
  TLoadAutoList = function: IInterface; stdcall;

constructor TDllManager<T>.Create;
begin
  inherited Create;
  FProviders := TDictionary<string, T>.Create;
  FModules := TDictionary<string, THandle>.Create;
end;

destructor TDllManager<T>.Destroy;
begin
  UnloadAll;
  FreeAndNil(FProviders);
  FreeAndNil(FModules);
  inherited;
end;

function TDllManager<T>.GetProvider(const Key: string; out Provider): Boolean;
begin
  try
    Result := FProviders.TryGetValue(Key, Provider);
  except
    Result := false;
  end;
end;

function TDllManager<T>.IsLoaded(const Key: string): Boolean;
begin
  Result := FProviders.ContainsKey(Key);
end;

function TDllManager<T>.Load(const Key, FileName: string; GUID: TGUID): Boolean;
var
  hMod: THandle;
  funcPtr: Pointer;
  createFunc: TLoadAutoList;
  rawIntf: IInterface;
  baseProvider: ILoadAutoList;
  specific: T;
begin
  Result := False;

  if trim(Key) = '' then
  begin
    MessageDlg('Не задан ключ', TMsgDlgType.mtError, [TMsgDlgBtn.mbOK], 0);
    exit;
  end;

  if trim(FileName) = '' then
  begin
    MessageDlg('Не задано имя файла', TMsgDlgType.mtError, [TMsgDlgBtn.mbOK], 0);
    exit;
  end;

  if FProviders.ContainsKey(Key) then
    exit;

  // Загружаем модуль
  hMod := LoadLibrary(PChar(FileName));
  if hMod = 0 then
  begin
    //MessageDlg(Format('Не удалось загрузить  "%s". Ошибка %d', [FileName, GetLastError]), TMsgDlgType.mtError, [TMsgDlgBtn.mbOK], 0);
    exit;
  end;

  try
    // Ищем экспортированную функцию LoadAutoList
    funcPtr := GetProcAddress(hMod, 'LoadAutoList');
    if not Assigned(funcPtr) then
    begin
      MessageDlg('Функция LoadAutoList не найдена в ' + FileName, TMsgDlgType.mtError, [TMsgDlgBtn.mbOK], 0);
      exit;
    end;

    @createFunc := funcPtr;

    // вызываем функцию — ожидаем IInterface (обобщённый)
    rawIntf := nil;
    try
      rawIntf := createFunc();
    except
      on E: Exception do
      begin
        MessageDlg(Format('Ошибка при вызове LoadAutoList: %s', [E.Message]), TMsgDlgType.mtError, [TMsgDlgBtn.mbOK], 0);
        exit;
      end;
    end;

    if rawIntf = nil then
    begin
      MessageDlg('LoadAutoList returned nil', TMsgDlgType.mtError, [TMsgDlgBtn.mbOK], 0);
      exit;
    end;

    // Проверяем, что интерфейс поддерживает базовый ILoadAutoList
    if not Supports(rawIntf, ILoadAutoList, baseProvider) then
    begin
      MessageDlg('DLL не поддерживает ILoadAutoList', TMsgDlgType.mtError, [TMsgDlgBtn.mbOK], 0);
      exit;
    end;

    // Проверяем, что интерфейс можно привести к T через указанный GUID (например IXLSLoadAutoList или IPGLoadAutoList)
    if not Supports(rawIntf, GUID, specific) then
    begin
      MessageDlg(FileName + ' не поддерживает указанный интерфейс', TMsgDlgType.mtError, [TMsgDlgBtn.mbOK], 0);
      exit;
    end;

    // Сохраняем: сначала интерфейс, затем дескриптор модуля
    FProviders.Add(Key, specific);
    FModules.Add(Key, hMod);

    // Успех
    Result := True;

  except
    // В случае ошибки — выгружаем модуль чтобы не утечь
    FreeLibrary(hMod);
    raise;
  end;
end;

function TDllManager<T>.Unload(const Key: string): Boolean;
var
  provider: T;
  hMod: THandle;
begin
  Result := False;

  if not FProviders.TryGetValue(Key, provider) then
    Exit; // не найдено

  // Удаляем интерфейс из словаря — это уменьшит счётчик ссылок и освободит объект интерфейса
  FProviders.Remove(Key);

  // Получаем и удаляем дескриптор модуля
  if FModules.TryGetValue(Key, hMod) then
  begin
    FModules.Remove(Key);
    // Теперь можно выгрузить DLL
    if hMod <> 0 then
      FreeLibrary(hMod);
  end;

  // Обнуляем локальную переменную provider чтобы гарантировать освобождение
  provider := Default(T);

  Result := True;
end;

procedure TDllManager<T>.UnloadAll;
var
  pair: TPair<string, THandle>;
begin
  // Сначала освободим все интерфейсы (словарь FProviders при очистке освободит интерфейсы)
  FProviders.Clear;

  // Затем выгрузим все модули
  for pair in FModules do
  begin
    if pair.Value <> 0 then
      FreeLibrary(pair.Value);
  end;
  FModules.Clear;
end;

{ TAuto }

function TAuto.GetCar: WideString;
begin
  Result := fCar;
end;

function TAuto.GetDateFrom: TDateTime;
begin
  Result := fDateFrom
end;

function TAuto.GetDateTo: TDateTime;
begin
  Result := fDateTo;
end;

function TAuto.GetParking: WideString;
begin
  Result := fParking;
end;

procedure TAuto.SetCar(const Value: WideString);
begin
  fCar := Value;
end;

procedure TAuto.SetDateFrom(const Value: TDateTime);
begin
  fDateFrom := Value;
end;

procedure TAuto.SetDateTo(const Value: TDateTime);
begin
  FDateTo := Value;
end;

procedure TAuto.SetParking(const Value: WideString);
begin
  fParking := Value;
end;

end.
