unit uIGenericDao;

interface

uses
  uTarefa, Data.Win.ADODB;

type
  IGenericDao = interface
   ['{4801F93E-295D-4FFC-B223-98E1BEC56BD3}']
     procedure alterar(tarefa: TTarefa);
     procedure excluir(idTarefa: Integer);
     procedure inserir(tarefa: TTarefa);
     function buscar(descricao: string): TADOquery; overload;
     function buscar(idTarefa: integer): TADOquery; overload;
     function buscar: TADOquery; overload;
  end;
implementation

end.
