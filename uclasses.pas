unit uClasses;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls, uGlobalVars, fpjson, jsonparser;

type

  { TfrmClasses }

  TfrmClasses = class(TForm)
    btnSelect: TButton;
    btnCancel: TButton;
    btnAdd: TButton;
    btnRemove: TButton;
    txtClasse: TEdit;
    lstClass: TListBox;
    procedure btnAddClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnRemoveClick(Sender: TObject);
    procedure btnSelectClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure lstClassClick(Sender: TObject);
    procedure makeLabelsMap;

  private


  public
    caminhoArquivo: string;

  end;

var
  frmClasses: TfrmClasses;

implementation

{$R *.lfm}

{ TfrmClasses }

procedure TfrmClasses.makeLabelsMap;
var
    nomeArquivo: string;
    tamanho: Integer;
    json: TJSONObject;
    list: TJSONArray;
    strJson: string;
    f: Text;
    contador: Integer;

begin
    nomeArquivo := caminhoArquivo + '\' + 'classesLabelMap.json';

    if(FileExists(nomeArquivo)) then begin
        DeleteFile(PChar(nomeArquivo));
    end;
    list := TJSONArray.Create;

    json := TJSONObject.Create;
    json.Add('name', 'none_of_the_above');
    json.Add('label', 0);
    json.Add('display_name', 'background');
    list.Add(json);

    tamanho := lstClass.Count;
    for contador := 0 to (tamanho - 1) do begin
        json := TJSONObject.Create;
        json.Add('name', lstClass.Items[contador]);
        json.Add('label', (contador + 1));
        json.Add('display_name', lstClass.Items[contador]);
        list.Add(json);
    end;
    strJson := list.asjSON;

    AssignFile(f,nomeArquivo);
    Rewrite(f);
    if IOResult = 0 then begin
       WriteLn(f, strJson);
    end else begin
         ShowMessage('error opening file for writing');
    end;
    CloseFile(f);
end;

procedure TfrmClasses.btnCancelClick(Sender: TObject);
begin
  Self.Close;
end;

procedure TfrmClasses.btnRemoveClick(Sender: TObject);
var
  f: Text;
  nomeArquivo: string;
  contador: Integer;
  tamanho: Integer;

begin
  if(lstClass.ItemIndex >= 0)then begin
    lstClass.Items.Delete(lstClass.ItemIndex);
    lstClass.ClearSelection;

    nomeArquivo := caminhoArquivo + '\' + 'classes.txt';
    if(FileExists(nomeArquivo)) then begin
        DeleteFile(nomeArquivo);
    end;
    AssignFile(f,nomeArquivo);
    Rewrite(f);
    if IOResult = 0 then begin
       tamanho := lstClass.Count;
       for contador := 0 to tamanho do begin
           WriteLn(f, lstClass.Items[contador]);
       end;
    end else begin
         ShowMessage('error opening file for writing');
    end;
    CloseFile(f);
    makeLabelsMap;
  end;
end;

procedure TfrmClasses.btnAddClick(Sender: TObject);
var
  f: Text;
  nomeArquivo: string;
  contador: Integer;
  tamanho: Integer;

begin
  if(txtClasse.Text <> '')then begin
    lstClass.ClearSelection;
    lstClass.Items.Add(txtClasse.Text);
    lstClass.Items.IndexOf(txtClasse.Text);
    txtClasse.Text := '';

    caminhoArquivo := uGlobalVars.caminhoArquivo;
    nomeArquivo := caminhoArquivo + '\' + 'classes.txt';
    if(FileExists(nomeArquivo)) then begin
        DeleteFile(nomeArquivo);
    end;
    AssignFile(f,nomeArquivo);
    Rewrite(f);
    if IOResult = 0 then begin
       tamanho := lstClass.Count;
       for contador := 0 to (tamanho - 1) do begin
           WriteLn(f, lstClass.Items[contador]);
       end;
    end else begin
         ShowMessage('error opening file for writing');
    end;
    CloseFile(f);
    makeLabelsMap;
  end;
end;

procedure TfrmClasses.btnSelectClick(Sender: TObject);
begin
  if(lstClass.ItemIndex >= 0) then begin
      uGlobalVars.globalClassID := lstClass.ItemIndex;
      uGlobalVars.globalClassName := lstClass.Items[lstClass.ItemIndex];
      Self.Close;
  end;
end;

procedure TfrmClasses.lstClassClick(Sender: TObject);
begin
    if(lstClass.ItemIndex >= 0) then begin
      uGlobalVars.globalClassID := lstClass.ItemIndex;
      uGlobalVars.globalClassName := lstClass.Items[lstClass.ItemIndex];
      Self.Close;
  end;
end;

procedure TfrmClasses.FormShow(Sender: TObject);
var
   f: Text;
   nomeArquivo: string;
   linha: string;

begin
    caminhoArquivo := uGlobalVars.caminhoArquivo;
    nomeArquivo := caminhoArquivo + '\' + 'classes.txt';
    if(FileExists(nomeArquivo)) then begin
        AssignFile(f, nomeArquivo);
        Reset(f);
        if(IORESULT <> 0) then begin
            ShowMessage('error opening file for reading');
        end else begin
            while not eof(f) do begin
                readln(f,linha);
                lstClass.Items.Add(linha);
            end;
        end;
        CloseFile(f);
    end;
end;

end.

