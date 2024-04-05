unit uDatabaseFactory;

interface

uses
  uIDatabaseConnection, uITarefaDao, uTarefaDao;
type
  TDatabaseFactory = class
  public
    class function CreateInteraction: TTarefaDao;
  end;

implementation

uses
  uDataBaseSqlServerADOConnection, uDatabasseSqlServerADOGeneric;

{ TDatabaseFactory }

class function TDatabaseFactory.CreateInteraction: TTarefaDao;
var
  Connection: TDataBaseSqlServerADOConnection;
begin
  Connection := TDataBaseSqlServerADOConnection.Create;
  try
    Result := TTarefaDao.Create(Connection.conexao);
  finally
    Connection.Free;
  end;
end;

end.
