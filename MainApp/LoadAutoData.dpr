program LoadAutoData;

uses
  Vcl.Forms,
  main in 'main.pas' {Form1},
  auto_intf in '..\Common\auto_intf.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
