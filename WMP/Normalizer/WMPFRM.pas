unit
  WMPFRM;

interface

uses
  WMPDCL,
  Forms,
  Controls,
  ComCtrls,
  StdCtrls,
  SysUtils;

type
  PWMPFRM = ^TWMPFRM;
  TWMPFRM = record
  private
    var finfo: TInfo;
    var fform: TForm;
    function CreateForm(const Top, Left, Width, Height: Integer; const Caption: String): TForm;
    function CreateTrackBar(const Top, Left, Width, Height: Integer; const Tag: Integer): TTrackBar;
    function CreateStaticText(const Top, Left, Width, Height: Integer; const Caption: String): TStaticText;
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
  Interfaces;

procedure TWMPFRM.Init();
begin
  self.Create();
end;

procedure TWMPFRM.Done();
begin
  self.Destroy();
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
var
  i: Integer;
begin
  Application.Initialize();
  self.fform := self.CreateForm(120, 215, 450, 45, 'Normalizer');
  self.fform.InsertControl(self.CreateTrackBar(0, 0, 450, 20, 0));
  self.fform.InsertControl(self.CreateStaticText(25, 0, 45, 20, '0 dB'));
  self.fform.InsertControl(self.CreateStaticText(25, 110, 45, 20, '5 dB'));
  self.fform.InsertControl(self.CreateStaticText(25, 215, 45, 20, '10 dB'));
  self.fform.InsertControl(self.CreateStaticText(25, 320, 45, 20, '15 dB'));
  self.fform.InsertControl(self.CreateStaticText(25, 420, 45, 20, '20 dB'));
end;

procedure TWMPFRM.Destroy();
var
  i: Integer;
begin
  self.fform.Hide();
  for i := 0 to self.fform.ControlCount - 1 do begin
    self.fform.Controls[i].Destroy();
  end;
  self.fform.Destroy();
  Application.Terminate();
end;

function TWMPFRM.CreateForm(const Top, Left, Width, Height: Integer; const Caption: String): TForm;
begin
  Result := TForm.Create(Application);
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
end;

function TWMPFRM.CreateTrackBar(const Top, Left, Width, Height: Integer; const Tag: Integer): TTrackBar;
begin
  Result := TTrackBar.Create(Application);
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
end;

function TWMPFRM.CreateStaticText(const Top, Left, Width, Height: Integer; const Caption: String): TStaticText;
begin
  Result := TStaticText.Create(Application);
  Result.Font.Size := 8;
  Result.Caption := Caption;
  Result.Top := Top;
  Result.Left := Left;
  Result.Width := Width;
  Result.Height := Height;
  Result.ShowHint := True;
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
