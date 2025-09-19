unit
  WMPFRM;

interface

uses
  WMPDCL;

type
  PFilter = ^TFilter;
  TFilter = record
    var Amp: Double;
    var Freq: Double;
    var Width: Double;
  end;

type
  PWMPFRM = ^TWMPFRM;
  TWMPFRM = record
  private
    var finfo: TInfo;
    var fbass: TFilter;
    var ftrbl: TFilter;
    function getInfo(): PInfo;
    function getBass(): PFilter;
    function getTreble(): PFilter;
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
    procedure Update();
    procedure Hide();
    property Info: PInfo read getInfo;
    property Bass: PFilter read getBass;
    property Treble: PFilter read getTreble;
  end;

implementation

uses
  Forms,
  Controls,
  ComCtrls,
  Interfaces,  
  StdCtrls,
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
    Assign(f, 'enhancer.cfg');
    ReSet(f, 1);
    BlockRead(f, self.finfo, SizeOf(TInfo) * 1);
    BlockRead(f, self.fbass, SizeOf(TFilter) * 1);
    BlockRead(f, self.ftrbl, SizeOf(TFilter) * 1);
    Close(f)
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
    Assign(f, 'enhancer.cfg');
    ReWrite(f, 1);
    BlockWrite(f, self.finfo, SizeOf(TInfo) * 1);
    BlockWrite(f, self.fbass, SizeOf(TFilter) * 1);
    BlockWrite(f, self.ftrbl, SizeOf(TFilter) * 1);
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

procedure TWMPFRM.Update();
begin
  self.TrackBarLoad(getComponent(TTrackBar, 2));
end;

procedure TWMPFRM.Hide();
begin
  with (getComponent(TForm, 10) as TForm) do begin
    Hide();
  end;
end;

function TWMPFRM.getInfo(): PInfo;
begin
  Result := Addr(self.finfo);
end;

function TWMPFRM.getBass(): PFilter;
begin
  Result := Addr(self.fbass);
end;

function TWMPFRM.getTreble(): PFilter;
begin
  Result := Addr(self.ftrbl);
end;

procedure TWMPFRM.Create();
begin
  with (TForm.Create(Application)) do begin
    Font.Size := 8;
    Caption := 'Enhancer';
    Tag := 10;
    Top := 120;
    Left := 215;
    Width := 450;
    Height := 265;
    BorderIcons := [biSystemMenu];
    BorderStyle := bsSingle;
    FormStyle := fsStayOnTop;
    Position := poMainFormCenter;
    ShowHint := True;
    Parent := nil;
    OnShow := self.FormShow;
    OnHide := self.FormHide;
  end;
  with (TGroupBox.Create(Application)) do begin
    Font.Size := 8;
    Caption := 'Amp';
    Tag := 10;
    Top := 0;
    Left := 5;
    Width := 440;
    Height := 70;
    Parent := getComponent(TForm, 10);
  end;
  with (TStaticText.Create(Application)) do begin
    Font.Size := 8;
    Caption := 'Limit';
    Top := 0;
    Left := 0;
    Width := 35;
    Height := 20;
    ShowHint := True;
    Parent := getComponent(TGroupBox, 10);
  end;
  with (TTrackBar.Create(Application)) do begin
    Font.Size := 8;
    Orientation := trHorizontal;
    Tag := 1;
    Top := 0;
    Left := 35;
    Width := 400;
    Height := 20;
    Min := 0;
    Max := 200;
    Enabled := True;
    ShowHint := True;
    TickMarks := tmBoth;
    TickStyle := tsNone;
    Parent := getComponent(TGroupBox, 10);
    OnChange := self.TrackBarSave;
  end;
  with (TStaticText.Create(Application)) do begin
    Font.Size := 8;
    Caption := 'Value';
    Top := 25;
    Left := 0;
    Width := 35;
    Height := 20;
    ShowHint := True;
    Parent := getComponent(TGroupBox, 10);
  end;
  with (TTrackBar.Create(Application)) do begin
    Font.Size := 8;
    Orientation := trHorizontal;
    Tag := 2;
    Top := 25;
    Left := 35;
    Width := 400;
    Height := 20;
    Min := 0;
    Max := 200;
    Enabled := False;
    ShowHint := True;
    TickMarks := tmBoth;
    TickStyle := tsNone;
    Parent := getComponent(TGroupBox, 10);
  end;
  with (TGroupBox.Create(Application)) do begin
    Font.Size := 8;
    Caption := 'Bass';
    Tag := 20;
    Top := 70;
    Left := 5;
    Width := 440;
    Height := 95;
    Parent := getComponent(TForm, 10);
  end;
  with (TStaticText.Create(Application)) do begin
    Font.Size := 8;
    Caption := 'Amp';
    Top := 0;
    Left := 0;
    Width := 35;
    Height := 20;
    ShowHint := True;
    Parent := getComponent(TGroupBox, 20);
  end;
  with (TTrackBar.Create(Application)) do begin
    Font.Size := 8;
    Orientation := trHorizontal;
    Tag := 10;
    Top := 0;
    Left := 35;
    Width := 400;
    Height := 20;
    Min := -200;
    Max := +200;
    Enabled := True;
    ShowHint := True;
    TickMarks := tmBoth;
    TickStyle := tsNone;
    Parent := getComponent(TGroupBox, 20);
    OnChange := self.TrackBarSave;
  end;
  with (TStaticText.Create(Application)) do begin
    Font.Size := 8;
    Caption := 'Freq';
    Top := 25;
    Left := 0;
    Width := 35;
    Height := 20;
    ShowHint := True;
    Parent := getComponent(TGroupBox, 20);
  end;
  with (TTrackBar.Create(Application)) do begin
    Font.Size := 8;
    Orientation := trHorizontal;
    Tag := 11;
    Top := 25;
    Left := 35;
    Width := 400;
    Height := 20;
    Min := 5;
    Max := 50;
    Enabled := True;
    ShowHint := True;
    TickMarks := tmBoth;
    TickStyle := tsNone;
    Parent := getComponent(TGroupBox, 20);
    OnChange := self.TrackBarSave;
  end;
  with (TStaticText.Create(Application)) do begin
    Font.Size := 8;
    Caption := 'Width';
    Top := 50;
    Left := 0;
    Width := 35;
    Height := 20;
    ShowHint := True;
    Parent := getComponent(TGroupBox, 20);
  end;
  with (TTrackBar.Create(Application)) do begin
    Font.Size := 8;
    Orientation := trHorizontal;
    Tag := 12;
    Top := 50;
    Left := 35;
    Width := 400;
    Height := 20;
    Min := 5;
    Max := 50;
    Enabled := True;
    ShowHint := True;
    TickMarks := tmBoth;
    TickStyle := tsNone;
    Parent := getComponent(TGroupBox, 20);
    OnChange := self.TrackBarSave;
  end;
  with (TGroupBox.Create(Application)) do begin
    Font.Size := 8;
    Caption := 'Treble';
    Tag := 30;
    Top := 165;
    Left := 5;
    Width := 440;
    Height := 95;
    Parent := getComponent(TForm, 10);
  end;
  with (TStaticText.Create(Application)) do begin
    Font.Size := 8;
    Caption := 'Amp';
    Top := 0;
    Left := 0;
    Width := 35;
    Height := 20;
    ShowHint := True;
    Parent := getComponent(TGroupBox, 30);
  end;
  with (TTrackBar.Create(Application)) do begin
    Font.Size := 8;
    Orientation := trHorizontal;
    Tag := 20;
    Top := 0;
    Left := 35;
    Width := 400;
    Height := 20;
    Min := -200;
    Max := +200;
    Enabled := True;
    ShowHint := True;
    TickMarks := tmBoth;
    TickStyle := tsNone;
    Parent := getComponent(TGroupBox, 30);
    OnChange := self.TrackBarSave;
  end;
  with (TStaticText.Create(Application)) do begin
    Font.Size := 8;
    Caption := 'Freq';
    Top := 25;
    Left := 0;
    Width := 35;
    Height := 20;
    ShowHint := True;
    Parent := getComponent(TGroupBox, 30);
  end;
  with (TTrackBar.Create(Application)) do begin
    Font.Size := 8;
    Orientation := trHorizontal;
    Tag := 21;
    Top := 25;
    Left := 35;
    Width := 400;
    Height := 20;
    Min := 5;
    Max := 150;
    Enabled := True;
    ShowHint := True;
    TickMarks := tmBoth;
    TickStyle := tsNone;
    Parent := getComponent(TGroupBox, 30);
    OnChange := self.TrackBarSave;
  end;
  with (TStaticText.Create(Application)) do begin
    Font.Size := 8;
    Caption := 'Width';
    Top := 50;
    Left := 0;
    Width := 35;
    Height := 20;
    ShowHint := True;
    Parent := getComponent(TGroupBox, 30);
  end;
  with (TTrackBar.Create(Application)) do begin
    Font.Size := 8;
    Orientation := trHorizontal;
    Tag := 22;
    Top := 50;
    Left := 35;
    Width := 400;
    Height := 20;
    Min := 5;
    Max := 50;
    Enabled := True;
    ShowHint := True;
    TickMarks := tmBoth;
    TickStyle := tsNone;
    Parent := getComponent(TGroupBox, 30);
    OnChange := self.TrackBarSave;
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
  k: Integer;
begin
  if (Sender is TForm) then begin
    with (Sender as TForm) do begin
      for i := 0 to ControlCount - 1 do begin
        if (Controls[i] is TGroupBox) then begin
          with (Controls[i] as TGroupBox) do begin
            for k := 0 to ControlCount - 1 do begin
              if (Controls[k] is TTrackBar) then begin
                self.TrackBarLoad(Controls[k]);
              end;
            end;
          end;
        end;
      end;
    end;
  end;
end;

procedure TWMPFRM.FormHide(Sender: TObject);
var
  i: Integer;
  k: Integer;
begin
  if (Sender is TForm) then begin
    with (Sender as TForm) do begin
      for i := 0 to ControlCount - 1 do begin
        if (Controls[i] is TGroupBox) then begin
          with (Controls[i] as TGroupBox) do begin
            for k := 0 to ControlCount - 1 do begin
              if (Controls[k] is TTrackBar) then begin
                self.TrackBarLoad(Controls[k]);
              end;
            end;
          end;
        end;
      end;
    end;
  end;
end;

procedure TWMPFRM.TrackBarLoad(Sender: TObject);
begin
  if (Sender is TTrackBar) then begin
    with (Sender as TTrackBar) do begin
      if (Tag = 1) then begin
        Position := self.finfo.Preamp;
        Hint := Format('Limit: %f dB', [self.finfo.Preamp / 10]);
      end;
      if (Tag = 2) then begin
        Position := self.finfo.Size;
        Hint := Format('Value: %f dB', [self.finfo.Size / 10]);
      end;
      if (Tag = 10) then begin
        Position := Round(self.fbass.Amp * 10.0);
        Hint := Format('Amp: %f dB', [self.fbass.Amp]);
      end;
      if (Tag = 11) then begin
        Position := Round(self.fbass.Freq / 10.0);
        Hint := Format('Freq: %f Hz', [self.fbass.Freq]);
      end;
      if (Tag = 12) then begin
        Position := Round(self.fbass.Width * 10.0);
        Hint := Format('Width: %f Octave', [self.fbass.Width]);
      end;
      if (Tag = 20) then begin
        Position := Round(self.ftrbl.Amp * 10.0);
        Hint := Format('Amp: %f dB', [self.ftrbl.Amp]);
      end;
      if (Tag = 21) then begin
        Position := Round(self.ftrbl.Freq / 100.0);
        Hint := Format('Freq: %f Hz', [self.ftrbl.Freq]);
      end;
      if (Tag = 22) then begin
        Position := Round(self.ftrbl.Width * 10.0);
        Hint := Format('Width: %f Octave', [self.ftrbl.Width]);
      end;
    end;
  end;
end;

procedure TWMPFRM.TrackBarSave(Sender: TObject);
begin
  if (Sender is TTrackBar) then begin
    with (Sender as TTrackBar) do begin
      if (Tag = 1) then begin
        self.finfo.Preamp := Position;
        Hint := Format('Limit: %f dB', [self.finfo.Preamp / 10]);
      end;
      if (Tag = 2) then begin
        self.finfo.Size := Position;
        Hint := Format('Value: %f dB', [self.finfo.Size / 10]);
      end;
      if (Tag = 10) then begin
        self.fbass.Amp := Position / 10.0;
        Hint := Format('Amp: %f dB', [self.fbass.Amp]);
      end;
      if (Tag = 11) then begin
        self.fbass.Freq := Position * 10.0;
        Hint := Format('Freq: %f Hz', [self.fbass.Freq]);
      end;
      if (Tag = 12) then begin
        self.fbass.Width := Position / 10.0;
        Hint := Format('Width: %f Octave', [self.fbass.Width]);
      end;
      if (Tag = 20) then begin
        self.ftrbl.Amp := Position / 10.0;
        Hint := Format('Amp: %f dB', [self.ftrbl.Amp]);
      end;
      if (Tag = 21) then begin
        self.ftrbl.Freq := Position * 100.0;
        Hint := Format('Freq: %f Hz', [self.ftrbl.Freq]);
      end;
      if (Tag = 22) then begin
        self.ftrbl.Width := Position / 10.0;
        Hint := Format('Width: %f Octave', [self.ftrbl.Width]);
      end;
    end;
  end;
end;

begin
end.
