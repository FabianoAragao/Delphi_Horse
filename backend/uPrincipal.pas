unit uPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Horse,
  System.JSON, uTarefa, Data.Win.ADODB, uITarefaDao;

type
  TFPrincipal = class(TForm)
    BitBtn1: TBitBtn;
    Label1: TLabel;
    procedure BitBtn1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    tarefaDao: ITarefaDao;

    procedure inserir(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    procedure alterar(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    procedure consultar(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    procedure excluir(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    procedure retornaNumeroTarefasConcluidas(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    procedure retornaNumeroTarefas(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    procedure retornaMediaPrioridadeTarefas(Req: THorseRequest; Res: THorseResponse; Next: TProc);
    function criaObjJson(tarefa: TTarefa): TJSONObject;
    function criaListaJSON(query: TADOQuery): TJSONArray;
    procedure pararServidor;
    procedure iniciarServidor;
  public

  end;

var
  FPrincipal: TFPrincipal;

implementation

uses
  System.Generics.Collections, uDatabaseFactory, uStatusTarefaEnum, TypInfo,
  uPrioridadeTarefaEnum;

{$R *.dfm}

procedure TFPrincipal.BitBtn1Click(Sender: TObject);
begin
  try
    try
      BitBtn1.Enabled := false;
      Label1.Caption := 'Iniciando o servidor...';
      Application.ProcessMessages;

      if(BitBtn1.Caption = 'Iniciar')then
        begin
          iniciarServidor();
          BitBtn1.Caption := 'Parar';
          Label1.Caption :=  'Serviço Iniciado na porta 9000.';
        end
      else
        begin
          pararServidor();
          BitBtn1.Caption := 'Iniciar';
          Label1.Caption := '';
        end;
    except on E: Exception do
      ShowMessage('Erro interno do servidor: ' + E.Message);
    end;
  finally
    BitBtn1.Enabled := true;
  end;
end;


procedure TFPrincipal.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if(BitBtn1.Caption = 'Parar')then
    pararServidor();
end;

procedure TFPrincipal.iniciarServidor();
begin
  try
    if(not assigned(tarefaDao))then
      tarefaDao := TDatabaseFactory.CreateInteraction;

    THorse.Get('/consultar', procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
      begin
        self.consultar(Req, Res, Next);
      end);

    THorse.post('/inserir',
      procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
      begin
        self.inserir(Req, Res, Next);
      end);

    THorse.put('/alterar',
      procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
      begin
        self.alterar(Req, Res, Next);
      end);

    THorse.delete('/excluir',
      procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
      begin
        self.excluir(Req, Res, Next);
      end);

    THorse.Get('/tarefasConcluidas',
      procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
      begin
        self.retornaNumeroTarefasConcluidas(Req, Res, Next);
      end);

    THorse.Get('/numeroTarefas',
      procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
      begin
        self.retornaNumeroTarefas(Req, Res, Next);
      end);

    THorse.Get('/mediaPrioridadeTarefas',
      procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
      begin
        self.retornaMediaPrioridadeTarefas(Req, Res, Next);
      end);

    THorse.Listen(9000);
  except
    on E: Exception do
      ShowMessage('Erro: ' + E.Message);
  end;
end;

procedure TFPrincipal.pararServidor();
begin
  THorse.StopListen;
end;


procedure TFPrincipal.inserir(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  tarefa: TTarefa;
  JSONObj: TJSONObject;
begin
  try
    tarefa := nil;
    JSONObj := nil;

    tarefa := TTarefa.Create();

    // Acessando o corpo da solicitação como uma string JSON
    JSONObj := TJSONObject.ParseJSONValue(Req.Body) as TJSONObject;
    if(JSONObj <> nil)then
      begin
        tarefa.Descricao  := JSONObj.GetValue<string>('descricao');
        tarefa.Status     := TStatusTarefa(JSONObj.GetValue<smallint>('status'));
        tarefa.Data       := JSONObj.GetValue<TDateTime>('data');
        tarefa.Prioridade := TPrioridadetarefa(JSONObj.GetValue<smallint>('prioridade'));


      end
    else
      begin
        Res.Status(400).Send('Corpo da solicitação inválido.');
        Exit;
      end;

    try
      tarefaDao.inserir(tarefa);
    except on E: Exception do
       Res.Status(500).Send('Erro interno do servidor: ' + E.Message);
    end;

    Res.Send('Tarefa inserida com sucesso!').Status(200);
  finally
    if (JSONObj<> nil)then
      FreeAndNil(JSONObj);
    if(tarefa <> nil)then
      FreeAndNil(tarefa);
  end;
end;

procedure TFPrincipal.retornaMediaPrioridadeTarefas(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  retorno: real;
begin
  try
    retorno := tarefaDao.retornaMediaPrioridadeTarefas();

    Res.Send('Media de Prioridade das Tarefas: ' + floatToStr(retorno)).Status(200);
  except on E: Exception do
     Res.Status(500).Send('Erro interno do servidor: ' + E.Message);
  end;
end;

procedure TFPrincipal.retornaNumeroTarefas(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  retorno: real;
begin
  try
    retorno := tarefaDao.retornaNumeroTarefas();

    Res.Send('Media de Prioridade das Tarefas: ' + floatToStr(retorno)).Status(200);
  except on E: Exception do
     Res.Status(500).Send('Erro interno do servidor: ' + E.Message);
  end;
end;


procedure TFPrincipal.retornaNumeroTarefasConcluidas(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  retorno: real;
begin
  try
    retorno := tarefaDao.retornaNumeroTarefasConcluidas();

    Res.Status(400).Send('Status inválido!');

    Res.Send('Media de Prioridade das Tarefas: ' + floatToStr(retorno)).Status(200);
  except on E: Exception do
     Res.Status(500).Send('Erro interno do servidor: ' + E.Message);
  end;
end;


procedure TFPrincipal.alterar(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  tarefa: TTarefa;
  JSONObj: TJSONObject;
begin
  try
    tarefa := nil;
    JSONObj := nil;

    tarefa := TTarefa.Create();

    // Acessando o corpo da solicitação como uma string JSON
    JSONObj := TJSONObject.ParseJSONValue(Req.Body) as TJSONObject;
    if(JSONObj <> nil)then
      begin
        tarefa.IdTarefa   := JSONObj.GetValue<Integer>('id_tarefa');
        tarefa.Descricao  := JSONObj.GetValue<string>('descricao');
        tarefa.Status     := TStatusTarefa(JSONObj.GetValue<smallint>('status'));
        tarefa.Data       := JSONObj.GetValue<TDateTime>('data');
        tarefa.Prioridade := TPrioridadetarefa(JSONObj.GetValue<SmallInt>('prioridade'));
      end
    else
      begin
        Res.Status(400).Send('Corpo da solicitação inválido.');
        Exit;
      end;
    try
      tarefaDao.alterar(tarefa);
    except on E: Exception do
       Res.Status(500).Send('Erro interno do servidor: ' + E.Message);
    end;

    Res.Send('Tarefa atualizada com sucesso!').Status(200);
  finally
    if(JSONObj <> nil)then
      FreeAndNil(JSONObj);
  end;
end;


procedure TFPrincipal.consultar(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  JSONObj: TJSONObject;
  JSONLista: TJSONArray;
  query: TADOQuery;
begin
  JSONObj := nil;
  JSONLista := nil;
  query := nil;

  // Acessando o corpo da solicitação como uma string JSON
  if (length(Req.Body) > 0) then
    JSONObj := TJSONObject.ParseJSONValue(Req.Body) as TJSONObject;
  try
    try
      if ((length(Req.Body) > 0) and (Assigned(JSONObj.Values['idtarefa'])))then
        begin
          query := tarefaDao.buscar(JSONObj.GetValue<Integer>('idtarefa'));
        end
      else if ((length(Req.Body) > 0) and (Assigned(JSONObj.Values['descricao'])))then
        begin
          query := tarefaDao.buscar(JSONObj.GetValue<string>('descricao'));
        end
      else
        begin
          query := tarefaDao.buscar();
        end;

      if(Assigned(query))then
        begin
          try
            JSONLista := criaListaJSON(query);
          except on E: Exception do
            Res.Status(500).Send('Erro interno do servidor: ' + E.Message);
          end;
        end;

      Res.Status(200).Send(JSONLista.ToString);

    except on E: Exception do
       Res.Status(500).Send('Erro interno do servidor: ' + E.Message);
    end;
  finally
    if(JSONObj <> nil)then
      freeAndNil(JSONObj);
    if(JSONLista <> nil)then
      freeAndNil(JSONLista);
    if(query <> nil) then
      freeAndNil(query);
  end;
end;

procedure TFPrincipal.excluir(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  JSONObj: TJSONObject;
begin
  JSONObj := nil;
  try
    try
      JSONObj := TJSONObject.ParseJSONValue(Req.Body) as TJSONObject;
      if(JSONObj <> nil)then
        begin
          tarefaDao.excluir(JSONObj.GetValue<Integer>('idtarefa'));
        end
      else
        begin
          Res.Status(400).Send('Corpo da solicitação inválido.');
          Exit;
        end;
    except on E: Exception do
       Res.Status(500).Send('Erro interno do servidor: ' + E.Message);
    end;

    Res.Send('Tarefa excluida com sucesso!').Status(200);
  finally
    if(JSONObj <> nil)then
      JSONObj.Free;
  end;
end;

procedure TFPrincipal.FormCreate(Sender: TObject);
begin
  Label1.Caption := '';
end;

function TFPrincipal.criaListaJSON(query: TADOQuery): TJSONArray;
var
  tarefa: TTarefa;
  JSONLista: TJSONArray;
begin
  tarefa := nil;
  JSONLista := nil;

  JSONLista := TJSONArray.Create;

  try

    query.close;
    query.open;
    query.First;
    while not query.eof do
      begin
        tarefa := TTarefa.Create;
        try
          tarefa.IdTarefa   := query.FieldByName('id_tarefa').AsInteger;
          tarefa.Descricao  := query.FieldByName('descricao').AsString;
          tarefa.Status     := TStatusTarefa(query.FieldByName('status').AsInteger);
          tarefa.Data       := query.FieldByName('data').AsDateTime;
          tarefa.Prioridade := TPrioridadetarefa(query.FieldByName('prioridade').AsInteger);
          JSONLista.AddElement(self.criaObjJson(tarefa));

         finally
           if(tarefa <> nil)then
             tarefa.Free;
         end;

        query.next;
      end;

    result := JSONLista;
  finally
    if (JSONLista <> nil)then
      FreeAndNil(JSONLista);
    if(tarefa <> nil)then
      FreeAndNil(tarefa);
  end;
end;

function TFPrincipal.criaObjJson(tarefa:TTarefa): TJSONObject;
begin
  result := TJSONObject.Create
          .AddPair('idtarefa', TJSONNumber.Create(tarefa.IdTarefa))
          .AddPair('descricao', tarefa.Descricao)
          .AddPair('status', TJSONNumber.Create(Ord(tarefa.Status)))
          .AddPair('data', FormatDateTime('yyyy-mm-dd', tarefa.Data))
          .AddPair('prioridade', TJSONNumber.Create(Ord(tarefa.Prioridade)));
end;

end.
