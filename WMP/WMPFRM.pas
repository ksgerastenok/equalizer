unit
  WMPFRM;

interface

uses
  WMPDCL,
  Forms,
  Controls,
  StdCtrls,
  ComCtrls,
  SysUtils,
  Interfaces;

type
  PWMPFRM = ^TWMPFRM;
  TWMPFRM = object
  private
    var finfo: PInfo;
    var fform: TForm;
    function CreateForm(const Top, Left, Width, Height: Integer; const Caption: String): TForm;
    function CreateTrackBar(const Top, Left, Width, Height: Integer; const Tag: Integer): TTrackBar;
    function CreateCheckBox(const Top, Left, Width, Height: Integer; const Caption: String): TCheckBox;
    function CreateStaticText(const Top, Left, Width, Height: Integer; const Caption: String): TStaticText;
    procedure FormShow(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure TrackBarLoad(Sender: TObject);
    procedure TrackBarSave(Sender: TObject);
    procedure CheckBoxLoad(Sender: TObject);
    procedure CheckBoxSave(Sender: TObject);
  public
    constructor Init(const Info: PInfo);
    destructor Done();
    procedure Show();
    procedure Hide();
  end;

implementation

uses
  Math;

constructor TWMPFRM.Init(const Info: PInfo);
var
  f: file;
  i: Integer;
begin
  Application.Initialize();
  self.finfo := Info;
  self.fform := self.CreateForm(120, 215, 710, 285, 'Equalizer');
  try
    Assign(f, 'equalizer.cfg');
    ReSet(f, 1);
    BlockRead(f, self.finfo^, SizeOf(TInfo) * 1);
    Close(f);
  except
    self.finfo^.Preamp := 0;
    self.finfo^.Enabled := False;
    for i := 0 to Length(self.finfo^.Bands) - 1 do begin
      self.finfo^.Bands[i] := 0;
    end;
  end;
end;

destructor TWMPFRM.Done();
var
  f: file;
  i: Integer;
begin
  try
    Assign(f, 'equalizer.cfg');
    ReWrite(f, 1);
    BlockWrite(f, self.finfo^, SizeOf(TInfo) * 1);
    Close(f);
  except
    self.finfo^.Preamp := 0;
    self.finfo^.Enabled := False;
    for i := 0 to Length(self.finfo^.Bands) - 1 do begin
      self.finfo^.Bands[i] := 0;
    end;
  end;
  self.finfo := nil;
  self.fform.Destroy();
  Application.Initialize();
end;

procedure TWMPFRM.Show();
begin
  self.fform.Show();
end;

procedure TWMPFRM.Hide();
begin
  self.fform.Hide();
end;

function TWMPFRM.CreateForm(const Top, Left, Width, Height: Integer; const Caption: String): TForm;
var
  x: Double;
  i: Integer;
begin
  Result := TForm.Create(Application);
  Result.Caption := Caption;
  Result.Top := Top;
  Result.Left := Left;
  Result.Width := Width;
  Result.Height := Height;
  Result.Font.Size := 8;
  Result.BorderIcons := [biSystemMenu];
  Result.BorderStyle := bsSingle;
  Result.Position := poMainFormCenter;
  Result.ShowHint := True;
  Result.OnShow := @self.FormShow;
  Result.OnHide := @self.FormHide;
  Result.InsertControl(self.CreateCheckBox(260, 5, 80, 20, 'Enabled'));
  Result.InsertControl(self.CreateTrackBar(5, 5, 25, 255, 99));
  Result.InsertControl(self.CreateStaticText(240, 30, 40, 20, '-20 dB'));
  Result.InsertControl(self.CreateStaticText(120, 40, 40, 20, '0 dB'));
  Result.InsertControl(self.CreateStaticText(5, 30, 40, 20, '+20 dB'));
  for i := 0 to Length(self.finfo^.Bands) - 1 do begin
    x := 20 * Power(2, 0.5 * i);
    if((x < 1000)) then begin
      Result.InsertControl(self.CreateTrackBar(5, 85 + 30 * i, 25, 255, i));
      Result.InsertControl(self.CreateStaticText(265, 80 + 30 * i, 30, 20, Format('%4.0f ', [x / 1])));
    end            else begin
      Result.InsertControl(self.CreateTrackBar(5, 85 + 30 * i, 25, 255, i));
      Result.InsertControl(self.CreateStaticText(265, 80 + 30 * i, 30, 20, Format('%4.1fk', [x / 1000])));
    end;
  end;
end;

function TWMPFRM.CreateStaticText(const Top, Left, Width, Height: Integer; const Caption: String): TStaticText;
begin
  Result := TStaticText.Create(Application);
  Result.Caption := Caption;
  Result.Top := Top;
  Result.Left := Left;
  Result.Width := Width;
  Result.Height := Height;
  Result.Font.Size := 8;
end;

function TWMPFRM.CreateTrackBar(const Top, Left, Width, Height: Integer; const Tag: Integer): TTrackBar;
begin
  Result := TTrackBar.Create(Application);
  Result.Orientation := trVertical;
  Result.Tag := Tag;
  Result.Top := Top;
  Result.Left := Left;
  Result.Width := Width;
  Result.Height := Height;
  Result.Font.Size := 8;
  Result.Min := -200;
  Result.Position := 0;
  Result.Max := 200;
  Result.ShowHint := True;
  Result.TickMarks := tmBoth;
  Result.TickStyle := tsNone;
  Result.OnExit := @self.TrackBarSave;
  Result.OnEnter := @self.TrackBarLoad;
  Result.OnChange := @self.TrackBarSave;
end;

function TWMPFRM.CreateCheckBox(const Top, Left, Width, Height: Integer; const Caption: String): TCheckBox;
begin
  Result := TCheckBox.Create(Application);
  Result.Caption := Caption;
  Result.Top := Top;
  Result.Left := Left;
  Result.Width := Width;
  Result.Height := Height;
  Result.Font.Size := 8;
  Result.OnClick := @CheckBoxSave;
end;

procedure TWMPFRM.TrackBarLoad(Sender: TObject);
begin
  with((Sender as TTrackBar)) do begin
    if((Tag = 99)) then begin
      Position := Max - self.finfo^.Preamp     + Min;
      Hint := Format('Gain: %s dB', [FloatToStr((Max - Position + Min) / 10)]);
    end            else begin
      Position := Max - self.finfo^.Bands[Tag] + Min;
      Hint := Format('Gain: %s dB', [FloatToStr((Max - Position + Min) / 10)]);
    end;
  end;
end;

procedure TWMPFRM.TrackBarSave(Sender: TObject);
begin
  with((Sender as TTrackBar)) do begin
    if((Tag = 99)) then begin
      self.finfo^.Preamp     := Max - Position + Min;
      Hint := Format('Gain: %s dB', [FloatToStr((Max - Position + Min) / 10)]);
    end            else begin
      self.finfo^.Bands[Tag] := Max - Position + Min;
      Hint := Format('Gain: %s dB', [FloatToStr((Max - Position + Min) / 10)]);
    end;
  end;
end;

procedure TWMPFRM.CheckBoxLoad(Sender: TObject);
begin
  with((Sender as TCheckBox)) do begin
    if((Tag = 99)) then begin
      Checked := self.finfo^.Enabled;
      Hint := Format('Enabled: %s', [BoolToStr(Checked, True)]);
    end            else begin
      Checked := self.finfo^.Enabled;
      Hint := Format('Enabled: %s', [BoolToStr(Checked, True)]);
    end;
  end;
end;

procedure TWMPFRM.CheckBoxSave(Sender: TObject);
begin
  with((Sender as TCheckBox)) do begin
    if((Tag = 99)) then begin
      self.finfo^.Enabled := Checked;
      Hint := Format('Enabled: %s', [BoolToStr(Checked, True)]);
    end            else begin
      self.finfo^.Enabled := Checked;
      Hint := Format('Enabled: %s', [BoolToStr(Checked, True)]);
    end;
  end;
end;

procedure TWMPFRM.FormShow(Sender: TObject);
var
  i: Integer;
begin
  with((Sender as TForm)) do begin
    for i := 0 to ControlCount - 1 do begin
      if((Controls[i] is TTrackBar)) then begin
        self.TrackBarLoad(Controls[i]);
      end;
      if((Controls[i] is TCheckBox)) then begin
        self.CheckBoxLoad(Controls[i]);
      end;
    end;
  end;
end;

procedure TWMPFRM.FormHide(Sender: TObject);
var
  i: Integer;
begin
  with((Sender as TForm)) do begin
    for i := 0 to ControlCount - 1 do begin
      if((Controls[i] is TTrackBar)) then begin
        self.TrackBarSave(Controls[i]);
      end;
      if((Controls[i] is TCheckBox)) then begin
        self.CheckBoxSave(Controls[i]);
      end;
    end;
  end;
end;

begin
end.
