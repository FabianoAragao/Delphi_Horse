unit uTarefaDao;

interface

uses
  Data.Win.ADODB, uTarefa, Data.DB, System.Variants,
  uStatusTarefaEnum, uDatabasseSqlServerADOGeneric, uITarefaDao;

type
  TTarefaDao = class(TDatabasseSqlServerADOGeneric, ITarefaDao)
    private
      const NOMETABELA = ' gerenciador_tarefas.dbo.tarefas ';
    public
      procedure alterar(tarefa: TTarefa);override;
      procedure excluir(idTarefa: Integer);override;
      procedure inserir(tarefa: TTarefa);override;
      function buscar(descricao: string): TADOquery; overload;override;
      function buscar(idTarefa: integer): TADOquery; overload;override;
      function buscar: TADOquery; overload;override;
      function retornaNumeroTarefas: integer;
      function retornaNumeroTarefasConcluidas(): integer;
      function retornaMediaPrioridadeTarefas: real;
  end;

implementation

uses
  System.SysUtils,  System.DateUtils, System.math;

procedure TTarefaDao.alterar(tarefa: TTarefa);
var
  sql: string;
  query: TADOQuery;
begin
  sql := 'UPDATE ' + NOMETABELA +
         ' SET descricao = :Descricao, '+
         ' status = :Status, ' +
         ' data = GETDATE(), ' +
         ' prioridade = :Prioridade ' +
         ' WHERE id_tarefa = :IdTarefa';

  query := self.retornarQuery(sql);
  try
    // Definindo os parâmetros e seus tipos
    query.Parameters.ParamByName('Descricao').DataType := ftString;
    query.Parameters.ParamByName('Descricao').Value := tarefa.Descricao;

    query.Parameters.ParamByName('Status').DataType := ftInteger;
    query.Parameters.ParamByName('Status').Value := Ord(tarefa.Status);

    query.Parameters.ParamByName('Prioridade').DataType := ftInteger;
    query.Parameters.ParamByName('Prioridade').Value := Ord(tarefa.Prioridade);

    query.Parameters.ParamByName('IdTarefa').DataType := ftInteger;
    query.Parameters.ParamByName('IdTarefa').Value := tarefa.IdTarefa;

    query.ExecSQL;
  finally
    query.Free;
  end;
end;

function TTarefaDao.buscar(idTarefa: integer): TADOquery;
var
  sql: string;
begin
  Result := nil;
  sql := 'SELECT id_tarefa, descricao, status, data, prioridade FROM ' + NOMETABELA +
         ' WHERE id_tarefa = :IdTarefa';

  Result := Self.retornarQuery(sql);
  try
    Result.Parameters.ParamByName('IdTarefa').DataType := ftInteger;
    Result.Parameters.ParamByName('IdTarefa').Value := idTarefa;
  except
    if(Result <> nil)then
      FreeAndNil(Result);
  end;
end;

function TTarefaDao.buscar(descricao: string): TADOquery;
var
  sql: string;
  query: TADOQuery;
begin
  query := nil;

  sql := 'SELECT id_tarefa, descricao, status, data, prioridade FROM ' + NOMETABELA +
         ' WHERE descricao LIKE :Descricao';

  query := Self.retornarQuery(sql);
  try
    query.Parameters.ParamByName('Descricao').DataType := ftString;
    query.Parameters.ParamByName('Descricao').Value := descricao;
    query.Open;
    Result := query;
  except
    if(query <> nil)then
      FreeAndNil(query);
  end;
end;

function TTarefaDao.buscar: TADOquery;
var
  sql: string;
  query: TADOQuery;
begin
  query := nil;

  sql := 'SELECT id_tarefa, descricao, status, data, prioridade FROM ' + NOMETABELA;

  query := Self.retornarQuery(sql);
  try
    query.Open;
    Result := query;
  except
    if(query <> nil)then
      FreeAndNil(query);
  end;
end;

procedure TTarefaDao.excluir(idTarefa: Integer);
var
  sql: string;
  query: TADOQuery;
begin
  query := nil;

  sql := 'DELETE FROM ' + NOMETABELA + ' WHERE id_tarefa = :ID_TAREFA';

  query := Self.retornarQuery(sql);
  try
    query.Parameters.ParamByName('ID_TAREFA').DataType := ftInteger;
    query.Parameters.ParamByName('ID_TAREFA').Value := idTarefa;
    query.ExecSQL;
  finally
    if(query <> nil)then
      FreeAndNil(query);
  end;
end;

procedure TTarefaDao.inserir(tarefa: TTarefa);
var
  sql: string;
  query: TADOQuery;
begin
  query := nil;

  sql := 'INSERT INTO ' + NOMETABELA + ' (descricao, status, data, prioridade) ' +
         'VALUES (:DESCRICAO, :STATUS, GETDATE(), :PRIORIDADE)';

  query := Self.retornarQuery(sql);
  try
    query.Parameters.ParamByName('DESCRICAO').DataType := ftString;
    query.Parameters.ParamByName('DESCRICAO').Value := tarefa.Descricao;

    query.Parameters.ParamByName('STATUS').DataType := ftInteger;
    query.Parameters.ParamByName('STATUS').Value := Ord(tarefa.Status);

    query.Parameters.ParamByName('PRIORIDADE').DataType := ftInteger;
    query.Parameters.ParamByName('PRIORIDADE').Value := Ord(tarefa.Prioridade);
    query.ExecSQL;
  finally
    if(query <> nil)then
      FreeAndNil(query);
  end;
end;

function TTarefaDao.retornaMediaPrioridadeTarefas: real;
var
  stProc: TADOStoredProc;
const
  NOME_PROC = 'GetMediaPrioridadeTarefas';
begin
  stProc :=  ExecutarStoredProcedure(NOME_PROC);
  stProc.Parameters.Clear;
  stProc.Parameters.CreateParameter('@MediaPrioridade', ftFloat, pdOutput, 0, 0);
  stProc.ExecProc;

  result := RoundTo(stProc.Parameters.ParamByName('@MediaPrioridade').value, -2);
end;


function TTarefaDao.retornaNumeroTarefas(): integer;
var
  stProc: TADOStoredProc;
const
  NOME_PROC = 'GetTotalTarefas';
begin
  stProc :=  ExecutarStoredProcedure(NOME_PROC);
  stProc.Parameters.Clear;
  stProc.Parameters.CreateParameter('@TotalTarefas', ftInteger, pdOutput, 0, 0);
  stProc.ExecProc;

  result := stProc.Parameters.ParamByName('@TotalTarefas').value;
end;


function TTarefaDao.retornaNumeroTarefasConcluidas(): integer;
var
  stProc: TADOStoredProc;
  dataInicial, dataFinal: string;
const
  NOME_PROC = 'GetQuantidadeTarefasConcluidas';
begin
  dataInicial := FormatDateTime('yyyy-MM-dd', IncDay(now, -7)) + ' 00:00:00';
  dataFinal := FormatDateTime('yyyy-MM-dd', now) + ' 23:59:59';

  stProc :=  ExecutarStoredProcedure(NOME_PROC);
  stProc.Parameters.Clear;
  stProc.Parameters.CreateParameter('@DataInicial', ftDateTime, pdInput, 0, dataInicial);
  stProc.Parameters.CreateParameter('@DataFinal', ftDateTime, pdInput, 0, dataFinal);
  stProc.Parameters.CreateParameter('@Status', ftInteger, pdInput, 0, Ord(TStatusTarefa.CONCLUIDA));
  stProc.Parameters.CreateParameter('@QuantidadeTarefasConcluidas', ftInteger, pdOutput, 0, 0);


{  stProc.Parameters.CreateParameter('@DataInicial', ftDateTime, pdInput, 0, StartOfTheDay(IncDay(now, -7)));
  stProc.Parameters.CreateParameter('@DataFinal', ftDateTime, pdInput, 0, EndOfTheDay(now));
  stProc.Parameters.CreateParameter('@Status', ftInteger, pdInput, 0, Ord(TStatusTarefa.CONCLUIDA));
  stProc.Parameters.CreateParameter('@QuantidadeTarefasConcluidas', ftInteger, pdOutput, 0, 0);}

  stProc.ExecProc;

  result := stProc.Parameters.ParamByName('@QuantidadeTarefasConcluidas').value
end;

end.
