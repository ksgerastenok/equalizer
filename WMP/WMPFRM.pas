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
    procedure CreateAll();
    procedure DestroyAll();
    procedure CreateForm(const NewTop, NewLeft, NewWidth, NewHeight: Integer; const NewCaption: String);
    procedure CreateTrackBar(const NewTop, NewLeft, NewWidth, NewHeight: Integer; const NewTag: Integer);
    procedure CreateCheckBox(const NewTop, NewLeft, NewWidth, NewHeight: Integer; const NewCaption: String);
    procedure CreateStaticText(const NewTop, NewLeft, NewWidth, NewHeight: Integer; const NewCaption: String);
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
  self.CreateAll();
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
  self.DestroyAll();
  self.finfo := nil;
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

procedure TWMPFRM.CreateAll();
var
  i: Integer;
begin
  self.CreateForm(120, 215, 710, 285, 'Equalizer');
  self.CreateCheckBox(260, 5, 80, 20, 'Enabled');
  self.CreateTrackBar(5, 5, 25, 255, 99);
  self.CreateStaticText(240, 30, 40, 20, '-20 dB');
  self.CreateStaticText(120, 40, 40, 20, '0 dB');
  self.CreateStaticText(5, 30, 40, 20, '+20 dB');
  for i := 0 to Length(self.finfo^.Bands) - 1 do begin
    if((20 * Power(2, 0.5 * i) < 1000)) then begin
      self.CreateStaticText(265, 80 + 30 * i, 30, 20, Format('%4.0f ', [20 * Power(2, 0.5 * i) / 1]));
    end                                 else begin
      self.CreateStaticText(265, 80 + 30 * i, 30, 20, Format('%4.1fk', [20 * Power(2, 0.5 * i) / 1000]));
    end;
    self.CreateTrackBar(5, 85 + 30 * i, 25, 255, i);
  end;
end;

procedure TWMPFRM.DestroyAll();
var
  i: Integer;
begin
  self.fform.Close();
  for i := 0 to self.fform.ControlCount - 1 do begin
    self.fform.Controls[i].Destroy();
  end;
  self.fform.Destroy();
end;

procedure TWMPFRM.CreateForm(const NewTop, NewLeft, NewWidth, NewHeight: Integer; const NewCaption: String);
begin
  self.fform := TForm.Create(Application);
  with((self.fform)) do begin
    Caption := NewCaption;
    Top := NewTop;
    Left := NewLeft;
    Width := NewWidth;
    Height := NewHeight;
    Font.Size := 8;
    BorderIcons := [biSystemMenu];
    BorderStyle := bsSingle;
    Position := poMainFormCenter;
    ShowHint := True;
    Parent := nil;
    OnShow := @self.FormShow;
    OnHide := @self.FormHide;
  end;
end;

procedure TWMPFRM.CreateStaticText(const NewTop, NewLeft, NewWidth, NewHeight: Integer; const NewCaption: String);
begin
  with((TStaticText.Create(Application))) do begin
    Caption := NewCaption;
    Top := NewTop;
    Left := NewLeft;
    Width := NewWidth;
    Height := NewHeight;
    Font.Size := 8;
    Parent := self.fform;
  end;
end;

procedure TWMPFRM.CreateTrackBar(const NewTop, NewLeft, NewWidth, NewHeight: Integer; const NewTag: Integer);
begin
  with((TTrackBar.Create(Application))) do begin
    Orientation := trVertical;
    Tag := NewTag;
    Top := NewTop;
    Left := NewLeft;
    Width := NewWidth;
    Height := NewHeight;
    Font.Size := 8;
    Min := -200;
    Position := 0;
    Max := 200;
    ShowHint := True;
    TickMarks := tmBoth;
    TickStyle := tsNone;
    Parent := self.fform;
    OnChange := @self.TrackBarSave;
  end;
end;

procedure TWMPFRM.CreateCheckBox(const NewTop, NewLeft, NewWidth, NewHeight: Integer; const NewCaption: String);
begin
  with((TCheckBox.Create(Application))) do begin
    Caption := NewCaption;
    Top := NewTop;
    Left := NewLeft;
    Width := NewWidth;
    Height := NewHeight;
    Font.Size := 8;
    Parent := self.fform;
    OnClick := @self.CheckBoxSave;
  end;
end;

procedure TWMPFRM.TrackBarLoad(Sender: TObject);
begin
  with((Sender as TTrackBar)) do begin
    if((Tag = 99)) then begin
      Position := Max - self.finfo^.Preamp     + Min;
    end            else begin
      Position := Max - self.finfo^.Bands[Tag] + Min;
    end;
    Hint := Format('Gain: %f dB', [(Max - Position + Min) / 10]);
  end;
end;

procedure TWMPFRM.TrackBarSave(Sender: TObject);
begin
  with((Sender as TTrackBar)) do begin
    if((Tag = 99)) then begin
      self.finfo^.Preamp     := Max - Position + Min;
    end            else begin
      self.finfo^.Bands[Tag] := Max - Position + Min;
    end;
    Hint := Format('Gain: %f dB', [(Max - Position + Min) / 10]);
  end;
end;

procedure TWMPFRM.CheckBoxLoad(Sender: TObject);
begin
  with((Sender as TCheckBox)) do begin
    if((Tag = 99)) then begin
      Checked := self.finfo^.Enabled;
    end            else begin
      Checked := self.finfo^.Enabled;
    end;
    Hint := Format('Enabled: %s', [Checked.ToString(TUseBoolStrs.True)]);
  end;
end;

procedure TWMPFRM.CheckBoxSave(Sender: TObject);
begin
  with((Sender as TCheckBox)) do begin
    if((Tag = 99)) then begin
      self.finfo^.Enabled := Checked;
    end            else begin
      self.finfo^.Enabled := Checked;
    end;
    Hint := Format('Enabled: %s', [Checked.ToString(TUseBoolStrs.True)]);
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
