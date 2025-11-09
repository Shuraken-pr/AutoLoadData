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
  TPGLoadAutoData = class(TInterfacedObject, IAutoList, ILoadAutoList)
  private
    FList: TList<IAuto>;
    FConnection: TFDConnection;
    FDatabase: string;
    FPort: integer;
    FServer: string;
    FLogin: string;
    FPassword: string;
    FSQLText: string;
    function GetCount: Integer;
    function GetItem(Index: Integer): IAuto;
    procedure SetItem(Index: Integer; const Value: IAuto);
    procedure LoadFromDS(AQry: TFDQuery);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Add(const Value: IAuto);
    procedure Remove(const Value: IAuto);
    procedure Clear;
    function CheckLoad(AParams: TArray<string>; out ErrorMessage: string): boolean;
    function GetDescription: string;
    procedure LoadData;
  end;
{$R *.res}

{ TXLSLoadAutoData }

procedure TPGLoadAutoData.Add(const Value: IAuto);
begin
  fList.Add(Value);
end;

function TPGLoadAutoData.CheckLoad(AParams: TArray<string>;
  out ErrorMessage: string): boolean;
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

procedure TPGLoadAutoData.Clear;
begin
  FList.Clear;
end;

constructor TPGLoadAutoData.Create;
begin
  FList := TList<IAuto>.Create;
  FConnection := TFDConnection.Create(nil);
end;

destructor TPGLoadAutoData.Destroy;
begin
  FreeAndNil(FList);
  FreeAndNil(FConnection);
  inherited;
end;

function TPGLoadAutoData.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TPGLoadAutoData.GetDescription: string;
begin
  Result :=
  'Загрузка данных из PostGre'#13#10+
  'Необходимо указать сервер, порт, название БД, логин, пароль, текст запроса.'#13#10+
  'Текст запроса должен содержать поля car, parking, date_from, date_to';
end;

function TPGLoadAutoData.GetItem(Index: Integer): IAuto;
begin
  if (Index < 0) or (Index >= fList.Count) then
    raise Exception.Create('Индекс вне диапазона');
  Result := fList[Index];
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
  NewAuto: IAuto;
  car, parking: string;
  date_from, date_to: TDateTime;
begin
  try
    car := AQry.FieldByName('car').AsString;
    parking := AQry.FieldByName('parking').AsString;
    date_from := AQry.FieldByName('date_from').AsDateTime;
    date_to := AQry.FieldByName('date_from').AsDateTime;
  except
    exit;
  end;

  NewAuto := TAuto.Create;

  NewAuto.Car := car;
  NewAuto.Parking := parking;
  NewAuto.DateFrom := date_from;
  NewAuto.DateTo := date_to;
  // Добавление в список
  Add(NewAuto);
end;

procedure TPGLoadAutoData.Remove(const Value: IAuto);
begin
  FList.Remove(Value);
end;

procedure TPGLoadAutoData.SetItem(Index: Integer; const Value: IAuto);
begin
  if (Index < 0) or (Index >= fList.Count) then
    raise Exception.Create('Индекс вне диапазона');
  fList[Index] := Value;
end;

function LoadAutoList: ILoadAutoList;
begin
  Result := TPGLoadAutoData.Create;
end;


exports
  LoadAutoList;

begin
end.
