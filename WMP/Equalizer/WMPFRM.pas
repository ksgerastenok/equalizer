unit
  WMPFRM;

interface

uses
  WMPDCL;

type
  PWMPFRM = ^TWMPFRM;
  TWMPFRM = record
  private
    var finfo: TInfo;
    function getInfo(): TInfo;
    procedure Create();
    procedure Destroy();
    procedure FormShow(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure TrackBarLoad(Sender: TObject);
    procedure TrackBarSave(Sender: TObject);
  public
    procedure Init();
    procedure Done();
    procedure Show();
    procedure Hide();
    property Info: TInfo read getInfo;
  end;

implementation

uses
  Forms,
  Controls,
  ComCtrls,
  StdCtrls,
  Interfaces,
  Math,
  StrUtils,
  SysUtils;

function getComponent(const Clazz: TWinControlClass; const Tag: Integer): TWinControl;
var
  i: Integer;
begin
  Result := nil;
  for i := 0 to Application.ComponentCount - 1 do begin
    if (Application.Components[i] is Clazz) then begin
      if (Application.Components[i].Tag = Tag) then begin
        Result := (Application.Components[i] as Clazz);
      end;
    end;
  end;
end;

procedure TWMPFRM.Init();
var
  f: file;
begin
  try
    Assign(f, 'equalizer.cfg');
    ReSet(f, 1);
    BlockRead(f, self.finfo, SizeOf(TInfo) * 1);
    Close(f);
  except
  end;
  Application.Initialize();
  self.Create();
  self.finfo.Enabled := True;
end;

procedure TWMPFRM.Done();
var
  f: file;
begin
  self.finfo.Enabled := True;
  self.Destroy();
  Application.Terminate();
  try
    Assign(f, 'equalizer.cfg');
    ReWrite(f, 1);
    BlockWrite(f, self.finfo, SizeOf(TInfo) * 1);
    Close(f);
  except
  end;
end;

procedure TWMPFRM.Show();
begin
  with (getComponent(TForm, 10) as TForm) do begin
    Show();
  end;
end;

procedure TWMPFRM.Hide();
begin
  with (getComponent(TForm, 10) as TForm) do begin
    Hide();
  end;
end;

function TWMPFRM.getInfo(): TInfo;
begin
  Result := self.finfo;
end;

procedure TWMPFRM.Create();
var
  i: Integer;
begin
  with (TForm.Create(Application)) do begin
    Font.Size := 6;
    Caption := 'Equalizer';
    Tag := 10;
    Top := 120;
    Left := 215;
    Width := 600;
    Height := 285;
    BorderIcons := [biSystemMenu];
    BorderStyle := bsSingle;
    FormStyle := fsStayOnTop;
    Position := poMainFormCenter;
    ShowHint := True;
    Parent := nil;
    OnShow := self.FormShow;
    OnHide := self.FormHide;
  end;
  with (TStaticText.Create(Application)) do begin
    Font.Size := 7;
    Caption := '-20 dB';
    Top := 245;
    Left := 30;
    Width := 45;
    Height := 20;
    ShowHint := True;
    Parent := getComponent(TForm, 10);
  end;
  with (TStaticText.Create(Application)) do begin
    Font.Size := 7;
    Caption := '0 dB';
    Top := 125;
    Left := 35;
    Width := 45;
    Height := 20;
    ShowHint := True;
    Parent := getComponent(TForm, 10);
  end;
  with (TStaticText.Create(Application)) do begin
    Font.Size := 7;
    Caption := '+20 dB';
    Top := 5;
    Left := 30;
    Width := 45;
    Height := 20;
    ShowHint := True;
    Parent := getComponent(TForm, 10);
  end;
  with (TTrackBar.Create(Application)) do begin
    Font.Size := 7;
    Orientation := trVertical;
    Top := 5;
    Left := 10;
    Width := 20;
    Height := 255;
    Tag := 99;
    Min := -200;
    Max := +200;
    ShowHint := True;
    TickMarks := tmBoth;
    TickStyle := tsNone;
    Parent := getComponent(TForm, 10);
    OnChange := self.TrackBarSave;
  end;
  with (TStaticText.Create(Application)) do begin
    Font.Size := 7;
    Caption := 'Preamp';
    Top := 265;
    Left := 5;
    Width := 45;
    Height := 20;
    ShowHint := True;
    Parent := getComponent(TForm, 10);
  end;
  for i := 0 to Length(self.finfo.Bands) - 1 do begin
    with (TTrackBar.Create(Application)) do begin
      Font.Size := 7;
      Orientation := trVertical;
      Top := 5;
      Left := 75 + 25 * i;
      Width := 20;
      Height := 255;
      Tag := i;
      Min := -200;
      Max := +200;
      ShowHint := True;
      TickMarks := tmBoth;
      TickStyle := tsNone;
      Parent := getComponent(TForm, 10);
      OnChange := self.TrackBarSave;
    end;
    with (TStaticText.Create(Application)) do begin
      Font.Size := 7;
      Caption := IfThen(20 * Power(2, 0.5 * i) < 1000, Format('%3.0f ', [20 * Power(2, 0.5 * i) / 1]), Format('%2.1fk', [20 * Power(2, 0.5 * i) / 1000]));
      Top := 265;
      Left := 70 + 25 * i;
      Width := 30;
      Height := 20;
      ShowHint := True;
      Parent := getComponent(TForm, 10);
    end;
  end;
end;

procedure TWMPFRM.Destroy();
begin
  with (getComponent(TForm, 10) as TForm) do begin
    Destroy();
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

begin
end.
