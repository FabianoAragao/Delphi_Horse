unit uJWTManager;

interface

uses
  System.SysUtils, System.DateUtils, IdGlobal, IdHashSHA, IdHMAC, IdHMACSHA1, IdSSLOpenSSL,
  IdCoderMIME, System.Classes, System.Hash, System.NetEncoding;

type
  TJWTManager = class
  private
    class function GenerateHMACSHA256(const Data, Key: string): string;
  public
    class function GenerateToken(idUsuario: Integer): string;
    class function ValidateToken(token: string): Boolean;
  end;

implementation

{ TJWTManager }

class function TJWTManager.GenerateHMACSHA256(const Data, Key: string): string;
var
  HashBytes: TBytes;
  KeyBytes: TBytes;
  DataBytes: TBytes;
begin
  // Converte a chave e os dados para bytes UTF-8
  KeyBytes := TEncoding.UTF8.GetBytes(Key);
  DataBytes := TEncoding.UTF8.GetBytes(Data);

  // Calcula o HMAC-SHA256
  HashBytes := THashSHA2.GetHMACAsBytes(DataBytes, KeyBytes, THashSHA2.TSHA2Version.SHA256);

  // Codifica o resultado em base64
  Result := TNetEncoding.Base64.EncodeBytesToString(HashBytes);
end;

class function TJWTManager.GenerateToken(idUsuario: Integer): string;
var
  Payload: TStringBuilder;
begin
  Payload := TStringBuilder.Create;
  try
    Payload.Append('{"id":' + IntToStr(idUsuario) + ',"exp":' + IntToStr(DateTimeToUnix(Now + EncodeTime(0, 30, 0, 0))) + '}');
    Result := Payload.ToString + '.' + GenerateHMACSHA256(Payload.ToString, 'chaveSecreta');
  finally
    Payload.Free;
  end;
end;

class function TJWTManager.ValidateToken(token: string): Boolean;
var
  Parts: TArray<string>;
  Payload: string;
  Signature: string;
begin
  if Token.IsEmpty then
    begin
      raise Exception.Create('Token não fornecido');
    end;

  Result := False;

  // Divide o token em partes (payload e assinatura)
  Parts := token.Split(['.']);
  if Length(Parts) <> 2 then
    begin
      raise Exception.Create('Token inválido');
    end;

  Payload := Parts[0];
  Signature := Parts[1];
  // Valida a assinatura
  Result := Signature = GenerateHMACSHA256(Payload, 'suaChaveSecreta');
end;

end.

