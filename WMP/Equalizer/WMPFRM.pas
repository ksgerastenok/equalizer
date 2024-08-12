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
    function getInfo(): TInfo;
    function getForm(): TForm;
    procedure Create();
    procedure Destroy();
    procedure FormShow(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure TrackBarLoad(Sender: TObject);
    procedure TrackBarSave(Sender: TObject);
    procedure CheckBoxLoad(Sender: TObject);
    procedure CheckBoxSave(Sender: TObject);
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
  self.getForm().Show();
end;

procedure TWMPFRM.Hide();
begin
  self.getForm().Hide();
end;

function TWMPFRM.getInfo(): TInfo;
begin
  Result := self.finfo;
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
var
  i: Integer;
begin
  with (TForm.Create(Application)) do begin
    Font.Size := 8;
    Caption := 'Equalizer';
    Top := 120;
    Left := 215;
    Width := 600;
    Height := 285;
    BorderIcons := [biSystemMenu];
    BorderStyle := bsSingle;
    Position := poMainFormCenter;
    ShowHint := True;
    Parent := nil;
    OnShow := self.FormShow;
    OnHide := self.FormHide;
  end;
  with (TCheckBox.Create(Application)) do begin
    Font.Size := 8;
    Caption := 'Enabled';
    Top := 260;
    Left := 5;
    Width := 80;
    Height := 20;
    ShowHint := True;
    Parent := self.getForm();
    OnClick := self.CheckBoxSave;
  end;
  with (TTrackBar.Create(Application)) do begin
    Font.Size := 8;
    Orientation := trVertical;
    Top := 5;
    Left := 10;
    Width := 20;
    Height := 255;
    Tag := 99;
    Min := -200;
    Position := 0;
    Max := 200;
    ShowHint := True;
    TickMarks := tmBoth;
    TickStyle := tsNone;
    Parent := self.getForm();
    OnChange := self.TrackBarSave;
  end;
  with (TStaticText.Create(Application)) do begin
    Font.Size := 8;
    Caption := '-20 dB';
    Top := 245;
    Left := 30;
    Width := 45;
    Height := 20;
    ShowHint := True;
    Parent := self.getForm();
  end;
  with (TStaticText.Create(Application)) do begin
    Font.Size := 8;
    Caption := '0 dB';
    Top := 125;
    Left := 35;
    Width := 45;
    Height := 20;
    ShowHint := True;
    Parent := self.getForm();
  end;
  with (TStaticText.Create(Application)) do begin
    Font.Size := 8;
    Caption := '+20 dB';
    Top := 5;
    Left := 30;
    Width := 45;
    Height := 20;
    ShowHint := True;
    Parent := self.getForm();
  end;
  for i := 0 to Length(self.finfo.Bands) - 1 do begin
    with (TTrackBar.Create(Application)) do begin
      Font.Size := 8;
      Orientation := trVertical;
      Top := 5;
      Left := 75 + 25 * i;
      Width := 20;
      Height := 255;
      Tag := i;
      Min := -200;
      Position := 0;
      Max := 200;
      ShowHint := True;
      TickMarks := tmBoth;
      TickStyle := tsNone;
      Parent := self.getForm();
      OnChange := self.TrackBarSave;
    end;
    with (TStaticText.Create(Application)) do begin
      Font.Size := 8;
      Caption := IfThen(20 * Power(2, 0.5 * i) < 1000, Format('%4.0f ', [20 * Power(2, 0.5 * i) / 1]), Format('%4.1fk', [20 * Power(2, 0.5 * i) / 1000]));
      Top := 265;
      Left := 70 + 25 * i;
      Width := 30;
      Height := 20;
      ShowHint := True;
      Parent := self.getForm();
    end;
  end;
end;

procedure TWMPFRM.Destroy();
begin
  self.getForm().Close();
  self.getForm().Destroy();
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

begin
end.
