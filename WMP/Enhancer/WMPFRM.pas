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
  PFilter = ^TFilter;
  TFilter = record
    var Amp: Double;
    var Freq: Double;
    var Width: Double;
  end;

type
  PInfo = ^TInfo;
  TInfo = record
    var Enabled: Boolean;
    var Bass: TFilter;
    var Treble: TFilter;
  end;

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
  public
    procedure Init();
    procedure Done();
    procedure Show();
    procedure Hide();
    property Info: TInfo read getInfo;
  end;

implementation

uses
  SysUtils,
  Interfaces;

procedure TWMPFRM.Init();
begin
  Application.Initialize();
  self.Create();
  self.finfo.Enabled := True;
  self.finfo.Bass.Amp := 7.5;
  self.finfo.Bass.Freq := 110.0;
  self.finfo.Bass.Width := 2.5;
  self.finfo.Treble.Amp := 15.0;
  self.finfo.Treble.Freq := 2500.0;
  self.finfo.Treble.Width := 2.5;
end;

procedure TWMPFRM.Done();
begin
  self.finfo.Enabled := False;
  self.finfo.Bass.Amp := 0.0;
  self.finfo.Bass.Freq := 0.0;
  self.finfo.Bass.Width := 0.0;
  self.finfo.Treble.Amp := 0.0;
  self.finfo.Treble.Freq := 0.0;
  self.finfo.Treble.Width := 0.0;
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
  Result := nil;
  for i := 0 to Application.ComponentCount - 1 do begin
    if (Application.Components[i] is TForm) then begin
      Result := (Application.Components[i] as TForm);
    end;
  end;
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
    Parent := self.getForm();
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
    Parent := self.getForm();
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
    Parent := self.getForm();
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
    Parent := self.getForm();
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
    Parent := self.getForm();
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
    Parent := self.getForm();
    OnChange := self.TrackBarSave;
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
        Position := Round(self.finfo.Bass.Amp * 10.0);
        Hint := Format('Amp: %f', [self.finfo.Bass.Amp]);
      end;
      if (Tag = 11) then begin
        Position := Round(self.finfo.Bass.Freq / 10.0);
        Hint := Format('Freq: %f Hz', [self.finfo.Bass.Freq]);
      end;
      if (Tag = 12) then begin
        Position := Round(self.finfo.Bass.Width * 100.0);
        Hint := Format('Width: %f', [self.finfo.Bass.Width]);
      end;
      if (Tag = 20) then begin
        Position := Round(self.finfo.Treble.Amp * 10.0);
        Hint := Format('Amp: %f', [self.finfo.Treble.Amp]);
      end;
      if (Tag = 21) then begin
        Position := Round(self.finfo.Treble.Freq / 100.0);
        Hint := Format('Freq: %f Hz', [self.finfo.Treble.Freq]);
      end;
      if (Tag = 22) then begin
        Position := Round(self.finfo.Treble.Width * 100.0);
        Hint := Format('Width: %f', [self.finfo.Treble.Width]);
      end;
    end;
  end;
end;

procedure TWMPFRM.TrackBarSave(Sender: TObject);
begin
  if (Sender is TTrackBar) then begin
    with (Sender as TTrackBar) do begin
      if (Tag = 10) then begin
        self.finfo.Bass.Amp := Position / 10.0;
        Hint := Format('Amp: %f', [self.finfo.Bass.Amp]);
      end;
      if (Tag = 11) then begin
        self.finfo.Bass.Freq := Position * 10.0;
        Hint := Format('Freq: %f Hz', [self.finfo.Bass.Freq]);
      end;
      if (Tag = 12) then begin
        self.finfo.Bass.Width := Position / 100.0;
        Hint := Format('Width: %f', [self.finfo.Bass.Width]);
      end;
      if (Tag = 20) then begin
        self.finfo.Treble.Amp := Position / 10.0;
        Hint := Format('Amp: %f', [self.finfo.Treble.Amp]);
      end;
      if (Tag = 21) then begin
        self.finfo.Treble.Freq := Position * 100.0;
        Hint := Format('Freq: %f Hz', [self.finfo.Treble.Freq]);
      end;
      if (Tag = 22) then begin
        self.finfo.Treble.Width := Position / 100.0;
        Hint := Format('Width: %f', [self.finfo.Treble.Width]);
      end;
    end;
  end;
end;

begin
end.
