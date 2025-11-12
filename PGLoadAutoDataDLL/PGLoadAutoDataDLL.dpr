library PGLoadAutoDataDLL;

uses
  ShareMem,
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.PG,
  FireDAC.Phys.PGDef, FireDAC.VCLUI.Wait, Data.DB, FireDAC.Comp.Client,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt,
  auto_intf in '..\Common\auto_intf.pas'  ;

type
  TPGLoadAutoData = class(TInterfacedObject, ILoadAutoList, IPGLoadAutoList)
  private
    FList: TObjectList<TAuto>;
    FConnection: TFDConnection;
    FDatabase: WideString;
    FPort: integer;
    FServer: WideString;
    FLogin: WideString;
    FPassword: WideString;
    FSQLText: WideString;
    procedure LoadFromDS(AQry: TFDQuery); safecall;
    function GetList: TObjectList<TAuto>; safecall;
    function GetDatabase: WideString; safecall;
    function GetLogin: WideString; safecall;
    function GetPassword: WideString;  safecall;
    function GetPort: integer; safecall;
    function GetServer: WideString; safecall;
    function GetSqlText: WideString; safecall;
  public
    constructor Create;
    destructor Destroy; override;
    function CheckLoad(AParams: TArray<string>; out ErrorMessage: WideString): boolean;  safecall;
    function GetDescription: WideString;  safecall;
    procedure LoadData;  safecall;
    property Database: WideString read GetDatabase;
    property Port: integer read GetPort;
    property Server: WideString read GetServer;
    property Login: WideString read GetLogin;
    property Password: WideString read GetPassword;
    property SQLText: WideString read GetSqlText;
    property AutoList: TObjectList<TAuto> read GetList;
  end;
{$R *.res}

{ TXLSLoadAutoData }

function TPGLoadAutoData.CheckLoad(AParams: TArray<string>;
  out ErrorMessage: WideString): boolean;
begin
  Result := Assigned(FConnection);
  ErrorMessage := '';
  if Result then  
  try
    FServer := AParams[0];
    FPort := StrToInt(AParams[1]);
    FDatabase := AParams[2];
    FLogin := AParams[3];
    FPassword := AParams[4];
    FSQLText := AParams[5];
    FConnection.DriverName := 'PG';
    FConnection.LoginPrompt := false;
    FConnection.ConnectionName := 'postgres';
    with FConnection.Params do
    begin
      DriverID := 'PG';
      Database := FDatabase;
      UserName := FLogin;
      Password := FPassword;
      TFDPhysPGConnectionDefParams(FConnection.Params).port := FPort;
      TFDPhysPGConnectionDefParams(FConnection.Params).server := FServer;
    end;
    try
      FConnection.Connected := true;
      Result := FConnection.Connected;
      FConnection.Connected := false;
    except
      Result := false;
      ErrorMessage := 'Не удалось установить соединение';
    end;
  except
    Result := false;
    ErrorMessage := 'Параметры заданы неверно';
  end;
end;

constructor TPGLoadAutoData.Create;
begin
  FList := TObjectList<TAuto>.Create(false);
  FConnection := TFDConnection.Create(nil);
end;

destructor TPGLoadAutoData.Destroy;
begin
  FreeAndNil(FList);
  FreeAndNil(FConnection);
  inherited;
end;

function TPGLoadAutoData.GetDatabase: WideString;
begin

end;

function TPGLoadAutoData.GetDescription: WideString;
begin
  Result :=
  'Загрузка данных из PostGre'#13#10+
  'Необходимо указать сервер, порт, название БД, логин, пароль, текст запроса.'#13#10+
  'Текст запроса должен содержать поля car, parking, date_from, date_to';
end;

function TPGLoadAutoData.GetList: TObjectList<TAuto>;
begin
  Result := FList;
end;

function TPGLoadAutoData.GetLogin: WideString;
begin
  Result := FLogin;
end;

function TPGLoadAutoData.GetPassword: WideString;
begin
  Result := FPassword;
end;

function TPGLoadAutoData.GetPort: integer;
begin
  Result := FPort;
end;

function TPGLoadAutoData.GetServer: WideString;
begin
  Result := FServer;
end;

function TPGLoadAutoData.GetSqlText: WideString;
begin
  Result := FSQLText;
end;

procedure TPGLoadAutoData.LoadData;
var
  qry: TFDQuery;
begin
  try
    FConnection.connected := true;
  except
    exit;
  end;
  if FConnection.Connected then
  begin
    FList.Clear;
    qry := TFDQuery.Create(nil);
    try
      qry.Connection := FConnection;
      qry.SQL.Text := FSQLText;
      try
        qry.Open;
        qry.First;
        while not qry.Eof do
        begin
          LoadFromDS(qry);
          qry.Next;
        end;
      except
        raise Exception.Create('Неверный запрос');
      end;
    finally
      FreeAndNil(qry);
    end;
  end;
end;

procedure TPGLoadAutoData.LoadFromDS(AQry: TFDQuery);
var
  NewAuto: TAuto;
  car, parking: WideString;
  date_from, date_to: TDateTime;
begin
  try
    car := AQry.FieldByName('car').AsWideString;
    parking := AQry.FieldByName('parking').AsWideString;
    date_from := AQry.FieldByName('date_from').AsDateTime;
    date_to := AQry.FieldByName('date_from').AsDateTime;
  except
    exit;
  end;

  NewAuto := TAuto.Create;
  try
    NewAuto.Car := car;
    NewAuto.Parking := parking;
    NewAuto.DateFrom := date_from;
    NewAuto.DateTo := date_to;
    // Добавление в список
    FList.Add(NewAuto);
  except
    FreeAndNil(NewAuto)
  end;
end;

function LoadAutoList: ILoadAutoList;
begin
  Result := TPGLoadAutoData.Create;
end;


exports
  LoadAutoList;

begin
end.
