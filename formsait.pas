unit formSait;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls, CheckLst, StdCtrls, ComCtrls, Buttons, Windows, Messages, Variants,
  frmhelp, LCLType, PopupNotifier, Types, uClasses, uGlobalVars, StrUtils, laz2_XMLRead, laz2_DOM, crt;

type

  { TfrmPrincipal }

  TfrmPrincipal = class(TForm)
    btnCropAllInList: TButton;
    btnHelp: TBitBtn;
    btnAnterior: TButton;
    btnAvante: TButton;
    btnCrop: TButton;
    btnOpenDir: TButton;
    btnSalvar: TButton;
    btnLimpar: TButton;
    btnDel: TButton;
    btnClearLastPoint: TButton;
    chCross: TCheckBox;
    chkMasks: TCheckBox;
    gbAnnotation: TGroupBox;
    bgPattern: TGroupBox;
    chlImagens: TListBox;
    rdbSquare: TRadioButton;
    rdbPoligon: TRadioButton;
    rdbPV2012: TRadioButton;
    rdbYolo: TRadioButton;
    ScrollBox1: TScrollBox;
    showImage: TImage;
    StatusBar1: TStatusBar;
    txtDir: TEdit;
    SelectDirectoryDialog1: TSelectDirectoryDialog;
    procedure btnAnteriorClick(Sender: TObject);
    procedure btnAvanteClick(Sender: TObject);
    procedure btnClearLastPointClick(Sender: TObject);
    procedure btnCropAllInListClick(Sender: TObject);
    procedure btnCropClick(Sender: TObject);
    procedure btnDelClick(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
    procedure btnLimparClick(Sender: TObject);
    procedure btnOpenDirClick(Sender: TObject);
    procedure btnSalvarClick(Sender: TObject);
    procedure chlImagensClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure drawAnnotation;
    procedure clearPoints;
    procedure colectPoint(ponto: TPoint);
    procedure showImageClick(Sender: TObject);
    procedure showImageDblClick(Sender: TObject);
    procedure showImageMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure showImageMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure showImageMouseWheelDown(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    procedure showImageMouseWheelUp(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    function  splitString(entrada: string; divisor:string) : TStringList;
    procedure loadImageService(caminho: string);
    function  returnPointImage: TPoint;
    function  returnPointScroll: TPoint;
    procedure drawSquare(ponto1: TPoint; ponto2: TPoint; image: TImage);
    procedure drawPreviousSquares;
    procedure DrawPolygon(image: TImage);
    procedure drawPreviousPoligons;
    procedure savePoints;
    procedure savePascalVoc;
    procedure saveYolo;
    procedure saveCocoo;
    function  showCustomMessage(msg: string; tipo: Integer): LongInt;
    procedure getClass;
    procedure loadExistFile;
    procedure loadCocooPascal(nomeArquivo: string);
    procedure loadYolo(nomeArquivo: string);
    function  returnNameClass(idClass: Integer): string;
    function  returnIdClass(nomeClass: String): Integer;
    procedure drawPointAt(x: Integer; y: Integer);
    procedure drawNameTagAtPoint(x: Integer; y: Integer; nameTag: string);
    procedure registraMensagem(msg: string; nomeArquivo: string);
    procedure drawCrossAt;
    procedure countAnnotation;
    procedure drawMaskFile;
    function IsPointInPolygon(AX, AY: Integer; APolygon: array of TPoint): Boolean;
    procedure saveAllCrops;

  type
      quadrado = record
          pontoOrigem : TPoint;
          pontoFim: TPoint;
          classID: Integer;
          className: String;
      end;
      poligono = record
          pontos: array of TPoint;
          classID: Integer;
          className: String;
      end;

  private
    zoom: LongInt;
    desenhando: Boolean;

    ponto1: TPoint;
    ponto2: TPoint;
    ponto1Real: TPoint;
    ponto2Real: TPoint;

    objPoligono: array of TPoint;
    objPoligonoReal: array of TPoint;

    listaQuadrados: array of quadrado;
    listaPoligonos: array of poligono;

  public

  end;

var
  frmPrincipal: TfrmPrincipal;
  quadroHelp: TfrmSobre;
  caixaClasses: TfrmClasses;
  start: TDateTime;
  stop: TDateTime;
  elapsed: TDateTime;

implementation

{$R *.lfm}

{ TfrmPrincipal }

{%region 'Metodos'}

function TfrmPrincipal.showCustomMessage(msg: string; tipo: Integer): LongInt;
var
  Reply, BoxStyle: Integer;

begin
  if(tipo = 1) then begin
      BoxStyle := MB_ICONQUESTION + MB_YESNO;
  end;
  if(tipo = 2) then begin
      BoxStyle := MB_ICONINFORMATION + MB_OK;
  end;
  if(tipo = 3) then begin
      BoxStyle := MB_ICONHAND + MB_OK;
  end;
  Reply := Application.MessageBox(PChar(msg), '----> SAIT <----', BoxStyle);
  Result := Reply;
end;

function TfrmPrincipal.splitString(entrada: string; divisor:string) : TStringList;
var
  strTemp: TStringList;

begin
  strTemp := TStringList.Create;
  strTemp.LineBreak := divisor;
  strTemp.Text := entrada;
  splitString := strTemp;
end;

procedure TfrmPrincipal.loadImageService(caminho: string);
begin
  zoom := 1;
  clearPoints;

  showImage.Picture.LoadFromFile(caminho);
  if(showImage.Picture.Bitmap.PixelFormat = pf1bit) then begin
      StatusBar1.Panels.Items[4].Text := '  Pixel = 1 bits';
  end;
  if(showImage.Picture.Bitmap.PixelFormat = pf4bit) then begin
      StatusBar1.Panels.Items[4].Text := '  Pixel = 4 bits';
  end;
  if(showImage.Picture.Bitmap.PixelFormat = pf8bit) then begin
      StatusBar1.Panels.Items[4].Text := '  Pixel = 8 bits';
  end;
  if(showImage.Picture.Bitmap.PixelFormat = pf15bit) then begin
      StatusBar1.Panels.Items[4].Text := '  Pixel = 15 bits';
  end;
  if(showImage.Picture.Bitmap.PixelFormat = pf16bit) then begin
      StatusBar1.Panels.Items[4].Text := '  Pixel = 16 bits';
  end;
  if(showImage.Picture.Bitmap.PixelFormat = pf24bit) then begin
      StatusBar1.Panels.Items[4].Text := '  Pixel = 24 bits';
  end;
  if(showImage.Picture.Bitmap.PixelFormat = pf32bit) then begin
    StatusBar1.Panels.Items[4].Text := '  Pixel = 32 bits';
  end;

  showImage.Picture.LoadFromFile(caminho);
  showImage.Refresh;

  StatusBar1.Panels.Items[0].Text := '  Width = ' + IntToStr(showImage.Picture.Width);
  StatusBar1.Panels.Items[1].Text := '  Height = ' + IntToStr(showImage.Picture.Height);
  StatusBar1.Panels.Items[3].Text := '  Zoom = ' + IntToStr(zoom);

  ScrollBox1.VertScrollBar.Position := 0;
  ScrollBox1.HorzScrollBar.Position := 0;
  ScrollBox1.Update;
  ScrollBox1.UpdateScrollbars;
  loadExistFile;
  countAnnotation;
  start := Now;
end;

function TfrmPrincipal.returnPointScroll: TPoint;
var
  pt : tPoint;

begin
  pt := Mouse.CursorPos;
  pt := ScrollBox1.ScreenToControl(pt);
  Result := pt;
end;

function TfrmPrincipal.returnPointImage: TPoint;
var
  pt : tPoint;

begin
  pt := Mouse.CursorPos;
  pt := ScrollBox1.ScreenToClient(pt);
  Result := pt;
end;

procedure TfrmPrincipal.colectPoint(ponto: TPoint);
var
    tamanho: Integer;
    tamanhoReal: Integer;
    quadradoLocal: quadrado;
    quadradoLocalReal: quadrado;
    pontoReal: TPoint;

begin
     pontoReal := returnPointImage;
     if(rdbPoligon.Checked = True) then begin
         tamanho := Length(objPoligono);
         if(tamanho = 0) then begin
             desenhando := False;
             SetLength(objPoligono, tamanho + 1);
             objPoligono[tamanho] := pontoReal;

             tamanhoReal := Length(objPoligonoReal);
             SetLength(objPoligonoReal, tamanhoReal + 1);
             objPoligonoReal[tamanhoReal] := pontoReal;
         end;
         if(tamanho > 0) then begin
             if(objPoligono[0] <> objPoligono[tamanho]) then begin
                 desenhando := True;
                 SetLength(objPoligono, tamanho + 1);
                 objPoligono[tamanho] := pontoReal;

                 tamanhoReal := Length(objPoligonoReal);
                 SetLength(objPoligonoReal, tamanhoReal + 1);
                 objPoligonoReal[tamanhoReal] := pontoReal;
             end else begin
                 desenhando := False;
                 tamanhoReal := Length(listaPoligonos);
                 SetLength(listaPoligonos, tamanhoReal + 1);
                 listaPoligonos[tamanhoReal].pontos := objPoligonoReal;
                 SetLength(objPoligono, 0);
                 SetLength(objPoligonoReal, 0);
             end;
         end;
     end;
     if(rdbSquare.Checked = True) then begin
         if((ponto2.x = 0) and (ponto2.y = 0) and (desenhando = True)) then begin
             uGlobalVars.globalClassID := 0;
             uGlobalVars.globalClassName := '';
             getClass;

             ponto2 := ponto;
             quadradoLocal.pontoOrigem.x := ponto1.x;
             quadradoLocal.pontoOrigem.y := ponto1.y;
             quadradoLocal.pontoFim.x := ponto2.x;
             quadradoLocal.pontoFim.y := ponto2.y;
             quadradoLocal.classID := uGlobalVars.globalClassID;
             quadradoLocal.className := uGlobalVars.globalClassName;

             ponto2Real := pontoReal;
             quadradoLocalReal.pontoOrigem.x := ponto1Real.x;
             quadradoLocalReal.pontoOrigem.y := ponto1Real.y;
             quadradoLocalReal.pontoFim.x := ponto2Real.x;
             quadradoLocalReal.pontoFim.y := ponto2Real.y;
             quadradoLocalReal.classID := uGlobalVars.globalClassID;
             quadradoLocalReal.className := uGlobalVars.globalClassName;

             tamanhoReal := Length(listaQuadrados);
             SetLength(listaQuadrados, (tamanhoReal  + 1));
             listaQuadrados[tamanhoReal] := quadradoLocalReal;

             drawPreviousPoligons;
             drawNameTagAtPoint(ponto1.x, ponto1.y, uGlobalVars.globalClassName);
             drawSquare(ponto1, ponto2, showImage);
             drawPreviousSquares;

             ponto1.x := 0;
             ponto1.y := 0;
             ponto2.x := 0;
             ponto2.y := 0;

             ponto1Real.x := 0;
             ponto1Real.y := 0;
             ponto2Real.x := 0;
             ponto2Real.y := 0;
         end;
         if((ponto1.x = 0) and (ponto1.y = 0) and (desenhando = False)) then begin
             ponto1 := ponto;
             ponto1Real := pontoReal;
             desenhando := True;
         end;
         if((ponto1.x = 0) and (ponto1.y = 0) and (ponto2.x = 0) and (ponto2.y = 0) and (desenhando = True)) then begin
             desenhando := False;
         end;
     end;
end;

procedure TfrmPrincipal.clearPoints;
begin
     SetLength(listaQuadrados, 0);
     SetLength(listaPoligonos, 0);
     SetLength(objPoligono, 0);
     SetLength(objPoligonoReal, 0);
     ponto1.x := 0;
     ponto1.y := 0;
     ponto2.x := 0;
     ponto2.y := 0;
     ponto1Real.x := 0;
     ponto1Real.y := 0;
     ponto2Real.x := 0;
     ponto2Real.y := 0;
     desenhando := False;
     showImage.Refresh;
end;

procedure TfrmPrincipal.drawPointAt(x: Integer; y: Integer);
begin
    showImage.Canvas.Pen.Width := 2;
    showImage.Canvas.Pen.Color := clYellow;
    showImage.Canvas.Brush.Color := clYellow;
    showImage.canvas.Ellipse((x - 3), (y - 3), (x + 3), (y + 3));
end;

procedure TfrmPrincipal.drawCrossAt;
var
     ponto: TPoint;
     x: Integer;
     y: Integer;
     ax: Integer;
     ay: Integer;
     bx: Integer;
     by: Integer;
     cx: Integer;
     cy: Integer;
     dx: Integer;
     dy: Integer;
     tamanho: Integer;

begin
     if(chCross.Checked = True) then begin
         tamanho := 1000;
         ponto := returnPointScroll;
         x := ponto.x;
         y := ponto.y;

         ax := x + tamanho;
         ay := y;

         bx := x;
         by := y + tamanho;

         cx := x - tamanho;
         cy := y;

         dx := x;
         dy := y - tamanho;

         showImage.Canvas.Pen.Width := 1;
         showImage.Canvas.Pen.Color := clLtGray;

         showImage.Canvas.Line(x, y, ax, ay);
         showImage.Canvas.Line(x, y, bx, by);
         showImage.Canvas.Line(x, y, cx, cy);
         showImage.Canvas.Line(x, y, dx, dy);

         ponto := returnPointImage;
         drawNameTagAtPoint(x, y, IntToStr(ponto.x) + ', ' + IntToStr(ponto.y))
     end;
end;

procedure TfrmPrincipal.drawNameTagAtPoint(x: Integer; y: Integer; nameTag: string);
begin
    showImage.canvas.Font.Color := clYellow;
    showImage.Canvas.Font.Name := 'courier';
    showImage.Canvas.Brush.Color := clYellow;
    showImage.Canvas.Brush.Style := bsClear;
    showImage.canvas.font.Size := 1;
    showImage.Canvas.TextOut((x + 5), (y + 5), nameTag);
end;

procedure TfrmPrincipal.drawSquare(ponto1: TPoint; ponto2: TPoint; image: TImage);
var
   ax: Integer;
   ay: Integer;
   bx: Integer;
   by: Integer;
   cx: Integer;
   cy: Integer;
   dx: Integer;
   dy: Integer;

begin
    //   A-------B
    //   |       |
    //   |       |
    //   C-------D

    ax := ponto1.x;
    ay := ponto1.y;

    dx := ponto2.x;
    dy := ponto2.y;

    bx := ponto1.x;
    by := ponto2.y;

    cx := ponto2.x;
    cy := ponto1.y;

    image.Canvas.Pen.Width := 2;
    image.Canvas.Pen.Color := clYellow;
    image.Canvas.Brush.Color := clYellow;

    drawPointAt(ax, ay);
    drawPointAt(bx, by);
    drawPointAt(cx, cy);
    drawPointAt(dx, dy);

    image.Canvas.Line(ax, ay, bx, by);
    image.Canvas.Line(ax, ay, cx, cy);
    image.Canvas.Line(cx, cy, dx, dy);
    image.Canvas.Line(bx, by, dx, dy);
end;

procedure TfrmPrincipal.DrawPolygon(image: TImage);
var
  contador: Integer;
  ptInicio: TPoint;
  ptfim: TPoint;
  tamanho: Integer;

begin
    image.Refresh;
    image.Canvas.Pen.Width := 2;
    image.Canvas.Pen.Color := clYellow;
    image.Canvas.Brush.Color := clYellow;

    tamanho := Length(objPoligono);
    if(tamanho > 0) then begin
        for contador := 0 to (tamanho - 2) do begin
            ptInicio := objPoligono[contador];
            ptfim := objPoligono[contador + 1];

            ptInicio.x := ptInicio.x - ScrollBox1.HorzScrollBar.ScrollPos;
            ptInicio.y := ptInicio.y - ScrollBox1.VertScrollBar.ScrollPos;
            ptfim.x := ptfim.x - ScrollBox1.HorzScrollBar.ScrollPos;
            ptfim.y := ptfim.y - ScrollBox1.VertScrollBar.ScrollPos;

            image.Canvas.Line(ptInicio.x, ptInicio.y, ptfim.x, ptfim.y);
            drawPointAt(ptInicio.x, ptInicio.y);
        end;
    end;
end;

procedure TfrmPrincipal.drawPreviousSquares;
var
   tamanho: Integer;
   contador: Integer;
   quadradoLocal: quadrado;

begin
    tamanho := Length(listaQuadrados);
    if(tamanho > 0) then begin
        for contador := 0 to (tamanho - 1) do begin
            quadradoLocal := listaQuadrados[contador];
            quadradoLocal.pontoOrigem.x := quadradoLocal.pontoOrigem.x - ScrollBox1.HorzScrollBar.ScrollPos;
            quadradoLocal.pontoOrigem.y := quadradoLocal.pontoOrigem.y - ScrollBox1.VertScrollBar.ScrollPos;
            quadradoLocal.pontoFim.x := quadradoLocal.pontoFim.x - ScrollBox1.HorzScrollBar.ScrollPos;
            quadradoLocal.pontoFim.y := quadradoLocal.pontoFim.y - ScrollBox1.VertScrollBar.ScrollPos;

            drawSquare(quadradoLocal.pontoOrigem, quadradoLocal.pontoFim, showImage);
            drawPointAt(quadradoLocal.pontoOrigem.x, quadradoLocal.pontoOrigem.y);
            drawPointAt(quadradoLocal.pontoOrigem.x, quadradoLocal.pontoFim.y);
            drawPointAt(quadradoLocal.pontoFim.x, quadradoLocal.pontoOrigem.y);
            drawPointAt(quadradoLocal.pontoFim.x, quadradoLocal.pontoFim.y);
            drawNameTagAtPoint(quadradoLocal.pontoOrigem.x, quadradoLocal.pontoOrigem.y, quadradoLocal.className);
        end;
    end;
end;

procedure TfrmPrincipal.drawPreviousPoligons;
var
   tamanho: Integer;
   tamanhoTemp: Integer;
   contador: Integer;
   contadorTemp: Integer;
   tempPoligono: array of TPoint;
   ptInicio: TPoint;
   ptfim: TPoint;

begin
    showImage.Canvas.Pen.Width := 2;
    showImage.Canvas.Pen.Color := clYellow;
    showImage.Canvas.Brush.Color := clYellow;

    tamanho := Length(listaPoligonos);
    if(tamanho > 0) then begin
        for contador := 0 to (tamanho - 1) do begin
            tempPoligono := listaPoligonos[contador].pontos;

            tamanhoTemp := Length(tempPoligono) - 1;
            for contadorTemp := 0 to (tamanhoTemp - 1) do begin
                ptInicio := tempPoligono[contadorTemp];
                ptfim := tempPoligono[contadorTemp + 1];

                ptInicio.x := ptInicio.x - ScrollBox1.HorzScrollBar.ScrollPos;
                ptInicio.y := ptInicio.y - ScrollBox1.VertScrollBar.ScrollPos;
                ptfim.x := ptfim.x - ScrollBox1.HorzScrollBar.ScrollPos;
                ptfim.y := ptfim.y - ScrollBox1.VertScrollBar.ScrollPos;

                showImage.Canvas.Line(ptInicio.x, ptInicio.y, ptfim.x, ptfim.y);
                drawPointAt(ptInicio.x, ptInicio.y);
            end;
            ptInicio := tempPoligono[0];
            ptfim := tempPoligono[tamanhoTemp];

            ptInicio.x := ptInicio.x - ScrollBox1.HorzScrollBar.ScrollPos;
            ptInicio.y := ptInicio.y - ScrollBox1.VertScrollBar.ScrollPos;
            ptfim.x := ptfim.x - ScrollBox1.HorzScrollBar.ScrollPos;
            ptfim.y := ptfim.y - ScrollBox1.VertScrollBar.ScrollPos;

            showImage.Canvas.Line(ptInicio.x, ptInicio.y, ptfim.x, ptfim.y);
            drawNameTagAtPoint(ptInicio.x, ptInicio.y, listaPoligonos[contador].className);
            drawPointAt(ptInicio.x, ptInicio.y);
        end;
    end;
end;

procedure TfrmPrincipal.drawAnnotation;
var
  pontoFinal: TPoint;

begin
  if(rdbPoligon.Checked = True) then begin
     if(desenhando = True) then
         DrawPolygon(showImage);
  end;
  if(rdbSquare.Checked = True) then begin
    if((ponto2.x = 0) and (ponto2.y = 0)) then begin
          pontoFinal := returnPointScroll;
    end else begin
          pontoFinal := ponto2;
    end;
    if(desenhando = True) then
        drawSquare(ponto1, pontoFinal, showImage);
  end;
end;

procedure TfrmPrincipal.registraMensagem(msg: string; nomeArquivo: string);
  var
    f: Text;
    msgError: string;

  begin
    try
        AssignFile(f, nomeArquivo);
        if FileExists(nomeArquivo) then begin
            Append(f);
        end else begin
            ReWrite(f);
        end;
        Write(f, #10 + msg);
        CloseFile(f);
    except on E: Exception do begin
        msgError := 'Error: ' + E.Message;
        showCustomMessage(msgError, 3);
    end;
  end;
end;

procedure TfrmPrincipal.savePascalVoc;
var
  nomeArquivo: String;
  nomeImagem: String;
  diretorio: String;
  lista: TStringList;
  tamanho: Integer;
  contador: Integer;
  contPonto: Integer;
  tamanhoPonto: Integer;

begin
     nomeImagem := txtDir.Text + '\' + chlImagens.Items[chlImagens.ItemIndex];
     nomeArquivo := StringReplace(nomeImagem, '.jpg', '.xml', [rfReplaceAll, rfIgnoreCase]);
     nomeArquivo := StringReplace(nomeArquivo, '.png', '.xml', [rfReplaceAll, rfIgnoreCase]);

     diretorio := StringReplace(txtDir.Text, '\', '-', [rfReplaceAll, rfIgnoreCase]);
     lista := splitString(diretorio, '-');
     diretorio := lista[(lista.Count - 1)];

     if(FileExists(nomeArquivo)) then begin
        DeleteFile(PChar(nomeArquivo));
     end;
     registraMensagem('<annotation>', nomeArquivo);
     registraMensagem(#9 + '<folder>' + diretorio + '</folder>', nomeArquivo);
     registraMensagem(#9 + '<filename>' + chlImagens.Items[chlImagens.ItemIndex] + '</filename>', nomeArquivo);
     registraMensagem(#9 + '<path>' + txtDir.Text + '\' + chlImagens.Items[chlImagens.ItemIndex] + '</path>', nomeArquivo);
     registraMensagem(#9 + '<source>', nomeArquivo);
     registraMensagem(#9 + #9 + '<database>Unknown</database>', nomeArquivo);
     registraMensagem(#9 + '</source>', nomeArquivo);
     registraMensagem(#9 + '<size>', nomeArquivo);
     registraMensagem(#9 + #9 + '<width>' + IntToStr(showImage.Picture.Width) + '</width>', nomeArquivo);
     registraMensagem(#9 + #9 + '<height>' + IntToStr(showImage.Picture.Height) + '</height>', nomeArquivo);
     registraMensagem(#9 + #9 + '<depth>3</depth>', nomeArquivo);
     registraMensagem(#9 + '</size>', nomeArquivo);
     registraMensagem(#9 + '<segmented>0</segmented>', nomeArquivo);

        tamanho := Length(listaQuadrados);
        if(tamanho > 0) then begin
            for contador := 0 to (tamanho - 1) do begin
                registraMensagem(#9 + '<object>', nomeArquivo);
                registraMensagem(#9 + #9 + '<name>' + listaQuadrados[contador].className + '</name>', nomeArquivo);
                registraMensagem(#9 + #9 +'<pose>Unspecified</pose>', nomeArquivo);
                registraMensagem(#9 + #9 + '<truncated>0</truncated>', nomeArquivo);
                registraMensagem(#9 + #9 + '<occluded>0</occluded>', nomeArquivo);
                registraMensagem(#9 + #9 + '<difficult>0</difficult>', nomeArquivo);
                registraMensagem(#9 + #9 + '<bndbox>', nomeArquivo);

                registraMensagem(#9 + #9 + #9 + '<xmin>' + IntToStr(listaQuadrados[contador].pontoOrigem.x) + '</xmin>', nomeArquivo);
                registraMensagem(#9 + #9 + #9 + '<ymin>' + IntToStr(listaQuadrados[contador].pontoOrigem.y) + '</ymin>', nomeArquivo);

                registraMensagem(#9 + #9 + #9 + '<xmax>' + IntToStr(listaQuadrados[contador].pontoFim.x) + '</xmax>', nomeArquivo);
                registraMensagem(#9 + #9 + #9 + '<ymax>' + IntToStr(listaQuadrados[contador].pontoFim.y) + '</ymax>', nomeArquivo);

                registraMensagem(#9 + #9 + '</bndbox>', nomeArquivo);
                registraMensagem(#9 + '</object>', nomeArquivo);
            end;
        end;
        tamanho := Length(listaPoligonos);
        if(tamanho > 0) then begin
            for contador := 0 to (tamanho - 1) do begin
                registraMensagem(#9 + '<object>', nomeArquivo);
                registraMensagem(#9 + #9 + '<name>' + listaPoligonos[contador].className + '</name>', nomeArquivo);
                registraMensagem(#9 + #9 + '<pose>Unspecified</pose>', nomeArquivo);
                registraMensagem(#9 + #9 + '<truncated>0</truncated>', nomeArquivo);
                registraMensagem(#9 + #9 + '<occluded>0</occluded>', nomeArquivo);
                registraMensagem(#9 +  #9 + '<difficult>0</difficult>', nomeArquivo);
                registraMensagem(#9 + #9 + '<polygon>', nomeArquivo);

                tamanhoPonto := Length(listaPoligonos[contador].pontos);
                if(tamanhoPonto > 0) then begin
                    for contPonto := 0 to (tamanhoPonto - 1) do begin
                        registraMensagem(#9 + #9 + #9 + '<x' + IntToStr(contPonto + 1) + '>' + IntToStr(listaPoligonos[contador].pontos[contPonto].x) + '</x' + IntToStr(contPonto + 1) + '>', nomeArquivo);
                        registraMensagem(#9 + #9 + #9 + '<y' + IntToStr(contPonto + 1) + '>' + IntToStr(listaPoligonos[contador].pontos[contPonto].y) + '</y' + IntToStr(contPonto + 1) + '>', nomeArquivo);
                    end;
                end;
                registraMensagem(#9 + #9 + '</polygon>', nomeArquivo);
                registraMensagem(#9 + '</object>', nomeArquivo);
            end;
        end;
        registraMensagem('</annotation>', nomeArquivo);
end;

procedure TfrmPrincipal.saveYolo;
var
  nomeArquivo: String;
  nomeImagem: String;
  tamanho: Integer;
  contador: Integer;
  contPonto: Integer;
  tamanhoPonto: Integer;
  linha: string;
  space: string;

begin
     nomeImagem := txtDir.Text + '\' + chlImagens.Items[chlImagens.ItemIndex];
     nomeArquivo := StringReplace(nomeImagem, '.jpg', '.txt', [rfReplaceAll, rfIgnoreCase]);
     nomeArquivo := StringReplace(nomeArquivo, '.png', '.txt', [rfReplaceAll, rfIgnoreCase]);
     space := '   ';

     if(FileExists(nomeArquivo)) then begin
        DeleteFile(PChar(nomeArquivo));
     end;
        tamanho := Length(listaQuadrados);
        if(tamanho > 0) then begin
            for contador := 0 to (tamanho - 1) do begin
                linha := '';
                linha := IntToStr(listaQuadrados[contador].classID);
                linha := linha + space + IntToStr(listaQuadrados[contador].pontoOrigem.x);
                linha := linha + space + IntToStr(listaQuadrados[contador].pontoOrigem.y);
                linha := linha + space + IntToStr(listaQuadrados[contador].pontoFim.x);
                linha := linha + space + IntToStr(listaQuadrados[contador].pontoFim.y);
                registraMensagem(linha, nomeArquivo);
            end;
        end;
        tamanho := Length(listaPoligonos);
        if(tamanho > 0) then begin
            for contador := 0 to (tamanho - 1) do begin
                linha := '';
                linha := IntToStr(listaPoligonos[contador].classID);
                tamanhoPonto := Length(listaPoligonos[contador].pontos);
                if(tamanhoPonto > 0) then begin
                    for contPonto := 0 to (tamanhoPonto - 1) do begin
                        linha := linha + space + IntToStr(listaPoligonos[contador].pontos[contPonto].x);
                        linha := linha + space + IntToStr(listaPoligonos[contador].pontos[contPonto].y);
                    end;
                end;
                registraMensagem(linha, nomeArquivo);
            end;
        end;
end;

procedure TfrmPrincipal.saveCocoo;
var
  nomeArquivo: String;
  nomeImagem: String;
  diretorio: String;
  lista: TStringList;
  tamanho: Integer;
  contador: Integer;
  contPonto: Integer;
  tamanhoPonto: Integer;

begin
     nomeImagem := txtDir.Text + '\\' + chlImagens.Items[chlImagens.ItemIndex];
     nomeArquivo := StringReplace(nomeImagem, '.jpg', '.xml', [rfReplaceAll, rfIgnoreCase]);
     nomeArquivo := StringReplace(nomeArquivo, '.png', '.xml', [rfReplaceAll, rfIgnoreCase]);

     diretorio := StringReplace(txtDir.Text, '\', '-', [rfReplaceAll, rfIgnoreCase]);
     lista := splitString(diretorio, '-');
     diretorio := lista[lista.Count];

     if(FileExists(nomeArquivo)) then begin
        DeleteFile(PChar(nomeArquivo));
     end;
        registraMensagem('<annotation>', nomeArquivo);
        registraMensagem(#9 + '<folder>' + diretorio + '</folder>', nomeArquivo);
        registraMensagem(#9 + '<filename>' + chlImagens.Items[chlImagens.ItemIndex] + '</filename>', nomeArquivo);
        registraMensagem(#9 + '<size>', nomeArquivo);
        registraMensagem(#9 + #9 + '<width>' + IntToStr(showImage.Picture.Width) + '</width>', nomeArquivo);
        registraMensagem(#9 + #9 + '<height>' + IntToStr(showImage.Picture.Height) + '</height>', nomeArquivo);
        registraMensagem(#9 + #9 + '<depth>3</depth>', nomeArquivo);
        registraMensagem(#9 + '<\size>', nomeArquivo);
        registraMensagem(#9 + '<segmented>0</segmented>', nomeArquivo);

        tamanho := Length(listaQuadrados);
        if(tamanho > 0) then begin
            for contador := 0 to (tamanho - 1) do begin
                registraMensagem(#9 + '<object>', nomeArquivo);
                registraMensagem(#9 + #9 + '<name>' + listaQuadrados[contador].className + '</name>', nomeArquivo);
                registraMensagem(#9 + #9 + '<pose>Unspecified</pose>', nomeArquivo);
                registraMensagem(#9 + #9 + '<truncated>0</truncated>', nomeArquivo);
                registraMensagem(#9 + #9 + '<occluded>0</occluded>', nomeArquivo);
                registraMensagem(#9 + #9 + '<difficult>0</difficult>', nomeArquivo);
                registraMensagem(#9 + #9 + '<bndbox>', nomeArquivo);

                registraMensagem(#9 + #9 + #9 + '<xmin>' + IntToStr(listaQuadrados[contador].pontoOrigem.x) + '</xmin>', nomeArquivo);
                registraMensagem(#9 + #9 + #9 + '<ymin>' + IntToStr(listaQuadrados[contador].pontoOrigem.y) + '</ymin>', nomeArquivo);

                registraMensagem(#9 + #9 + #9 + '<xmax>' + IntToStr(listaQuadrados[contador].pontoFim.x) + '</xmax>', nomeArquivo);
                registraMensagem(#9 + #9 + #9 + '<ymax>' + IntToStr(listaQuadrados[contador].pontoFim.y) + '</ymax>', nomeArquivo);

                registraMensagem(#9 + #9 + '<\bndbox>', nomeArquivo);
                registraMensagem(#9 + '<\object>', nomeArquivo);
            end;
        end;
        tamanho := Length(listaPoligonos);
        if(tamanho > 0) then begin
            for contador := 0 to (tamanho - 1) do begin
                registraMensagem(#9 + '<object>', nomeArquivo);
                registraMensagem(#9 + #9 + '<name>' + listaPoligonos[contador].className + '</name>', nomeArquivo);
                registraMensagem(#9 + #9 + '<pose>Unspecified</pose>', nomeArquivo);
                registraMensagem(#9 + #9 + '<truncated>0</truncated>', nomeArquivo);
                registraMensagem(#9 + #9 + '<occluded>0</occluded>', nomeArquivo);
                registraMensagem(#9 + #9 + '<difficult>0</difficult>', nomeArquivo);
                registraMensagem(#9 + #9 + '<polygon>', nomeArquivo);

                tamanhoPonto := Length(listaPoligonos[contador].pontos);
                if(tamanhoPonto > 0) then begin
                    for contPonto := 0 to (tamanhoPonto - 1) do begin
                        registraMensagem(#9 + #9 + #9 + '<x' + IntToStr(contPonto + 1) + '>' + IntToStr(listaPoligonos[contador].pontos[contPonto].x) + '</x' + IntToStr(contPonto + 1) + '>', nomeArquivo);
                        registraMensagem(#9 + #9 + #9 + '<y' + IntToStr(contPonto + 1) + '>' + IntToStr(listaPoligonos[contador].pontos[contPonto].y) + '</y' + IntToStr(contPonto + 1) + '>', nomeArquivo);
                    end;
                end;
                registraMensagem(#9 + #9 + '<\polygon>', nomeArquivo);
                registraMensagem(#9 + '<\object>', nomeArquivo);
            end;
        end;
        registraMensagem('</annotation>', nomeArquivo);
end;

procedure TfrmPrincipal.savePoints;
var
  tamanhoQuad: Integer;
  tamanhoPoly: Integer;
  contador: Integer;
  valido: Boolean;

begin
    tamanhoQuad := Length(listaQuadrados);
    tamanhoPoly := Length(listaPoligonos);

    if((tamanhoQuad <= 0) and (tamanhoPoly <= 0) ) then begin
       showCustomMessage('No data to safe.', 2);
       drawPreviousPoligons;
       drawPreviousSquares;
       Exit;
    end;
    if((rdbPV2012.Checked = False) and (rdbYolo.Checked = False)) then begin
       showCustomMessage('Please, select annotation type.', 2);
       drawPreviousPoligons;
       drawPreviousSquares;
       Exit;
    end;
    contador := chlImagens.ItemIndex;
    if(contador < 0) then begin
       showCustomMessage('Please, select a image to work.', 2);
       drawPreviousPoligons;
       drawPreviousSquares;
       Exit;
    end;

    valido := True;
    tamanhoQuad := Length(listaQuadrados);
    if(tamanhoQuad > 0) then begin
        for contador := 0 to (tamanhoQuad - 1) do begin
            if(listaQuadrados[contador].className = '') then begin
                valido := False;
            end;
        end;
    end;
    tamanhoPoly := Length(listaPoligonos);
    if(tamanhoPoly > 0) then begin
        for contador := 0 to (tamanhoPoly - 1) do begin
            if(listaPoligonos[contador].className = '') then begin
                valido := False;
            end;
        end;
    end;
    if(valido = False) then begin
       showCustomMessage('Attention. ' + #10 + #13 + 'There is one or more annotation without class definition.', 2);
       drawPreviousPoligons;
       drawPreviousSquares;
       Exit;
    end;

    stop := Now;
    elapsed := stop - start;
    StatusBar1.Panels.Items[7].Text := 'Time Used: ' + TimeToStr(elapsed);

    if(rdbPV2012.Checked = True)then begin
        savePascalVoc;
    end;
    if(rdbYolo.Checked = True)then begin
        saveYolo;
    end;
    drawMaskFile;
    showCustomMessage('Annotation saved.', 2);
    drawPreviousPoligons;
    drawPreviousSquares;
end;

procedure TfrmPrincipal.getClass;
begin
    uGlobalVars.caminhoArquivo := txtDir.Text;
    caixaClasses := TfrmClasses.Create(Self);
    caixaClasses.ShowModal;
end;

procedure TfrmPrincipal.loadExistFile;
var
    nomeImagem: string;
    nomeArquivo: string;
    nomeArquivoFinal: string;
    cont: Integer;

begin
    nomeArquivoFinal := '';
    nomeImagem := txtDir.Text + '\' + chlImagens.Items[chlImagens.ItemIndex];

    nomeArquivo := StringReplace(nomeImagem, '.jpg', '.txt', [rfReplaceAll, rfIgnoreCase]);
    nomeArquivo := StringReplace(nomeArquivo, '.png', '.txt', [rfReplaceAll, rfIgnoreCase]);
    if(FileExists(nomeArquivo)) then begin
        nomeArquivoFinal := nomeArquivo;
    end;

    nomeArquivo := StringReplace(nomeImagem, '.jpg', '.xml', [rfReplaceAll, rfIgnoreCase]);
    nomeArquivo := StringReplace(nomeArquivo, '.png', '.xml', [rfReplaceAll, rfIgnoreCase]);
    if(FileExists(nomeArquivo)) then begin
        nomeArquivoFinal := nomeArquivo;
    end;

    cont := CompareStr(nomeArquivoFinal, '');
    if(cont <> 0)then begin
        clearPoints;
        cont := Pos('.txt', LowerCase(nomeArquivoFinal));
        if(cont > 0) then begin
            rdbYolo.Checked := True;
            loadYolo(nomeArquivoFinal)
        end else begin
            rdbPV2012.Checked := True;
            loadCocooPascal(nomeArquivoFinal);
        end;

        drawPreviousPoligons;
        drawPreviousSquares;

        ponto1.x := 0;
        ponto1.y := 0;
        ponto2.x := 0;
        ponto2.y := 0;
    end;
end;

procedure TfrmPrincipal.loadYolo(nomeArquivo: string);
var
    f: Text;
    linha: string;
    space: string;
    lstLinha: TStringList;
    objQuadrado: quadrado;
    objPol: poligono;
    tamanho: Integer;
    contadorPar: Integer;
    objPonto: TPoint;

begin
    space := '   ';
    if(FileExists(nomeArquivo)) then begin
        AssignFile(f, nomeArquivo);
        Reset(f);
        if(IORESULT <> 0) then begin
            ShowMessage('error opening file for reading');
        end else begin
            while not eof(f) do begin
                readln(f, linha);
                if(linha <> '') then begin
                    linha := StringReplace(linha, space, '#', [rfReplaceAll, rfIgnoreCase]);
                    lstLinha := splitString(linha, '#');
                    if(lstLinha.Count = 5) then begin
                        objQuadrado.classID := StrToInt(lstLinha[0]);
                        objQuadrado.className := returnNameClass(objQuadrado.classID);
                        objQuadrado.pontoOrigem.x := StrToInt(lstLinha[1]);
                        objQuadrado.pontoOrigem.y := StrToInt(lstLinha[2]);
                        objQuadrado.pontoFim.x := StrToInt(lstLinha[3]);
                        objQuadrado.pontoFim.y := StrToInt(lstLinha[4]);

                        tamanho := Length(listaQuadrados);
                        SetLength(listaQuadrados, (tamanho + 1));
                        listaQuadrados[tamanho] := objQuadrado;


                    end else begin

                      objPol.classID := StrToInt(lstLinha[0]);
                      objPol.className := returnNameClass(objPol.classID);
                      contadorPar := 2;
                      while(contadorPar < (lstLinha.Count - 1)) do begin

                          objPonto.x := StrToInt(lstLinha[contadorPar]);
                          objPonto.y := StrToInt(lstLinha[contadorPar + 1]);

                          tamanho := Length(objPol.pontos);
                          SetLength(objPol.pontos, (tamanho  + 1));
                          objPol.pontos[tamanho] := objPonto;

                          contadorPar := contadorPar + 2;
                      end;
                      tamanho := Length(listaPoligonos);
                      SetLength(listaPoligonos, (tamanho + 1));
                      listaPoligonos[tamanho] := objPol;
                    end;
                end;
            end;
        end;
        CloseFile(f);
    end;
end;

function TfrmPrincipal.returnNameClass(idClass: Integer): string;
var
    f: Text;
    linha: string;
    contador: Integer;
    nomeClasse: string;
    nomeArquivo: string;

begin
    nomeArquivo := txtDir.Text + '\classes.txt' ;
    contador := 0;
    nomeClasse := '';
    if(FileExists(nomeArquivo)) then begin
        AssignFile(f, nomeArquivo);
        Reset(f);
        if(IORESULT <> 0) then begin
            ShowMessage('error opening file for reading');
        end else begin
            while not eof(f) do begin
                ReadLn(f, linha);
                if(contador = idClass) then begin
                    nomeClasse := linha;
                end;
                contador := contador + 1;
            end;
        end;
        CloseFile(f);
    end;
    Result := nomeClasse;
end;

function TfrmPrincipal.returnIdClass(nomeClass: String): Integer;
var
    f: Text;
    linha: string;
    contador: Integer;
    idClasse: Integer;
    nomeArquivo: string;
    strEqual: Integer;

begin
    nomeArquivo := txtDir.Text + '\classes.txt' ;
    idClasse := 0;
    contador := 0;
    if(FileExists(nomeArquivo)) then begin
        AssignFile(f, nomeArquivo);
        Reset(f);
        if(IORESULT <> 0) then begin
            ShowMessage('error opening file for reading');
        end else begin
            while not eof(f) do begin
                ReadLn(f, linha);
                strEqual := CompareStr(LowerCase(linha), LowerCase(nomeClass));
                if(strEqual = 0) then begin
                    idClasse := contador;
                end;
                contador := contador + 1;
            end;
        end;
        CloseFile(f);
    end;
    Result := idClasse;
end;

procedure TfrmPrincipal.loadCocooPascal(nomeArquivo: string);
var
    Doc: TXMLDocument;
    strTemp: String;
    Child: TDOMNode;
    j: Integer;
    sssss: LongWord;
    nomeClasse: String;
    isX: Boolean;
    nodeFilho: TDOMNode;
    tamanho: Integer;
    ponto: TPoint;
    contSquare: Integer;
    objSquare: quadrado;
    msgError: string;

begin
    if(FileExists(nomeArquivo)) then begin
        try
            ReadXMLFile(Doc, nomeArquivo);
            Child := Doc.DocumentElement.FirstChild;
            while Assigned(Child) do begin
                strTemp := Child.NodeName;
                sssss := CompareStr('object', LowerCase(strTemp));
                if(sssss = 0) then begin
                    sssss := Child.ChildNodes.Count;
                    if(sssss > 1) then begin
                        nomeClasse := '';
                        with Child.ChildNodes do try
                            for j := 0 to (Count - 1) do begin
                                strTemp := Item[j].NodeName;
                                sssss := CompareStr('name', LowerCase(strTemp));
                                if(sssss = 0) then begin
                                    nomeClasse := Item[j].FirstChild.NodeValue;
                                end;
                                sssss := CompareStr('polygon', LowerCase(strTemp));
                                if(sssss = 0) then begin
                                    isX := True;
                                    nodeFilho := Item[j].FirstChild;
                                    while Assigned(nodeFilho) do begin
                                        strTemp := nodeFilho.TextContent;
                                        if(isX = True) then begin
                                            ponto.x := StrToInt(strTemp);
                                        end;
                                        if(isX = False) then begin
                                            ponto.y := StrToInt(strTemp);
                                            tamanho := system.Length(objPoligono);
                                            SetLength(objPoligono, tamanho  + 1);
                                            objPoligono[tamanho] := ponto;
                                        end;
                                        isX := not isX;
                                        nodeFilho := nodeFilho.NextSibling;
                                    end;
                                    sssss := system.Length(objPoligono);
                                    if(sssss > 0) then begin
                                        tamanho := system.Length(listaPoligonos);
                                        SetLength(listaPoligonos, tamanho + 1);
                                        listaPoligonos[tamanho].pontos := objPoligono;
                                        listaPoligonos[tamanho].className := nomeClasse;
                                        listaPoligonos[tamanho].classID := returnIdClass(nomeClasse);
                                        SetLength(objPoligono, 0);
                                    end;
                                end;
                                sssss := CompareStr('bndbox', LowerCase(strTemp));
                                if(sssss = 0) then begin
                                    contSquare := 0;
                                    nodeFilho := Item[j].FirstChild;
                                    while Assigned(nodeFilho) do begin
                                        strTemp := nodeFilho.TextContent;
                                        if(contSquare = 0) then begin
                                            ponto1.x := StrToInt(strTemp);
                                        end;
                                        if(contSquare = 1) then begin
                                            ponto1.y := StrToInt(strTemp);
                                        end;
                                        if(contSquare = 2) then begin
                                            ponto2.x := StrToInt(strTemp);
                                        end;
                                        if(contSquare = 3) then begin
                                            ponto2.y := StrToInt(strTemp);

                                            objSquare.pontoOrigem.x := ponto1.x ;
                                            objSquare.pontoOrigem.y := ponto1.y ;
                                            objSquare.pontoFim.x := ponto2.x ;
                                            objSquare.pontoFim.y := ponto2.y ;
                                            objSquare.className := nomeClasse;
                                            objSquare.classID := returnIdClass(nomeClasse);

                                            tamanho := system.Length(listaQuadrados);
                                            SetLength(listaQuadrados, tamanho + 1);
                                            listaQuadrados[tamanho] := objSquare;
                                        end;
                                        contSquare := contSquare + 1;
                                        if(contSquare > 3) then begin
                                            contSquare := 0;
                                        end;
                                        nodeFilho := nodeFilho.NextSibling;
                                    end;
                                end;
                            end;
                        except on E: Exception do begin
                            msgError := 'Error: ' + E.Message;
                            showCustomMessage(msgError, 3);
                            end;
                        end;
                    end;
                end;
                Child := Child.NextSibling;
            end;
        finally
            Doc.Free;
        end;
    end;
end;

procedure TfrmPrincipal.countAnnotation;
var
    ext: string;
    sl: TStringList;

begin
    ext := '*.xml';
    if(rdbYolo.Checked = True) then begin
        ext := '*.txt';
    end;
    sl := FindAllFiles(txtDir.Text, ext, True);
    StatusBar1.Panels.Items[6].Text := 'Annotations = ' + IntToStr(sl.Count);
end;

function TfrmPrincipal.IsPointInPolygon(AX, AY: Integer; APolygon: array of TPoint): Boolean;
var
    xnew: Cardinal;
    ynew: Cardinal;
    xold: Cardinal;
    yold: Cardinal;
    x1: Cardinal;
    y1: Cardinal;
    x2: Cardinal;
    y2: Cardinal;
    i: Integer;
    npoints: Integer;
    inside: Integer = 0;

begin
    Result := False;
    npoints := Length(APolygon);
    if (npoints < 3) then Exit;
    xold := APolygon[npoints-1].X;
    yold := APolygon[npoints-1].Y;
    for i := 0 to npoints - 1 do begin
        xnew := APolygon[i].X;
        ynew := APolygon[i].Y;
        if (xnew > xold) then begin
            x1 := xold;
            x2 := xnew;
            y1 := yold;
            y2 := ynew;
        end else begin
            x1 := xnew;
            x2 := xold;
            y1 := ynew;
            y2 := yold;
        end;
        if (((xnew < AX) = (AX <= xold)) and ((AY-y1)*(x2-x1) < (y2-y1)*(AX-x1))) then begin
            inside := not inside;
        end;
        xold := xnew;
        yold := ynew;
    end;
    Result := inside <> 0;
end;

procedure TfrmPrincipal.drawMaskFile;
var
    tamanho: Integer;
    contador: Integer;
    novaImagem: TImage;
    poligon: array of TPoint;
    nomeImagem: string;
    pInicio: TPoint;
    pFim: TPoint;
    cont: Integer;
    tam: Integer;
    contVert: LongInt;
    contHori: LongInt;
    percentePoligono: Boolean;

begin
    if((rdbPoligon.Checked = True) and (chkMasks.Checked = True)) then begin
        tamanho := Length(listaPoligonos);
        for contador := 0 to (tamanho - 1) do begin
            novaImagem := TImage.Create(Self);

            novaImagem.Height := showImage.Height;
            novaImagem.Width := showImage.Width;
            novaImagem.Top := showImage.Top;
            novaImagem.Tag := showImage.Tag;

            novaImagem.Canvas.Brush.Color:= clBlue;
            novaImagem.Canvas.Rectangle(0, 0, showImage.Width, showImage.Height);

            novaImagem.Canvas.Pen.Width := 2;
            novaImagem.Canvas.Pen.Color := clYellow;
            novaImagem.Canvas.Brush.Color := clYellow;
            poligon := listaPoligonos[contador].pontos;
            tam := Length(poligon);
            for cont := 0 to (tam - 2) do begin
                pInicio := poligon[cont];
                pFim := poligon[cont + 1];
                novaImagem.Canvas.Line(pInicio.x, pInicio.y, pFim.x, pFim.y);
            end;
            pInicio := poligon[0];
            pFim := poligon[tam - 1];
            novaImagem.Canvas.Line(pInicio.x, pInicio.y, pFim.x, pFim.y);

            for contHori := 0 to (novaImagem.Canvas.Width - 1) do begin
                for contVert := 0 to (novaImagem.Canvas.Height - 1) do begin
                    percentePoligono := IsPointInPolygon(contHori, contVert, poligon);
                    if(percentePoligono = True) then begin
                        novaImagem.Canvas.Pixels[contHori, contVert] := clYellow;
                    end;
                end;
            end;
            nomeImagem := txtDir.Text + '\' + chlImagens.Items[chlImagens.ItemIndex];
            nomeImagem := nomeImagem.Replace('.jpg', '_mask_' + IntToStr(contador) + '.jpg');
            novaImagem.Picture.SaveToFile(nomeImagem);
        end;
    end;
end;

procedure TfrmPrincipal.saveAllCrops;
var
   tamanho: Integer;
   contador: Integer;
   largura: Integer;
   altura: Integer;
   imageTemp: TImage;
   nomeSubDir: String;
   nomeCompletoImagem: String;
   nomeCaminhoCompleto: string;
   nomeImagem: string;
   contadorNomes: Integer;
   existe: Boolean;
   quadradoLocal: quadrado;
   delta: Integer;

begin
  tamanho := Length(listaQuadrados);
  if(tamanho > 0) then begin
      showImage.Refresh;
      for contador := 0 to (tamanho - 1) do begin
          imageTemp := TImage.Create(Self);

          quadradoLocal := listaQuadrados[contador];

          ScrollBox1.HorzScrollBar.Position := round((quadradoLocal.pontoFim.x / 2));

          delta := round((quadradoLocal.pontoFim.y / 2));
          if(quadradoLocal.pontoFim.y >= ((showImage.Picture.Height / 3) * 2))then begin
              delta := delta + 250; //180
          end;
          ScrollBox1.VertScrollBar.Position := delta;
          ScrollBox1.Refresh;
          delay(200);

          quadradoLocal.pontoOrigem.x := quadradoLocal.pontoOrigem.x - ScrollBox1.HorzScrollBar.ScrollPos;
          quadradoLocal.pontoOrigem.y := quadradoLocal.pontoOrigem.y - ScrollBox1.VertScrollBar.ScrollPos;
          quadradoLocal.pontoFim.x := quadradoLocal.pontoFim.x - ScrollBox1.HorzScrollBar.ScrollPos;
          quadradoLocal.pontoFim.y := quadradoLocal.pontoFim.y - ScrollBox1.VertScrollBar.ScrollPos;

          largura := (quadradoLocal.pontoFim.x - quadradoLocal.pontoOrigem.x);
          altura := (quadradoLocal.pontoFim.y - quadradoLocal.pontoOrigem.y);

          imageTemp.Width := largura;
          imageTemp.Height := altura;
          imageTemp.Canvas.Copyrect(Rect(0, 0, largura, altura), showImage.Canvas,Rect(quadradoLocal.pontoOrigem.x, quadradoLocal.pontoOrigem.y, quadradoLocal.pontoFim.x, quadradoLocal.pontoFim.y));

          nomeSubDir := quadradoLocal.className;
          if(nomeSubDir = '') then begin
              nomeSubDir := IntToStr(quadradoLocal.classID);
          end;

          nomeCaminhoCompleto := txtDir.Text + '\Croppeds';
          if(not(DirectoryExists(nomeCaminhoCompleto)))then begin
              CreateDir(nomeCaminhoCompleto);
          end;
          nomeCaminhoCompleto := txtDir.Text + '\Croppeds\' + nomeSubDir;
          if(not(DirectoryExists(nomeCaminhoCompleto)))then begin
              CreateDir(nomeCaminhoCompleto);
          end;

          contadorNomes := 0;
          nomeImagem := nomeSubDir + '.jpg';
          nomeCompletoImagem := nomeCaminhoCompleto + '\' + nomeImagem;
          if FileExists(nomeCompletoImagem) then begin
              existe := True;
              while(existe = True) do begin
                  nomeImagem := nomeSubDir + '(' + IntToStr(contadorNomes) + ').jpg';
                  nomeCompletoImagem := nomeCaminhoCompleto + '\'  + nomeImagem;
                  contadorNomes := contadorNomes + 1;
                  existe := FileExists(nomeCompletoImagem);
              end;
          end;

          imageTemp.Picture.SaveToFile(nomeCompletoImagem);
          imageTemp.Free;

      end;
  end else begin
      showCustomMessage('No annotations boxes found!!!', 3);
  end;
end;

{%endregion}

{%region 'Eventos'}

procedure TfrmPrincipal.showImageClick(Sender: TObject);
var
  pt : tPoint;

begin
  pt := returnPointScroll;
  colectPoint(pt);
  if(rdbPoligon.Checked = True) then begin
      drawAnnotation;
  end;

end;

procedure TfrmPrincipal.showImageDblClick(Sender: TObject);
var
  tamanho: Integer;
  ponto: TPoint;

begin
    if(rdbPoligon.Checked = True) then begin
      tamanho := Length(objPoligono);
      if((desenhando = True) and (tamanho > 0)) then begin
          desenhando := False;

          ponto := returnPointScroll;
          SetLength(objPoligono, tamanho + 1);
          objPoligono[tamanho] := ponto;

          ponto := returnPointImage;
          tamanho := Length(objPoligonoReal);
          SetLength(objPoligonoReal, tamanho + 1);
          objPoligonoReal[tamanho] := ponto;

          tamanho := Length(listaPoligonos);
          SetLength(listaPoligonos, tamanho + 1);

          uGlobalVars.globalClassID := 0;
          uGlobalVars.globalClassName := '';
          getClass;
          listaPoligonos[tamanho].classID := uGlobalVars.globalClassID;
          listaPoligonos[tamanho].className := uGlobalVars.globalClassName;
          listaPoligonos[tamanho].pontos := objPoligonoReal;
          SetLength(objPoligono, 0);
          SetLength(objPoligonoReal, 0);

          drawPreviousPoligons;
          drawPreviousSquares;
      end;
  end;
end;

procedure TfrmPrincipal.showImageMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
    resumo: string;

begin
    showImage.Refresh;
    showImage.Canvas.Refresh;
    drawAnnotation;
    if(rdbPoligon.Checked = True) then begin
        DrawPolygon(showImage);
    end;
    drawPreviousPoligons;
    drawPreviousSquares;
    drawCrossAt;

    resumo := 'X = ' + IntToStr(X) + ', Y = ' + IntToStr(Y);
    StatusBar1.Panels.Items[2].Text := resumo;
end;

procedure TfrmPrincipal.showImageMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TfrmPrincipal.showImageMouseWheelDown(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
    if(zoom > 0) then
        zoom := zoom - 1;
    StatusBar1.Panels.Items[3].Text := '  Zoom = ' + IntToStr(zoom);

end;

procedure TfrmPrincipal.showImageMouseWheelUp(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
    zoom := zoom + 1;
    StatusBar1.Panels.Items[3].Text := '  Zoom = ' + IntToStr(zoom);

end;

procedure TfrmPrincipal.btnAnteriorClick(Sender: TObject);
var
    tamanho: Integer;
    nomeArquivo: string;
    nomeImagem: string;
    existe: Boolean;

begin
     existe := False;
     tamanho := Length(listaPoligonos);
     if(tamanho > 0) then begin
         nomeArquivo := '';
         nomeImagem := txtDir.Text + '\' + chlImagens.Items[chlImagens.ItemIndex];

         nomeArquivo := StringReplace(nomeImagem, '.jpg', '.txt', [rfReplaceAll, rfIgnoreCase]);
         nomeArquivo := StringReplace(nomeArquivo, '.png', '.txt', [rfReplaceAll, rfIgnoreCase]);
         existe := FileExists(nomeArquivo);

         if(existe = False) then begin
             nomeArquivo := StringReplace(nomeImagem, '.jpg', '.xml', [rfReplaceAll, rfIgnoreCase]);
             nomeArquivo := StringReplace(nomeArquivo, '.png', '.xml', [rfReplaceAll, rfIgnoreCase]);
             existe := FileExists(nomeArquivo);
         end;
         if(existe = False) then begin
             savePoints;
         end;
     end;
     if(chlImagens.ItemIndex > 0)then begin
         chlImagens.ItemIndex := chlImagens.ItemIndex - 1;
         loadImageService(txtDir.Text + '\' + chlImagens.Items[chlImagens.ItemIndex]);
     end;
end;

procedure TfrmPrincipal.btnAvanteClick(Sender: TObject);
var
    tamanho: Integer;
    nomeArquivo: string;
    nomeImagem: string;
    existe: Boolean;

begin
     existe := False;
     tamanho := Length(listaPoligonos);
     if(tamanho > 0) then begin
         nomeArquivo := '';
         nomeImagem := txtDir.Text + '\' + chlImagens.Items[chlImagens.ItemIndex];

         nomeArquivo := StringReplace(nomeImagem, '.jpg', '.txt', [rfReplaceAll, rfIgnoreCase]);
         nomeArquivo := StringReplace(nomeArquivo, '.png', '.txt', [rfReplaceAll, rfIgnoreCase]);
         existe := FileExists(nomeArquivo);

         if(existe = False) then begin
             nomeArquivo := StringReplace(nomeImagem, '.jpg', '.xml', [rfReplaceAll, rfIgnoreCase]);
             nomeArquivo := StringReplace(nomeArquivo, '.png', '.xml', [rfReplaceAll, rfIgnoreCase]);
             existe := FileExists(nomeArquivo);
         end;
         if(existe = False) then begin
             savePoints;
         end;
     end;
      if(chlImagens.ItemIndex < (chlImagens.Items.Count - 1))then begin
          chlImagens.ItemIndex := chlImagens.ItemIndex + 1;
          loadImageService(txtDir.Text + '\' + chlImagens.Items[chlImagens.ItemIndex]);
      end;
end;

procedure TfrmPrincipal.btnClearLastPointClick(Sender: TObject);
var
    tamanho: Integer;

begin
  if(rdbPoligon.Checked = True) then begin
      tamanho := Length(objPoligono);
      SetLength(objPoligono, tamanho - 1);

      tamanho := Length(objPoligonoReal);
      SetLength(objPoligonoReal, tamanho - 1);

      showImage.Refresh;
      DrawPolygon(showImage);
  end;
  if(rdbSquare.Checked = True) then begin
      //drawSquare();
  end;
end;

procedure TfrmPrincipal.btnCropAllInListClick(Sender: TObject);
var
   contador: Integer;

begin
     for contador := 0 to (chlImagens.Items.Count - 1) do begin
         chlImagens.ItemIndex := contador;
         loadImageService(txtDir.Text + '\' + chlImagens.Items[chlImagens.ItemIndex]);
         delay(300);
         saveAllCrops;
     end;
     showCustomMessage('Completed!!!', 2);
end;

procedure TfrmPrincipal.btnCropClick(Sender: TObject);
begin
    saveAllCrops;
    showCustomMessage('Completed!!!', 2);
end;

procedure TfrmPrincipal.btnDelClick(Sender: TObject);
var
   caminho: UnicodeString;
   del: Boolean;
   ret: LongInt;

begin
     if(chlImagens.ItemIndex < 0) then begin
         showCustomMessage('Attention. ' + #10 + #13 + 'Select a file from the list below..', 2);
         Exit;
     end;
     ret := showCustomMessage('Attention. ' + #10 + #13 + 'Do you confirm that it is to delete the file ' + chlImagens.Items[chlImagens.ItemIndex] + '?', 1);
     if(ret = 6) then begin
         caminho := txtDir.Text + '\' + chlImagens.Items[chlImagens.ItemIndex];
         showImage.Picture.Clear;
         chlImagens.Items.Delete(chlImagens.ItemIndex);
         chlImagens.Refresh;
         del :=  SysUtils.DeleteFile(caminho);
         if(del = True) then begin
             showCustomMessage('File Deleted.', 2);
         end;
         if(chlImagens.Count > 0) then begin
             chlImagens.ItemIndex := chlImagens.ItemIndex + 1;
             loadImageService(txtDir.Text + '\' + chlImagens.Items[chlImagens.ItemIndex]);
         end;
     end;
end;

procedure TfrmPrincipal.btnHelpClick(Sender: TObject);
begin
     quadroHelp := TfrmSobre.Create(Self);
     quadroHelp.ShowModal;
end;

procedure TfrmPrincipal.btnLimparClick(Sender: TObject);
begin
    clearPoints;
end;

procedure TfrmPrincipal.chlImagensClick(Sender: TObject);
begin
     loadImageService(txtDir.Text + '\' + chlImagens.Items[chlImagens.ItemIndex]);
end;

procedure TfrmPrincipal.FormCreate(Sender: TObject);
begin

end;

procedure TfrmPrincipal.FormShow(Sender: TObject);
begin
     StatusBar1.Panels.Items[8].Text := '  Version: 0.1.1';
     self.WindowState := wsMaximized;
end;

procedure TfrmPrincipal.btnOpenDirClick(Sender: TObject);
Const FileFound = 0;
      CharCR = Chr(13);
      CharLF = Chr(10); //Windows ?30?
      StringCRLF = CharCR + CharLF;
      WildcardSearch = '\*';

var
  SearchResult : TSearchRec;
  nomePartes: TStringList;
  extensao: String;

begin
     chlImagens.Items.Clear;
     showImage.Picture.Clear;
     clearPoints;
     SelectDirectoryDialog1.Execute;

     nomePartes := splitString(SelectDirectoryDialog1.FileName, '\');
     txtDir.Text := SelectDirectoryDialog1.FileName;

     If FindFirst (SelectDirectoryDialog1.FileName + WildcardSearch, (faAnyFile And Not faDirectory) , SearchResult) = FileFound Then Begin
        nomePartes := splitString(SearchResult.Name, '.');
        extensao := LowerCase(nomePartes[nomePartes.Count - 1]);
        if((extensao = 'jpg') or (extensao = 'png') or (extensao = 'pgm')) then begin
            chlImagens.Items.Add(SearchResult.Name);
        End;
        While FindNext (SearchResult) = FileFound Do Begin
              nomePartes := splitString(SearchResult.Name, '.');
              extensao := LowerCase(nomePartes[nomePartes.Count - 1]);
              if((extensao = 'jpg') or (extensao = 'png') or (extensao = 'pgm')) then begin
                    chlImagens.Items.Add(SearchResult.Name);
              End;
        End;
     End;
     if(chlImagens.Items.Count > 0)then begin
         chlImagens.ItemIndex := 0;
         StatusBar1.Panels.Items[5].Text := ' Images in directory = ' + IntToStr(chlImagens.Items.Count);
         loadImageService(txtDir.Text + '\' + chlImagens.Items[0]);
     end;
end;

procedure TfrmPrincipal.btnSalvarClick(Sender: TObject);
begin
  savePoints;
end;

{%endregion}

end.

