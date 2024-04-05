unit uDatabasseSqlServerADOGeneric;

interface

uses
  Data.Win.ADODB, uTarefa, Data.DB, System.Variants,
  uStatusTarefaEnum, uITarefaDao, uIGenericDao;

type
  TDatabasseSqlServerADOGeneric = class abstract(TInterfacedObject, IGenericDao)
    private
      _conexao: TADOConnection;
    protected
      property conexao: TADOConnection read _conexao;

      procedure executarQuery(sql: string);
      function retornarQuery(sql: string): TADOquery;
      function ExecutarStoredProcedure(const nomeSP: string):TADOStoredProc;
    public
      procedure alterar(tarefa: TTarefa); virtual;
      procedure excluir(idTarefa: Integer); virtual;
      procedure inserir(tarefa: TTarefa); virtual;
      function buscar(descricao: string): TADOquery; overload; virtual;
      function buscar(idTarefa: integer): TADOquery; overload; virtual;
      function buscar: TADOquery; overload; virtual;
      constructor Create(const pConexao: TADOConnection);
  end;

implementation

uses
  System.SysUtils,  System.DateUtils;

constructor TDatabasseSqlServerADOGeneric.Create(const pConexao: TADOConnection);
begin
  _conexao := pConexao;
end;

procedure TDatabasseSqlServerADOGeneric.executarQuery(sql: string);
var
  query: TADOQuery;
begin
  query := TADOQuery.Create(nil);
  query.Connection := self.conexao;
  query.Close;
  query.SQL.Clear;
  query.SQL.add(sql);
  query.ExecSQL;
end;

function TDatabasseSqlServerADOGeneric.retornarQuery(sql: string): TADOquery;
var
  query: TADOQuery;
begin
  query := TADOQuery.Create(nil);
  query.Connection := self.conexao;
  query.Close;
  query.SQL.Clear;
  query.SQL.add(sql);

  result := query;
end;

function TDatabasseSqlServerADOGeneric.ExecutarStoredProcedure(const nomeSP: string):TADOStoredProc;
var
  query: TADOStoredProc;
begin
  query := TADOStoredProc.Create(nil);

  query.Connection := self.conexao;
  query.ProcedureName := nomeSP;

  result := query;;
end;

procedure TDatabasseSqlServerADOGeneric.inserir(tarefa: TTarefa);
begin
  //metodo virtual apenas para implementar interface, será sobrescrito nos filhos
end;

function TDatabasseSqlServerADOGeneric.buscar(idTarefa: integer): TADOquery;
begin
  //metodo virtual apenas para implementar interface, será sobrescrito nos filhos
end;

function TDatabasseSqlServerADOGeneric.buscar(descricao: string): TADOquery;
begin
  //metodo virtual apenas para implementar interface, será sobrescrito nos filhos
end;

procedure TDatabasseSqlServerADOGeneric.alterar(tarefa: TTarefa);
begin
  //metodo virtual apenas para implementar interface, será sobrescrito nos filhos
end;

function TDatabasseSqlServerADOGeneric.buscar: TADOquery;
begin
  //metodo virtual apenas para implementar interface, será sobrescrito nos filhos
end;

procedure TDatabasseSqlServerADOGeneric.excluir(idTarefa: Integer);
begin
  //metodo virtual apenas para implementar interface, será sobrescrito nos filhos
end;

end.
