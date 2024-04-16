program gerenciador_tarefa;

uses
  Vcl.Forms,
  uPrincipal in 'uPrincipal.pas' {FPrincipal},
  uPrioridadeTarefaEnum in 'enum\uPrioridadeTarefaEnum.pas',
  uStatusTarefaEnum in 'enum\uStatusTarefaEnum.pas',
  uTarefaDao in 'uTarefaDao.pas',
  uTarefa in 'model\uTarefa.pas',
  uIDatabaseConnection in 'interface\uIDatabaseConnection.pas',
  uIGenericDao in 'interface\uIGenericDao.pas',
  uDatabaseFactory in 'factorys\uDatabaseFactory.pas',
  uDataBaseSqlServerADOConnection in 'uDataBaseSqlServerADOConnection.pas',
  uDatabasseSqlServerADOGeneric in 'uDatabasseSqlServerADOGeneric.pas',
  uITarefaDao in 'interface\uITarefaDao.pas',
  uJWTManager in 'utils\uJWTManager.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFPrincipal, FPrincipal);
  Application.Run;
end.
