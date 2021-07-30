unit
  WMPFRM;

interface

uses
  WMPDCL,
  Forms,
  StdCtrls,
  ComCtrls,
  SysUtils;

type
  PWMPFRM = ^TWMPFRM;
  TWMPFRM = record
  private
    var fform: TForm;
    var finfo: TInfo;
    function getInfo(): PInfo;
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
    procedure Init();
    procedure Quit();
    procedure Show();
    procedure Hide();
    property Info: PInfo read getInfo;
  end;

implementation

function TWMPFRM.getInfo(): PInfo;
begin
  Result := Addr(self.finfo);
end;

procedure TWMPFRM.Init();
var
  f: file;
  i: Integer;
begin
  try
    Assign(f, 'equalizer.cfg');
    ReSet(f, 1);
    BlockRead(f, self.Info^, SizeOf(TInfo) * 1);
    Close(f);
  except
    self.Info.Preamp := 0;
    self.Info.Enabled := False;
    for i := 0 to Length(self.Info.Bands) - 1 do begin
      self.Info.Bands[i] := 0;
    end;
  end;
  self.fform := self.CreateForm();
end;

procedure TWMPFRM.Quit();
var
  f: file;
  i: Integer;
begin
  try
    Assign(f, 'equalizer.cfg');
    ReWrite(f, 1);
    BlockWrite(f, self.Info^, SizeOf(TInfo) * 1);
    Close(f);
  except
    self.Info.Preamp := 0;
    self.Info.Enabled := False;
    for i := 0 to Length(self.Info.Bands) - 1 do begin
      self.Info.Bands[i] := 0;
    end;
  end;
  self.fform.Destroy();
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
  Result.InsertControl(self.CreateTrackBar(5, 80, 20, 255, 0));
  Result.InsertControl(self.CreateTrackBar(5, 110, 20, 255, 1));
  Result.InsertControl(self.CreateTrackBar(5, 140, 20, 255, 2));
  Result.InsertControl(self.CreateTrackBar(5, 170, 20, 255, 3));
  Result.InsertControl(self.CreateTrackBar(5, 200, 20, 255, 4));
  Result.InsertControl(self.CreateTrackBar(5, 230, 20, 255, 5));
  Result.InsertControl(self.CreateTrackBar(5, 260, 20, 255, 6));
  Result.InsertControl(self.CreateTrackBar(5, 290, 20, 255, 7));
  Result.InsertControl(self.CreateTrackBar(5, 320, 20, 255, 8));
  Result.InsertControl(self.CreateTrackBar(5, 350, 20, 255, 9));
  Result.InsertControl(self.CreateTrackBar(5, 380, 20, 255, 10));
  Result.InsertControl(self.CreateTrackBar(5, 410, 20, 255, 11));
  Result.InsertControl(self.CreateTrackBar(5, 440, 20, 255, 12));
  Result.InsertControl(self.CreateTrackBar(5, 470, 20, 255, 13));
  Result.InsertControl(self.CreateTrackBar(5, 500, 20, 255, 14));
  Result.InsertControl(self.CreateTrackBar(5, 530, 20, 255, 15));
  Result.InsertControl(self.CreateTrackBar(5, 560, 20, 255, 16));
  Result.InsertControl(self.CreateTrackBar(5, 590, 20, 255, 17));
  Result.InsertControl(self.CreateTrackBar(5, 620, 20, 255, 18));
  Result.InsertControl(self.CreateTrackBar(5, 650, 20, 255, 19));
  Result.InsertControl(self.CreateTrackBar(5, 680, 20, 255, 20));
  Result.InsertControl(self.CreateStaticText(260, 80, 30, 20, '20'));
  Result.InsertControl(self.CreateStaticText(260, 110, 30, 20, '30'));
  Result.InsertControl(self.CreateStaticText(260, 140, 30, 20, '40'));
  Result.InsertControl(self.CreateStaticText(260, 170, 30, 20, '55'));
  Result.InsertControl(self.CreateStaticText(260, 200, 30, 20, '80'));
  Result.InsertControl(self.CreateStaticText(260, 230, 30, 20, '115'));
  Result.InsertControl(self.CreateStaticText(260, 260, 30, 20, '160'));
  Result.InsertControl(self.CreateStaticText(260, 290, 30, 20, '225'));
  Result.InsertControl(self.CreateStaticText(260, 320, 30, 20, '320'));
  Result.InsertControl(self.CreateStaticText(260, 350, 30, 20, '455'));
  Result.InsertControl(self.CreateStaticText(260, 380, 30, 20, '640'));
  Result.InsertControl(self.CreateStaticText(260, 410, 30, 20, '905'));
  Result.InsertControl(self.CreateStaticText(260, 440, 30, 20, '1.3k'));
  Result.InsertControl(self.CreateStaticText(260, 470, 30, 20, '1.8k'));
  Result.InsertControl(self.CreateStaticText(260, 500, 30, 20, '2.6k'));
  Result.InsertControl(self.CreateStaticText(260, 530, 30, 20, '3.6k'));
  Result.InsertControl(self.CreateStaticText(260, 560, 30, 20, '5.1k'));
  Result.InsertControl(self.CreateStaticText(260, 590, 30, 20, '7.2k'));
  Result.InsertControl(self.CreateStaticText(260, 620, 30, 20, '10.2k'));
  Result.InsertControl(self.CreateStaticText(260, 650, 30, 20, '14.5k'));
  Result.InsertControl(self.CreateStaticText(260, 680, 30, 20, '20.5k'));
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
      Position := Max - self.Info.Preamp     + Min;
      Hint := Format('Gain: %s dB', [FloatToStr((Max - Position + Min) / 10)]);
    end            else begin
      Position := Max - self.Info.Bands[Tag] + Min;
      Hint := Format('Gain: %s dB', [FloatToStr((Max - Position + Min) / 10)]);
    end;
  end;
end;

procedure TWMPFRM.TrackBarSave(Sender: TObject);
begin
  with((Sender as TTrackBar)) do begin
    if((Tag = 99)) then begin
      self.Info.Preamp     := Max - Position + Min;
      Hint := Format('Gain: %s dB', [FloatToStr((Max - Position + Min) / 10)]);
    end            else begin
      self.Info.Bands[Tag] := Max - Position + Min;
      Hint := Format('Gain: %s dB', [FloatToStr((Max - Position + Min) / 10)]);
    end;
  end;
end;

procedure TWMPFRM.CheckBoxLoad(Sender: TObject);
begin
  with((Sender as TCheckBox)) do begin
    if((Tag = 99)) then begin
      Checked := self.Info.Enabled;
      Hint := Format('Enabled: %s', [BoolToStr(Checked, True)]);
    end            else begin
      Checked := self.Info.Enabled;
      Hint := Format('Enabled: %s', [BoolToStr(Checked, True)]);
    end;
  end;
end;

procedure TWMPFRM.CheckBoxSave(Sender: TObject);
begin
  with((Sender as TCheckBox)) do begin
    if((Tag = 99)) then begin
      self.Info.Enabled := Checked;
      Hint := Format('Enabled: %s', [BoolToStr(Checked, True)]);
    end            else begin
      self.Info.Enabled := Checked;
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
