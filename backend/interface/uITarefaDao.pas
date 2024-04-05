unit uITarefaDao;

interface

uses
  uStatusTarefaEnum, uIGenericDao;

type
  ITarefaDao = interface(IGenericDao)
  ['{F69B65F9-8A4C-4C27-BCDD-F6A9D60E35B8}']
  function retornaNumeroTarefas: integer;
  function retornaNumeroTarefasConcluidas(): integer;
  function retornaMediaPrioridadeTarefas: real;
  end;
implementation

end.
