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
    function getInfo(): TInfo;
    function CreateForm(const Top, Left, Width, Height: Integer; const Caption: String): TForm;
    function CreateTrackBar(const Top, Left, Width, Height: Integer; const Tag: Integer): TTrackBar;
    function CreateCheckBox(const Top, Left, Width, Height: Integer; const Caption: String): TCheckBox;
    function CreateStaticText(const Top, Left, Width, Height: Integer; const Caption: String): TStaticText;
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
  Interfaces;

procedure TWMPFRM.Init();
var
  f: file;
begin
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
  Application.Initialize();
  self.fform := self.CreateForm(120, 215, 600, 285, 'Equalizer');
  self.fform.InsertControl(self.CreateCheckBox(260, 5, 80, 20, 'Enabled'));
  self.fform.InsertControl(self.CreateTrackBar(5, 10, 20, 255, 99));
  self.fform.InsertControl(self.CreateStaticText(245, 30, 45, 20, '-20 dB'));
  self.fform.InsertControl(self.CreateStaticText(125, 35, 45, 20, '0 dB'));
  self.fform.InsertControl(self.CreateStaticText(5, 30, 45, 20, '+20 dB'));
  for i := 0 to Length(self.finfo.Bands) - 1 do begin
    self.fform.InsertControl(self.CreateTrackBar(5, 75 + 25 * i, 20, 255, i));
    self.fform.InsertControl(self.CreateStaticText(265, 70 + 25 * i, 30, 20, IfThen(20 * Power(2, 0.5 * i) < 1000, Format('%4.0f ', [20 * Power(2, 0.5 * i) / 1]), Format('%4.1fk', [20 * Power(2, 0.5 * i) / 1000]))));
  end;
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
  Result.OnShow := self.FormShow;
  Result.OnHide := self.FormHide;
end;

function TWMPFRM.CreateTrackBar(const Top, Left, Width, Height: Integer; const Tag: Integer): TTrackBar;
begin
  Result := TTrackBar.Create(Application);
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
end;

function TWMPFRM.CreateCheckBox(const Top, Left, Width, Height: Integer; const Caption: String): TCheckBox;
begin
  Result := TCheckBox.Create(Application);
  Result.Font.Size := 8;
  Result.Caption := Caption;
  Result.Top := Top;
  Result.Left := Left;
  Result.Width := Width;
  Result.Height := Height;
  Result.ShowHint := True;
  Result.OnClick := self.CheckBoxSave;
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

procedure TWMPFRM.TrackBarLoad(Sender: TObject);
begin
  if (Sender is TTrackBar) then begin
    with (Sender as TTrackBar) do begin
      if (Tag = 99) then begin
        Position := Max - self.finfo.Preamp     + Min;
      end           else begin
        Position := Max - self.finfo.Bands[Tag] + Min;
      end;
      Hint := Format('Gain: %f dB', [(Max - Position + Min) / 10]);
    end;
  end;
end;

procedure TWMPFRM.TrackBarSave(Sender: TObject);
begin
  if (Sender is TTrackBar) then begin
    with (Sender as TTrackBar) do begin
      if (Tag = 99) then begin
        self.finfo.Preamp     := Max - Position + Min;
      end           else begin
        self.finfo.Bands[Tag] := Max - Position + Min;
      end;
      Hint := Format('Gain: %f dB', [(Max - Position + Min) / 10]);
    end;
  end;
end;

procedure TWMPFRM.CheckBoxLoad(Sender: TObject);
begin
  if (Sender is TCheckBox) then begin
    with (Sender as TCheckBox) do begin
      if (Tag = 99) then begin
        Checked := self.finfo.Enabled;
      end           else begin
        Checked := self.finfo.Enabled;
      end;
      Hint := Format('Enabled: %s', [Checked.ToString(TUseBoolStrs.True)]);
    end;
  end;
end;

procedure TWMPFRM.CheckBoxSave(Sender: TObject);
begin
  if (Sender is TCheckBox) then begin
    with (Sender as TCheckBox) do begin
      if (Tag = 99) then begin
        self.finfo.Enabled := Checked;
      end           else begin
        self.finfo.Enabled := Checked;
      end;
      Hint := Format('Enabled: %s', [Checked.ToString(TUseBoolStrs.True)]);
    end;
  end;
end;

procedure TWMPFRM.FormShow(Sender: TObject);
var
  i: Integer;
begin
  if (Sender is TForm) then begin
    with (Sender as TForm) do begin
      for i := 0 to ControlCount - 1 do begin
        if (Controls[i] is TTrackBar) then begin
          self.TrackBarLoad(Controls[i]);
        end;
        if (Controls[i] is TCheckBox) then begin
          self.CheckBoxLoad(Controls[i]);
        end;
      end;
    end;
  end;
end;

procedure TWMPFRM.FormHide(Sender: TObject);
var
  i: Integer;
begin
  if (Sender is TForm) then begin
    with (Sender as TForm) do begin
      for i := 0 to ControlCount - 1 do begin
        if (Controls[i] is TTrackBar) then begin
          self.TrackBarSave(Controls[i]);
        end;
        if (Controls[i] is TCheckBox) then begin
          self.CheckBoxSave(Controls[i]);
        end;
      end;
    end;
  end;
end;

begin
end.
