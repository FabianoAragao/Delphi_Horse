unit uDataBaseSqlServerADOConnection;

interface

uses
  uIDatabaseConnection, Data.Win.ADODB;
type
  TDataBaseSqlServerADOConnection = class(TInterfacedObject, IDatabaseConnection)
  private
    _conexao: TADOConnection;
    function GetConexao: TADOConnection;
  public
    property conexao: TADOConnection read GetConexao;
    constructor Create;
    destructor Destroy;
  end;

implementation

constructor TDataBaseSqlServerADOConnection.Create;
begin
  self._conexao := TADOConnection.Create(nil);
  self._conexao.ConnectionString := 'Provider=MSDASQL.1;Persist Security Info=False;Data Source=odbc_MSSQL';
  self._conexao.LoginPrompt := false;
  self._conexao.Close;
end;

destructor TDataBaseSqlServerADOConnection.Destroy;
begin
  self.conexao.Close;
  self.conexao.Free;
end;

function TDataBaseSqlServerADOConnection.GetConexao: TADOConnection;
begin
  if (not _conexao.Connected) then
    begin
      _conexao.Open;
    end;

  Result := _conexao;
end;

end.

