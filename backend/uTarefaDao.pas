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
begin
  sql := 'UPDATE ' + NOMETABELA +
         'SET descricao = ' + QuotedStr(tarefa.Descricao) + ', '+
         'status = ' + inttostr(Ord(tarefa.Status)) + ', ' +
         'data = GETDATE(), ' +
         'prioridade = ' + inttostr(Ord(tarefa.Prioridade)) +
         'WHERE id_tarefa = ' + inttostr(tarefa.IdTarefa);
  self.executarQuery(sql);
end;

function TTarefaDao.buscar(idTarefa: integer): TADOquery;
var
  sql: string;
begin
  sql :=  'SELECT id_tarefa, descricao, status, data, prioridade FROM ' + NOMETABELA +
          'WHERE id_tarefa = ' + IntToStr(idTarefa);
  result := self.retornarQuery(sql);
end;

function TTarefaDao.buscar(descricao: string): TADOquery;
var
  sql: string;
begin
  sql :=  'SELECT id_tarefa, descricao, status, data, prioridade FROM ' + NOMETABELA +
          'WHERE descricao LIKE ' + QuotedStr(descricao);
  result := self.retornarQuery(sql);
end;

function TTarefaDao.buscar: TADOquery;
var
  sql: string;
begin
  sql :=  'SELECT id_tarefa, descricao, status, data, prioridade FROM ' + NOMETABELA;
  result := self.retornarQuery(sql);
end;

procedure TTarefaDao.excluir(idTarefa: Integer);
var
  sql: string;
begin
  sql := 'DELETE FROM ' + NOMETABELA + ' WHERE id_tarefa = ' + IntToStr(idTarefa);

  self.executarQuery(sql);
end;

procedure TTarefaDao.inserir(tarefa: TTarefa);
var
  sql: string;
begin
  sql := 'INSERT INTO ' + NOMETABELA + ' (descricao, status, data, prioridade) ' +
          'VALUES (' + QuotedStr(tarefa.Descricao) + ', ' + inttostr(Ord(tarefa.Status)) + ', GETDATE(), ' + inttostr(Ord(tarefa.Prioridade)) + ')';

  self.executarQuery(sql);
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
const
  NOME_PROC = 'GetQuantidadeTarefasConcluidas';
begin
  stProc :=  ExecutarStoredProcedure(NOME_PROC);

  stProc.Parameters.Clear;
  stProc.Parameters.CreateParameter('@DataInicial', ftDateTime, pdInput, 0, StartOfTheDay(IncDay(now, -7)));
  stProc.Parameters.CreateParameter('@DataFinal', ftDateTime, pdInput, 0, EndOfTheDay(now));
  stProc.Parameters.CreateParameter('@Status', ftInteger, pdInput, 0, 3);
  stProc.Parameters.CreateParameter('@QuantidadeTarefasConcluidas', ftInteger, pdOutput, 0, 0);


{  stProc.Parameters.CreateParameter('@DataInicial', ftDateTime, pdInput, 0, StartOfTheDay(IncDay(now, -7)));
  stProc.Parameters.CreateParameter('@DataFinal', ftDateTime, pdInput, 0, EndOfTheDay(now));
  stProc.Parameters.CreateParameter('@Status', ftInteger, pdInput, 0, Ord(TStatusTarefa.CONCLUIDA));
  stProc.Parameters.CreateParameter('@QuantidadeTarefasConcluidas', ftInteger, pdOutput, 0, 0);}

  stProc.ExecProc;

  result := stProc.Parameters.ParamByName('@QuantidadeTarefasConcluidas').value
end;

end.
