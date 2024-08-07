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
    var finfo: TInfo;
    var fform: TForm;
    procedure CreateForm(const Top, Left, Width, Height: Integer; const Caption: String);
    procedure CreateTrackBar(const Top, Left, Width, Height: Integer; const Tag: Integer);
    procedure CreateStaticText(const Top, Left, Width, Height: Integer; const Caption: String);
    procedure Create();
    procedure Destroy();
  public
    procedure Init();
    procedure Done();
    procedure Show();
    procedure Hide();
    procedure Update(const Value: Double);
  end;

implementation

uses
  Math,
  StrUtils,
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
  self.fform.Show();
end;

procedure TWMPFRM.Hide();
begin
  self.fform.Hide();
end;

procedure TWMPFRM.Create();
begin
  self.CreateForm(120, 215, 450, 45, 'Normalizer');
  self.CreateTrackBar(0, 0, 450, 20, 0);
  self.CreateStaticText(25, 0, 45, 20, '0 dB');
  self.CreateStaticText(25, 110, 45, 20, '5 dB');
  self.CreateStaticText(25, 215, 45, 20, '10 dB');
  self.CreateStaticText(25, 320, 45, 20, '15 dB');
  self.CreateStaticText(25, 420, 45, 20, '20 dB');
end;

procedure TWMPFRM.Destroy();
begin
  self.fform.Close();
  self.fform.Destroy();
end;

procedure TWMPFRM.CreateForm(const Top, Left, Width, Height: Integer; const Caption: String);
var
  Result: TForm;
begin
  Result := TForm.Create(nil);
  Result.Font.Size := 8;
  Result.Caption := Caption;
  Result.Top := Top;
  Result.Left := Left;
  Result.Width := Width;
  Result.Height := Height;
  Result.BorderIcons := [biSystemMenu];
  Result.BorderStyle := bsSingle;
  Result.Position := poMainFormCenter;
  Result.ShowHint := True;
  self.fform := Result;
end;

procedure TWMPFRM.CreateTrackBar(const Top, Left, Width, Height: Integer; const Tag: Integer);
var
  Result: TTrackBar;
begin
  Result := TTrackBar.Create(nil);
  Result.Font.Size := 8;
  Result.Orientation := trHorizontal;
  Result.Tag := Tag;
  Result.Top := Top;
  Result.Left := Left;
  Result.Width := Width;
  Result.Height := Height;
  Result.Min := 0;
  Result.Position := 0;
  Result.Max := 200;
  Result.Enabled := False;
  Result.ShowHint := True;
  Result.TickMarks := tmBoth;
  Result.TickStyle := tsNone;
  Result.Parent := self.fform;
end;

procedure TWMPFRM.CreateStaticText(const Top, Left, Width, Height: Integer; const Caption: String);
var
  Result: TStaticText;
begin
  Result := TStaticText.Create(nil);
  Result.Font.Size := 8;
  Result.Caption := Caption;
  Result.Top := Top;
  Result.Left := Left;
  Result.Width := Width;
  Result.Height := Height;
  Result.ShowHint := True;
  Result.Parent := self.fform;
end;

procedure TWMPFRM.Update(const Value: Double);
var
  i: Integer;
begin
  for i := 0 to self.fform.ControlCount - 1 do begin
    if (self.fform.Controls[i] is TTrackBar) then begin
      with (self.fform.Controls[i] as TTrackBar) do begin
        Position := Round(Value * 10);
      end;
    end;
  end;
end;

begin
end.
