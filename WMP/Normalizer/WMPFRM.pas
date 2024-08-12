unit
  WMPFRM;

interface

uses
  WMPDCL,
  Forms,
  Controls,
  ComCtrls,
  StdCtrls;

type
  PWMPFRM = ^TWMPFRM;
  TWMPFRM = record
  private
    function getForm(): TForm;
    procedure setAmp(const Value: Double);
    procedure Create();
    procedure Destroy();
  public
    procedure Init();
    procedure Done();
    procedure Show();
    procedure Hide();
    property Amp: Double write setAmp;
  end;

implementation

uses
  Math,
  SysUtils,
  Interfaces;

procedure TWMPFRM.Init();
begin
  Application.Initialize();
  self.Create();
end;

procedure TWMPFRM.Done();
begin
  self.Destroy();
  Application.Terminate();
end;

procedure TWMPFRM.Show();
begin
  self.getForm().Show();
end;

procedure TWMPFRM.Hide();
begin
  self.getForm().Hide();
end;

function TWMPFRM.getForm(): TForm;
var
  i: Integer;
begin
  for i := 0 to Application.ComponentCount - 1 do begin
    if (Application.Components[i] is TForm) then begin
      Result := (Application.Components[i] as TForm);
    end;
  end;
end;

procedure TWMPFRM.Create();
begin
  with (TForm.Create(Application)) do begin
    Font.Size := 8;
    Caption := 'Normalizer';
    Top := 120;
    Left := 215;
    Width := 450;
    Height := 45;
    BorderIcons := [biSystemMenu];
    BorderStyle := bsSingle;
    Position := poMainFormCenter;
    ShowHint := True;
    Parent := nil;
  end;
  with (TTrackBar.Create(Application)) do begin
    Font.Size := 8;
    Orientation := trHorizontal;
    Tag := 0;
    Top := 0;
    Left := 0;
    Width := 450;
    Height := 20;
    Min := 0;
    Position := 0;
    Max := 200;
    Enabled := False;
    ShowHint := True;
    TickMarks := tmBoth;
    TickStyle := tsNone;
    Parent := self.getForm();
  end;
  with (TStaticText.Create(Application)) do begin
    Font.Size := 8;
    Caption := '0 dB';
    Top := 25;
    Left := 0;
    Width := 45;
    Height := 20;
    ShowHint := True;
    Parent := self.getForm();
  end;
  with (TStaticText.Create(Application)) do begin
    Font.Size := 8;
    Caption := '5 dB';
    Top := 25;
    Left := 110;
    Width := 45;
    Height := 20;
    ShowHint := True;
    Parent := self.getForm();
  end;
  with (TStaticText.Create(Application)) do begin
    Font.Size := 8;
    Caption := '10 dB';
    Top := 25;
    Left := 215;
    Width := 45;
    Height := 20;
    ShowHint := True;
    Parent := self.getForm();
  end;
  with (TStaticText.Create(Application)) do begin
    Font.Size := 8;
    Caption := '15 dB';
    Top := 25;
    Left := 320;
    Width := 45;
    Height := 20;
    ShowHint := True;
    Parent := self.getForm();
  end;
  with (TStaticText.Create(Application)) do begin
    Font.Size := 8;
    Caption := '20 dB';
    Top := 25;
    Left := 420;
    Width := 45;
    Height := 20;
    ShowHint := True;
    Parent := self.getForm();
  end;
end;

procedure TWMPFRM.Destroy();
begin
  self.getForm().Close();
  self.getForm().Destroy();
end;

procedure TWMPFRM.setAmp(const Value: Double);
var
  s: TTrackBar;
  i: Integer;
begin
  for i := 0 to self.getForm().ControlCount - 1 do begin
    if (self.getForm().Controls[i] is TTrackBar) then begin
      with(self.getForm().Controls[i] as TTrackBar) do begin
        Position := Round(20 * Log10(Value) * 10);
      end;
    end;
  end;
end;

begin
end.
