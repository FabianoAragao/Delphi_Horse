object FPrincipal: TFPrincipal
  Left = 0
  Top = 0
  Caption = 'Servidor - Teste delphi + horse '
  ClientHeight = 88
  ClientWidth = 386
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnClose = FormClose
  OnCreate = FormCreate
  TextHeight = 15
  object Label1: TLabel
    Left = 0
    Top = 67
    Width = 386
    Height = 21
    Align = alBottom
    Alignment = taCenter
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
    ExplicitTop = 136
    ExplicitWidth = 4
  end
  object BitBtn1: TBitBtn
    Left = 8
    Top = 8
    Width = 370
    Height = 56
    Caption = 'Iniciar'
    TabOrder = 0
    OnClick = BitBtn1Click
  end
end
