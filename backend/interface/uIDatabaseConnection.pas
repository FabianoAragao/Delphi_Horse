unit uIDatabaseConnection;

interface

uses
  Data.Win.ADODB;

type
 IDatabaseConnection = interface
  ['{81B774D4-BB1F-4EC3-B80C-BE27B1E64279}']
  function GetConexao: TADOConnection;
 end;

implementation

end.
