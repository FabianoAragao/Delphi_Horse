unit uTarefa;

interface

uses
  uStatusTarefaEnum, uPrioridadeTarefaEnum;

type
  TTarefa = class
    private
      FIdTarefa: Integer;
      FDescricao: string;
      FStatus: TStatusTarefa;
      FData: TDateTime;
      FPrioridade: TPrioridadetarefa;
    public
      property IdTarefa: Integer read FIdTarefa write FIdTarefa;
      property Descricao: string read FDescricao write FDescricao;
      property Status: TStatusTarefa read FStatus write FStatus;
      property Data: TDateTime read FData write FData;
      property Prioridade: TPrioridadetarefa read FPrioridade write FPrioridade;
  end;

implementation

end.
