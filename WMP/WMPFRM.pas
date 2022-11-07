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
    var finfo: PInfo;
    var fform: TForm;
    procedure Create();
    procedure Destroy();
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
    procedure Init(const Info: PInfo);
    procedure Done();
    procedure Show();
    procedure Hide();
  end;

implementation

uses
  Math,
  StrUtils,
  Interfaces;

procedure TWMPFRM.Init(const Info: PInfo);
var
  f: file;
begin
  self.finfo := Info;
  self.Create();
  try
    Assign(f, 'equalizer.cfg');
    ReSet(f, 1);
    BlockRead(f, self.finfo^, SizeOf(TInfo) * 1);
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
    BlockWrite(f, self.finfo^, SizeOf(TInfo) * 1);
    Close(f);
  except
  end;
  self.Destroy();
  self.finfo := nil;
end;

procedure TWMPFRM.Show();
begin
  self.fform.Show();
end;

procedure TWMPFRM.Hide();
begin
  self.fform.Hide();
end;

procedure TWMPFRM.Create();
var
  i: Integer;
begin
  Application.Initialize();
  self.CreateForm(120, 215, 600, 285, 'Equalizer');
  self.CreateCheckBox(260, 5, 80, 20, 'Enabled');
  self.CreateTrackBar(5, 10, 20, 255, 99);
  self.CreateStaticText(245, 30, 45, 20, '-20 dB');
  self.CreateStaticText(125, 35, 45, 20, '0 dB');
  self.CreateStaticText(5, 30, 45, 20, '+20 dB');
  for i := 0 to Length(self.finfo.Bands) - 1 do begin
    self.CreateTrackBar(5, 75 + 25 * i, 20, 255, i);
    self.CreateStaticText(265, 70 + 25 * i, 30, 20, IfThen(20 * Power(2, 0.5 * i) < 1000, Format('%4.0f ', [20 * Power(2, 0.5 * i) / 1]), Format('%4.1fk', [20 * Power(2, 0.5 * i) / 1000])));
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
  Application.Initialize();
end;

procedure TWMPFRM.CreateForm(const NewTop, NewLeft, NewWidth, NewHeight: Integer; const NewCaption: String);
begin
  self.fform := TForm.Create(Application);
  with (self.fform as TForm) do begin
    Font.Size := 8;
    Caption := NewCaption;
    Top := NewTop;
    Left := NewLeft;
    Width := NewWidth;
    Height := NewHeight;
    BorderIcons := [biSystemMenu];
    BorderStyle := bsSingle;
    Position := poMainFormCenter;
    ShowHint := True;
    OnShow := self.FormShow;
    OnHide := self.FormHide;
  end;
end;

procedure TWMPFRM.CreateStaticText(const NewTop, NewLeft, NewWidth, NewHeight: Integer; const NewCaption: String);
begin
  self.fform.InsertControl(TStaticText.Create(Application));
  with (self.fform.Controls[self.fform.ControlCount - 1] as TStaticText) do begin
    Font.Size := 8;
    Caption := NewCaption;
    Top := NewTop;
    Left := NewLeft;
    Width := NewWidth;
    Height := NewHeight;
    ShowHint := True;
  end;
end;

procedure TWMPFRM.CreateTrackBar(const NewTop, NewLeft, NewWidth, NewHeight: Integer; const NewTag: Integer);
begin
  self.fform.InsertControl(TTrackBar.Create(Application));
  with (self.fform.Controls[self.fform.ControlCount - 1] as TTrackBar) do begin
    Font.Size := 8;
    Orientation := trVertical;
    Tag := NewTag;
    Top := NewTop;
    Left := NewLeft;
    Width := NewWidth;
    Height := NewHeight;
    Min := -200;
    Position := 0;
    Max := 200;
    ShowHint := True;
    TickMarks := tmBoth;
    TickStyle := tsNone;
    OnChange := self.TrackBarSave;
  end;
end;

procedure TWMPFRM.CreateCheckBox(const NewTop, NewLeft, NewWidth, NewHeight: Integer; const NewCaption: String);
begin
  self.fform.InsertControl(TCheckBox.Create(Application));
  with (self.fform.Controls[self.fform.ControlCount - 1] as TCheckBox) do begin
    Font.Size := 8;
    Caption := NewCaption;
    Top := NewTop;
    Left := NewLeft;
    Width := NewWidth;
    Height := NewHeight;
    ShowHint := True;
    OnClick := self.CheckBoxSave;
  end;
end;

procedure TWMPFRM.TrackBarLoad(Sender: TObject);
begin
  with (Sender as TTrackBar) do begin
    if (Tag = 99) then begin
      Position := Max - self.finfo.Preamp     + Min;
    end           else begin
      Position := Max - self.finfo.Bands[Tag] + Min;
    end;
    Hint := Format('Gain: %f dB', [(Max - Position + Min) / 10]);
  end;
end;

procedure TWMPFRM.TrackBarSave(Sender: TObject);
begin
  with (Sender as TTrackBar) do begin
    if (Tag = 99) then begin
      self.finfo.Preamp     := Max - Position + Min;
    end           else begin
      self.finfo.Bands[Tag] := Max - Position + Min;
    end;
    Hint := Format('Gain: %f dB', [(Max - Position + Min) / 10]);
  end;
end;

procedure TWMPFRM.CheckBoxLoad(Sender: TObject);
begin
  with (Sender as TCheckBox) do begin
    if (Tag = 99) then begin
      Checked := self.finfo.Enabled;
    end           else begin
      Checked := self.finfo.Enabled;
    end;
    Hint := Format('Enabled: %s', [Checked.ToString(TUseBoolStrs.True)]);
  end;
end;

procedure TWMPFRM.CheckBoxSave(Sender: TObject);
begin
  with (Sender as TCheckBox) do begin
    if (Tag = 99) then begin
      self.finfo.Enabled := Checked;
    end           else begin
      self.finfo.Enabled := Checked;
    end;
    Hint := Format('Enabled: %s', [Checked.ToString(TUseBoolStrs.True)]);
  end;
end;

procedure TWMPFRM.FormShow(Sender: TObject);
var
  i: Integer;
begin
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

procedure TWMPFRM.FormHide(Sender: TObject);
var
  i: Integer;
begin
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

begin
end.
