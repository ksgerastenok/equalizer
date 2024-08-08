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
    function getInfo(): TInfo;
    procedure CreateForm(const Top, Left, Width, Height: Integer; const Caption: String);
    procedure CreateTrackBar(const Top, Left, Width, Height: Integer; const Tag: Integer);
    procedure CreateCheckBox(const Top, Left, Width, Height: Integer; const Caption: String);
    procedure CreateStaticText(const Top, Left, Width, Height: Integer; const Caption: String);
    procedure TrackBarLoad(Sender: TObject);
    procedure TrackBarSave(Sender: TObject);
    procedure CheckBoxLoad(Sender: TObject);
    procedure CheckBoxSave(Sender: TObject);
    procedure Create();
    procedure Destroy();
    procedure FormShow(Sender: TObject);
    procedure FormHide(Sender: TObject);
  public
    procedure Init();
    procedure Done();
    procedure Show();
    procedure Hide();
    property Info: TInfo read getInfo;
  end;

implementation

uses
  Math,
  StrUtils,
  SysUtils,
  Interfaces;

procedure TWMPFRM.Init();
var
  f: file;
begin
  Application.Initialize();
  self.Create();
  try
    Assign(f, 'equalizer.cfg');
    ReSet(f, 1);
    BlockRead(f, self.finfo, SizeOf(TInfo) * 1);
    Close(f);
  except
  end;
end;

procedure TWMPFRM.Done();
var
  f: file;
begin
  try
    Assign(f, 'equalizer.cfg');
    ReWrite(f, 1);
    BlockWrite(f, self.finfo, SizeOf(TInfo) * 1);
    Close(f);
  except
  end;
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

function TWMPFRM.getInfo(): TInfo;
begin
  Result := self.finfo;
end;

procedure TWMPFRM.Create();
var
  i: Integer;
begin
  self.CreateForm(120, 215, 600, 285, 'Equalizer');
  self.CreateCheckBox(260, 5, 80, 20, 'Enabled');
  self.CreateTrackBar(5, 10, 20, 255, 99);
  self.CreateStaticText(245, 30, 45, 20, '-20 dB')  ;
  self.CreateStaticText(125, 35, 45, 20, '0 dB');
  self.CreateStaticText(5, 30, 45, 20, '+20 dB');
  for i := 0 to Length(self.finfo.Bands) - 1 do begin
    self.CreateTrackBar(5, 75 + 25 * i, 20, 255, i);
    self.CreateStaticText(265, 70 + 25 * i, 30, 20, IfThen(20 * Power(2, 0.5 * i) < 1000, Format('%4.0f ', [20 * Power(2, 0.5 * i) / 1]), Format('%4.1fk', [20 * Power(2, 0.5 * i) / 1000])));
  end;
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
  Result.OnShow := self.FormShow;
  Result.OnHide := self.FormHide;
  self.fform := Result;
end;

procedure TWMPFRM.CreateTrackBar(const Top, Left, Width, Height: Integer; const Tag: Integer);
var
  Result: TTrackBar;
begin
  Result := TTrackBar.Create(nil);
  Result.Font.Size := 8;
  Result.Orientation := trVertical;
  Result.Tag := Tag;
  Result.Top := Top;
  Result.Left := Left;
  Result.Width := Width;
  Result.Height := Height;
  Result.Min := -200;
  Result.Position := 0;
  Result.Max := 200;
  Result.ShowHint := True;
  Result.TickMarks := tmBoth;
  Result.TickStyle := tsNone;
  Result.OnChange := self.TrackBarSave;
  Result.Parent := self.fform;
end;

procedure TWMPFRM.CreateCheckBox(const Top, Left, Width, Height: Integer; const Caption: String);
var
  Result: TCheckBox;
begin
  Result := TCheckBox.Create(nil);
  Result.Font.Size := 8;
  Result.Caption := Caption;
  Result.Top := Top;
  Result.Left := Left;
  Result.Width := Width;
  Result.Height := Height;
  Result.ShowHint := True;
  Result.OnClick := self.CheckBoxSave;
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

procedure TWMPFRM.TrackBarLoad(Sender: TObject);
var
  s: TTrackBar;
begin
  if (Sender is TTrackBar) then begin
    s := (Sender as TTrackBar);
    if (s.Tag = 99) then begin
      s.Position := s.Max - self.finfo.Preamp       + s.Min;
    end             else begin
      s.Position := s.Max - self.finfo.Bands[s.Tag] + s.Min;
    end;
    s.Hint := Format('Gain: %f dB', [(s.Max - s.Position + s.Min) / 10]);
  end;
end;

procedure TWMPFRM.TrackBarSave(Sender: TObject);
var
  s: TTrackBar;
begin
  if (Sender is TTrackBar) then begin
    s := (Sender as TTrackBar);
    if (s.Tag = 99) then begin
      self.finfo.Preamp       := s.Max - s.Position + s.Min;
    end             else begin
      self.finfo.Bands[s.Tag] := s.Max - s.Position + s.Min;
    end;
    s.Hint := Format('Gain: %f dB', [(s.Max - s.Position + s.Min) / 10]);
  end;
end;

procedure TWMPFRM.CheckBoxLoad(Sender: TObject);
var
  s: TCheckBox;
begin
  if (Sender is TCheckBox) then begin
    s := (Sender as TCheckBox);
    if (s.Tag = 99) then begin
      s.Checked := self.finfo.Enabled;
    end             else begin
      s.Checked := self.finfo.Enabled;
    end;
    s.Hint := Format('Enabled: %s', [s.Checked.ToString(TUseBoolStrs.True)]);
  end;
end;

procedure TWMPFRM.CheckBoxSave(Sender: TObject);
var
  s: TCheckBox;
begin
  if (Sender is TCheckBox) then begin
    s := (Sender as TCheckBox);
    if (s.Tag = 99) then begin
      self.finfo.Enabled := s.Checked;
    end             else begin
      self.finfo.Enabled := s.Checked;
    end;
    s.Hint := Format('Enabled: %s', [s.Checked.ToString(TUseBoolStrs.True)]);
  end;
end;

procedure TWMPFRM.FormShow(Sender: TObject);
var
  s: TForm;
  i: Integer;
begin
  if (Sender is TForm) then begin
    s := (Sender as TForm);
    for i := 0 to s.ControlCount - 1 do begin
      if (s.Controls[i] is TTrackBar) then begin
        self.TrackBarLoad(s.Controls[i]);
      end;
      if (s.Controls[i] is TCheckBox) then begin
        self.CheckBoxLoad(s.Controls[i]);
      end;
    end;
  end;
end;

procedure TWMPFRM.FormHide(Sender: TObject);
var
  s: TForm;
  i: Integer;
begin
  if (Sender is TForm) then begin
    s := (Sender as TForm);
    for i := 0 to s.ControlCount - 1 do begin
      if (s.Controls[i] is TTrackBar) then begin
        self.TrackBarSave(s.Controls[i]);
      end;
      if (s.Controls[i] is TCheckBox) then begin
        self.CheckBoxSave(s.Controls[i]);
      end;
    end;
  end;
end;

begin
end.
