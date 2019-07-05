unit frmhelp;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls, LCLIntf;

type

  { TfrmSobre }

  TfrmSobre = class(TForm)
    btnSair: TButton;
    Label1: TLabel;
    Memo1: TMemo;
    procedure btnSairClick(Sender: TObject);
    procedure Label1Click(Sender: TObject);
  private

  public

  end;

var
  frmSobre: TfrmSobre;

implementation

{$R *.lfm}

{ TfrmSobre }

procedure TfrmSobre.btnSairClick(Sender: TObject);
begin
  Self.Close;
end;

procedure TfrmSobre.Label1Click(Sender: TObject);
begin
    OpenURL('http://www.wind.net.br');
end;

end.

