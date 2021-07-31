unit
  WMPFRM;

interface

uses
  WMPDCL,
  WMPDSP,
  Forms,
  StdCtrls,
  ComCtrls,
  SysUtils;

type
  PWMPFRM = ^TWMPFRM;
  TWMPFRM = record
  private
    var fform: TForm;
    var ffdsp: PWMPDSP;
    function CreateForm(): TForm;
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
    procedure Init(const DSP: PWMPDSP);
    procedure Quit();
    procedure Show();
    procedure Hide();
  end;

implementation

uses
  Math;

procedure TWMPFRM.Init(const DSP: PWMPDSP);
var
  f: file;
begin
  self.ffdsp := DSP;
  self.fform := self.CreateForm();
  try
    Assign(f, 'equalizer.cfg');
    ReSet(f, 1);
    BlockRead(f, self.ffdsp.Info^, SizeOf(TInfo) * 1);
    Close(f);
  except
    self.ffdsp.Info.Preamp := 0;
    self.ffdsp.Info.Enabled := False;
    for var i := 0 to Length(self.ffdsp.Info.Bands) - 1 do begin
      self.ffdsp.Info.Bands[i] := 0;
    end;
  end;
end;

procedure TWMPFRM.Quit();
var
  f: file;
begin
  try
    Assign(f, 'equalizer.cfg');
    ReWrite(f, 1);
    BlockWrite(f, self.ffdsp.Info^, SizeOf(TInfo) * 1);
    Close(f);
  except
    self.ffdsp.Info.Preamp := 0;
    self.ffdsp.Info.Enabled := False;
    for var i := 0 to Length(self.ffdsp.Info.Bands) - 1 do begin
      self.ffdsp.Info.Bands[i] := 0;
    end;
  end;
  self.fform.Destroy();
  self.ffdsp := nil;
end;

procedure TWMPFRM.Show();
begin
  self.fform.Show();
end;

procedure TWMPFRM.Hide();
begin
  self.fform.Hide();
end;

function TWMPFRM.CreateForm(): TForm;
begin
  Result := TForm.CreateParented(0);
  Result.Caption := 'Equalizer';
  Result.Top := 120;
  Result.Left := 215;
  Result.Width := 715;
  Result.Height := 315;
  Result.BorderIcons := [biSystemMenu];
  Result.BorderStyle := bsSingle;
  Result.Position := poMainFormCenter;
  Result.ShowHint := True;
  Result.OnShow := self.FormShow;
  Result.OnHide := self.FormHide;
  Result.InsertControl(self.CreateCheckBox(260, 5, 65, 15, 'Enabled'));
  Result.InsertControl(self.CreateTrackBar(5, 5, 20, 255, 99));
  Result.InsertControl(self.CreateStaticText(240, 30, 35, 15, '-20 dB'));
  Result.InsertControl(self.CreateStaticText(125, 35, 35, 15, '0 dB'));
  Result.InsertControl(self.CreateStaticText(10, 30, 35, 15, '+20 dB'));
  for var i := 0 to Length(self.ffdsp.Info.Bands) - 1 do begin
    var x := 20 * Power(2, 0.5 * i);
    if((x < 1000)) then begin
      Result.InsertControl(self.CreateTrackBar(5, 80 + 30 * i, 20, 255, i));
      Result.InsertControl(self.CreateStaticText(260, 75 + 30 * i, 30, 20, Format('%4.0f ', [x / 1])));
    end            else begin
      Result.InsertControl(self.CreateTrackBar(5, 80 + 30 * i, 20, 255, i));
      Result.InsertControl(self.CreateStaticText(260, 75 + 30 * i, 30, 20, Format('%4.1fk', [x / 1000])));
    end;
  end;
end;

function TWMPFRM.CreateStaticText(const Top, Left, Width, Height: Integer; const Caption: String): TStaticText;
begin
  Result := TStaticText.CreateParented(0);
  Result.Caption := Caption;
  Result.Top := Top;
  Result.Left := Left;
  Result.Width := Width;
  Result.Height := Height;
end;

function TWMPFRM.CreateTrackBar(const Top, Left, Width, Height: Integer; const Tag: Integer): TTrackBar;
begin
  Result := TTrackBar.CreateParented(0);
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
  Result.ThumbLength := 15;
  Result.TickMarks := tmBoth;
  Result.TickStyle := tsNone;
  Result.OnExit := self.TrackBarSave;
  Result.OnEnter := self.TrackBarLoad;
  Result.OnChange := self.TrackBarSave;
end;

function TWMPFRM.CreateCheckBox(const Top, Left, Width, Height: Integer; const Caption: String): TCheckBox;
begin
  Result := TCheckBox.CreateParented(0);
  Result.Caption := Caption;
  Result.Top := Top;
  Result.Left := Left;
  Result.Width := Width;
  Result.Height := Height;
  Result.OnClick := CheckBoxSave;
end;

procedure TWMPFRM.TrackBarLoad(Sender: TObject);
begin
  with((Sender as TTrackBar)) do begin
    if((Tag = 99)) then begin
      Position := Max - self.ffdsp.Info.Preamp     + Min;
      Hint := Format('Gain: %s dB', [FloatToStr((Max - Position + Min) / 10)]);
    end            else begin
      Position := Max - self.ffdsp.Info.Bands[Tag] + Min;
      Hint := Format('Gain: %s dB', [FloatToStr((Max - Position + Min) / 10)]);
    end;
  end;
end;

procedure TWMPFRM.TrackBarSave(Sender: TObject);
begin
  with((Sender as TTrackBar)) do begin
    if((Tag = 99)) then begin
      self.ffdsp.Info.Preamp     := Max - Position + Min;
      Hint := Format('Gain: %s dB', [FloatToStr((Max - Position + Min) / 10)]);
    end            else begin
      self.ffdsp.Info.Bands[Tag] := Max - Position + Min;
      Hint := Format('Gain: %s dB', [FloatToStr((Max - Position + Min) / 10)]);
    end;
  end;
end;

procedure TWMPFRM.CheckBoxLoad(Sender: TObject);
begin
  with((Sender as TCheckBox)) do begin
    if((Tag = 99)) then begin
      Checked := self.ffdsp.Info.Enabled;
      Hint := Format('Enabled: %s', [BoolToStr(Checked, True)]);
    end            else begin
      Checked := self.ffdsp.Info.Enabled;
      Hint := Format('Enabled: %s', [BoolToStr(Checked, True)]);
    end;
  end;
end;

procedure TWMPFRM.CheckBoxSave(Sender: TObject);
begin
  with((Sender as TCheckBox)) do begin
    if((Tag = 99)) then begin
      self.ffdsp.Info.Enabled := Checked;
      Hint := Format('Enabled: %s', [BoolToStr(Checked, True)]);
    end            else begin
      self.ffdsp.Info.Enabled := Checked;
      Hint := Format('Enabled: %s', [BoolToStr(Checked, True)]);
    end;
  end;
end;

procedure TWMPFRM.FormShow(Sender: TObject);
begin
  with((Sender as TForm)) do begin
    for var i := 0 to ControlCount - 1 do begin
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
begin
  with((Sender as TForm)) do begin
    for var i := 0 to ControlCount - 1 do begin
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
