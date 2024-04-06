object FPrincipal: TFPrincipal
  Left = 0
  Top = 0
  Caption = 'FPrincipal'
  ClientHeight = 157
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
    Top = 136
    Width = 386
    Height = 21
    Align = alBottom
    Alignment = taCenter
    Caption = 'Label1'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
    ExplicitWidth = 50
  end
  object BitBtn1: TBitBtn
    Left = 8
    Top = 27
    Width = 370
    Height = 56
    Caption = 'Iniciar'
    TabOrder = 0
    OnClick = BitBtn1Click
  end
end
