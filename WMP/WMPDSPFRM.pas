unit
  WMPDSPFRM;

interface

uses
  Forms,
  Classes,
  Controls,
  ComCtrls,
  StdCtrls,
  SysUtils;

type
  TWMPDSPFRM = class(TForm)
  published
    { Published declarations }
    tbPreamp: TTrackBar;
    tbBand00: TTrackBar;
    tbBand01: TTrackBar;
    tbBand02: TTrackBar;
    tbBand03: TTrackBar;
    tbBand04: TTrackBar;
    tbBand05: TTrackBar;
    tbBand06: TTrackBar;
    tbBand07: TTrackBar;
    tbBand08: TTrackBar;
    tbBand09: TTrackBar;
    tbBand10: TTrackBar;
    tbBand11: TTrackBar;
    tbBand12: TTrackBar;
    tbBand13: TTrackBar;
    tbBand14: TTrackBar;
    tbBand15: TTrackBar;
    tbBand16: TTrackBar;
    tbBand17: TTrackBar;
    tbBand18: TTrackBar;
    cbEnabled: TCheckBox;
    stBand00: TStaticText;
    stBand01: TStaticText;
    stBand02: TStaticText;
    stBand03: TStaticText;
    stBand04: TStaticText;
    stBand05: TStaticText;
    stBand06: TStaticText;
    stBand07: TStaticText;
    stBand08: TStaticText;
    stBand09: TStaticText;
    stBand10: TStaticText;
    stBand11: TStaticText;
    stBand12: TStaticText;
    stBand13: TStaticText;
    stBand14: TStaticText;
    stBand15: TStaticText;
    stBand16: TStaticText;
    stBand17: TStaticText;
    stBand18: TStaticText;
    stLowValue: TStaticText;
    stZeroValue: TStaticText;
    stHighValue: TStaticText;
    procedure ControlsLoad(const Sender: TObject);
    procedure ControlsSave(const Sender: TObject);
    procedure FormMainShow(const Sender: TObject);
    procedure FormMainHide(const Sender: TObject);
    procedure FormMainCreate(const Sender: TObject);
    procedure FormMainDestroy(const Sender: TObject);
  public
    class function Instance(): TWMPDSPFRM;
  end;

implementation

uses
  WMPDSPMOD,
  WMPDSPDCL;

{$R *.dfm}

var
  CFGFrm: TWMPDSPFRM;

class function TWMPDSPFRM.Instance(): TWMPDSPFRM;
begin
  Result := CFGFrm;
end;

procedure TWMPDSPFRM.ControlsLoad(const Sender: TObject);
begin
  self.ActiveControl := nil;
  if((Sender is TCheckBox)) then begin
    if(((Sender as TCheckBox).Tag = 99)) then begin
      (Sender as TCheckBox).Checked := TWMPDSPMOD.Instance().Info.Enabled;
      (Sender as TCheckBox).Hint := Format('Enabled: %s', [BoolToStr((Sender as TCheckBox).Checked, True)]);
    end                                  else begin
      (Sender as TCheckBox).Checked := TWMPDSPMOD.Instance().Info.Enabled;
      (Sender as TCheckBox).Hint := Format('Enabled: %s', [BoolToStr((Sender as TCheckBox).Checked, True)]);
    end;
  end;
  if((Sender is TTrackBar)) then begin
    if(((Sender as TTrackBar).Tag = 99)) then begin
      (Sender as TTrackBar).Position := (Sender as TTrackBar).Max - TWMPDSPMOD.Instance().Info.Preamp                           + (Sender as TTrackBar).Min;
      (Sender as TTrackBar).Hint := Format('Gain: %s dB', [FloatToStr(((Sender as TTrackBar).Max - (Sender as TTrackBar).Position + (Sender as TTrackBar).Min) / 10)]);
    end                                  else begin
      (Sender as TTrackBar).Position := (Sender as TTrackBar).Max - TWMPDSPMOD.Instance().Info.Bands[(Sender as TTrackBar).Tag] + (Sender as TTrackBar).Min;
      (Sender as TTrackBar).Hint := Format('Gain: %s dB', [FloatToStr(((Sender as TTrackBar).Max - (Sender as TTrackBar).Position + (Sender as TTrackBar).Min) / 10)]);
    end;
  end;
end;

procedure TWMPDSPFRM.ControlsSave(const Sender: TObject);
begin
  self.ActiveControl := nil;
  if((Sender is TCheckBox)) then begin
    if(((Sender as TCheckBox).Tag = 99)) then begin
      TWMPDSPMOD.Instance().Info.Enabled := (Sender as TCheckBox).Checked;
      (Sender as TCheckBox).Hint := Format('Enabled: %s', [BoolToStr((Sender as TCheckBox).Checked, True)]);
    end                                  else begin
      TWMPDSPMOD.Instance().Info.Enabled := (Sender as TCheckBox).Checked;
      (Sender as TCheckBox).Hint := Format('Enabled: %s', [BoolToStr((Sender as TCheckBox).Checked, True)]);
    end;
  end;
  if((Sender is TTrackBar)) then begin
    if(((Sender as TTrackBar).Tag = 99)) then begin
      TWMPDSPMOD.Instance().Info.Preamp                           := (Sender as TTrackBar).Max - (Sender as TTrackBar).Position + (Sender as TTrackBar).Min;
      (Sender as TTrackBar).Hint := Format('Gain: %s dB', [FloatToStr(((Sender as TTrackBar).Max - (Sender as TTrackBar).Position + (Sender as TTrackBar).Min) / 10)]);
    end                                  else begin
      TWMPDSPMOD.Instance().Info.Bands[(Sender as TTrackBar).Tag] := (Sender as TTrackBar).Max - (Sender as TTrackBar).Position + (Sender as TTrackBar).Min;
      (Sender as TTrackBar).Hint := Format('Gain: %s dB', [FloatToStr(((Sender as TTrackBar).Max - (Sender as TTrackBar).Position + (Sender as TTrackBar).Min) / 10)]);
    end;
  end;
end;

procedure TWMPDSPFRM.FormMainCreate(const Sender: TObject);
var
  f: file;
  i: LongWord;
begin
  try
    System.Assign(f, 'equalizer.cfg');
    System.ReSet(f, 1);
    System.BlockRead(f, TWMPDSPMOD.Instance().Info^, SizeOf(TEQInfo) * 1);
    System.Close(f);
  except
    TWMPDSPMOD.Instance().Info.Preamp := 0;
    TWMPDSPMOD.Instance().Info.Enabled := False;
    for i := 0 to Length(TWMPDSPMOD.Instance().Info.Bands) - 1 do begin
      TWMPDSPMOD.Instance().Info.Bands[i] := 0;
    end;
  end;
end;

procedure TWMPDSPFRM.FormMainDestroy(const Sender: TObject);
var
  f: file;
  i: LongWord;
begin
  try
    System.Assign(f, 'equalizer.cfg');
    System.ReWrite(f, 1);
    System.BlockWrite(f, TWMPDSPMOD.Instance().Info^, SizeOf(TEQInfo) * 1);
    System.Close(f);
  except
    TWMPDSPMOD.Instance().Info.Preamp := 0;
    TWMPDSPMOD.Instance().Info.Enabled := False;
    for i := 0 to Length(TWMPDSPMOD.Instance().Info.Bands) - 1 do begin
      TWMPDSPMOD.Instance().Info.Bands[i] := 0;
    end;
  end;
end;

procedure TWMPDSPFRM.FormMainShow(const Sender: TObject);
var
  i: LongWord;
begin
  for i := 0 to self.ControlCount - 1 do begin
    self.ControlsLoad(self.Controls[i]);
  end;
end;

procedure TWMPDSPFRM.FormMainHide(const Sender: TObject);
var
  i: LongWord;
begin
  for i := 0 to self.ControlCount - 1 do begin
    self.ControlsSave(self.Controls[i]);
  end;
end;

initialization
  CFGFrm := TWMPDSPFRM.Create(Screen.Owner);

finalization
  CFGFrm.Destroy();

end.
