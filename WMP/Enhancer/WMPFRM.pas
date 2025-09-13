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
    function getInfo(): TInfo;
    function getBass(): TFilter;
    function getTreble(): TFilter;
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
    property Bass: TFilter read getBass;
    property Treble: TFilter read getTreble;
  end;

implementation

uses
  Forms,
  Controls,
  ComCtrls,
  StdCtrls,
  SysUtils,
  Interfaces;

function getForm(): TForm;
var
  i: Integer;
begin
  Result := nil;
  for i := 0 to Application.ComponentCount - 1 do begin
    if (Application.Components[i] is TForm) then begin
      if (Application.Components[i] <> Application.MainForm) then begin
        Result := (Application.Components[i] as TForm);
      end;
    end;
  end;
end;

procedure TWMPFRM.Init();
begin
  Application.Initialize();
  self.Create();
  self.finfo.Enabled := True;
  self.fbass.Amp := 5.0;
  self.fbass.Freq := 140.0;
  self.fbass.Width := 2.5;
  self.ftrbl.Amp := 15.0;
  self.ftrbl.Freq := 3500.0;
  self.ftrbl.Width := 2.5;
end;

procedure TWMPFRM.Done();
begin
  self.finfo.Enabled := True;
  self.fbass.Amp := 0.0;
  self.fbass.Freq := 0.0;
  self.fbass.Width := 0.0;
  self.ftrbl.Amp := 0.0;
  self.ftrbl.Freq := 0.0;
  self.ftrbl.Width := 0.0;
  self.Destroy();
  Application.Terminate();
end;

procedure TWMPFRM.Show();
begin
  getForm().Show();
end;

procedure TWMPFRM.Hide();
begin
  getForm().Hide();
end;

function TWMPFRM.getInfo(): TInfo;
begin
  Result := self.finfo;
end;

function TWMPFRM.getBass(): TFilter;
begin
  Result := self.fbass;
end;

function TWMPFRM.getTreble(): TFilter;
begin
  Result := self.ftrbl;
end;

procedure TWMPFRM.Create();
begin
  with (TForm.Create(Application)) do begin
    Font.Size := 8;
    Caption := 'Enhancer';
    Top := 120;
    Left := 215;
    Width := 450;
    Height := 250;
    BorderIcons := [biSystemMenu];
    BorderStyle := bsSingle;
    Position := poMainFormCenter;
    ShowHint := True;
    Parent := nil;
    OnShow := self.FormShow;
    OnHide := self.FormHide;
  end;
  with (TTrackBar.Create(Application)) do begin
    Font.Size := 8;
    Orientation := trHorizontal;
    Tag := 10;
    Top := 0;
    Left := 0;
    Width := 450;
    Height := 20;
    Min := -200;
    Max := +200;
    Enabled := True;
    ShowHint := True;
    TickMarks := tmBoth;
    TickStyle := tsNone;
    Parent := getForm();
    OnChange := self.TrackBarSave;
  end;
  with (TTrackBar.Create(Application)) do begin
    Font.Size := 8;
    Orientation := trHorizontal;
    Tag := 11;
    Top := 25;
    Left := 0;
    Width := 450;
    Height := 20;
    Min := 5;
    Max := 50;
    Enabled := True;
    ShowHint := True;
    TickMarks := tmBoth;
    TickStyle := tsNone;
    Parent := getForm();
    OnChange := self.TrackBarSave;
  end;
  with (TTrackBar.Create(Application)) do begin
    Font.Size := 8;
    Orientation := trHorizontal;
    Tag := 12;
    Top := 50;
    Left := 0;
    Width := 450;
    Height := 20;
    Min := 50;
    Max := 500;
    Enabled := True;
    ShowHint := True;
    TickMarks := tmBoth;
    TickStyle := tsNone;
    Parent := getForm();
    OnChange := self.TrackBarSave;
  end;
  with (TTrackBar.Create(Application)) do begin
    Font.Size := 8;
    Orientation := trHorizontal;
    Tag := 20;
    Top := 100;
    Left := 0;
    Width := 450;
    Height := 20;
    Min := -200;
    Max := +200;
    Enabled := True;
    ShowHint := True;
    TickMarks := tmBoth;
    TickStyle := tsNone;
    Parent := getForm();
    OnChange := self.TrackBarSave;
  end;
  with (TTrackBar.Create(Application)) do begin
    Font.Size := 8;
    Orientation := trHorizontal;
    Tag := 21;
    Top := 125;
    Left := 0;
    Width := 450;
    Height := 20;
    Min := 5;
    Max := 150;
    Enabled := True;
    ShowHint := True;
    TickMarks := tmBoth;
    TickStyle := tsNone;
    Parent := getForm();
    OnChange := self.TrackBarSave;
  end;
  with (TTrackBar.Create(Application)) do begin
    Font.Size := 8;
    Orientation := trHorizontal;
    Tag := 22;
    Top := 150;
    Left := 0;
    Width := 450;
    Height := 20;
    Min := 50;
    Max := 500;
    Enabled := True;
    ShowHint := True;
    TickMarks := tmBoth;
    TickStyle := tsNone;
    Parent := getForm();
    OnChange := self.TrackBarSave;
  end;
end;

procedure TWMPFRM.Destroy();
begin
  getForm().Close();
  getForm().Destroy();
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
      if (Tag = 10) then begin
        Position := Round(self.fbass.Amp * 10.0);
        Hint := Format('Amp: %f', [self.fbass.Amp]);
      end;
      if (Tag = 11) then begin
        Position := Round(self.fbass.Freq / 10.0);
        Hint := Format('Freq: %f Hz', [self.fbass.Freq]);
      end;
      if (Tag = 12) then begin
        Position := Round(self.fbass.Width * 100.0);
        Hint := Format('Width: %f', [self.fbass.Width]);
      end;
      if (Tag = 20) then begin
        Position := Round(self.ftrbl.Amp * 10.0);
        Hint := Format('Amp: %f', [self.ftrbl.Amp]);
      end;
      if (Tag = 21) then begin
        Position := Round(self.ftrbl.Freq / 100.0);
        Hint := Format('Freq: %f Hz', [self.ftrbl.Freq]);
      end;
      if (Tag = 22) then begin
        Position := Round(self.ftrbl.Width * 100.0);
        Hint := Format('Width: %f', [self.ftrbl.Width]);
      end;
    end;
  end;
end;

procedure TWMPFRM.TrackBarSave(Sender: TObject);
begin
  if (Sender is TTrackBar) then begin
    with (Sender as TTrackBar) do begin
      if (Tag = 10) then begin
        self.fbass.Amp := Position / 10.0;
        Hint := Format('Amp: %f', [self.fbass.Amp]);
      end;
      if (Tag = 11) then begin
        self.fbass.Freq := Position * 10.0;
        Hint := Format('Freq: %f Hz', [self.fbass.Freq]);
      end;
      if (Tag = 12) then begin
        self.fbass.Width := Position / 100.0;
        Hint := Format('Width: %f', [self.fbass.Width]);
      end;
      if (Tag = 20) then begin
        self.ftrbl.Amp := Position / 10.0;
        Hint := Format('Amp: %f', [self.ftrbl.Amp]);
      end;
      if (Tag = 21) then begin
        self.ftrbl.Freq := Position * 100.0;
        Hint := Format('Freq: %f Hz', [self.ftrbl.Freq]);
      end;
      if (Tag = 22) then begin
        self.ftrbl.Width := Position / 100.0;
        Hint := Format('Width: %f', [self.ftrbl.Width]);
      end;
    end;
  end;
end;

begin
end.
