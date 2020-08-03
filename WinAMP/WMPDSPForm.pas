unit
  WMPDSPForm;

interface

uses
  XPMan,
  Forms,
  Classes,
  Controls,
  ComCtrls,
  StdCtrls,
  SysUtils;

type
  TWMPDSPForm = class(TForm)
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
  end;

var
  CFGForm: TWMPDSPForm;

implementation

uses
  WMPDSPMod,
  WMPDSPDecl;

{$R *.dfm}

procedure TWMPDSPForm.ControlsLoad(const Sender: TObject);
begin
  self.ActiveControl := nil;
  if((Sender is TCheckBox)) then begin
    if(((Sender as TCheckBox).Tag = 99)) then begin
      (Sender as TCheckBox).Checked := DSPMod.Info.Enabled;
      (Sender as TCheckBox).Hint := Format('Enabled: %s', [BoolToStr((Sender as TCheckBox).Checked, True)]);
    end                                  else begin
      (Sender as TCheckBox).Checked := DSPMod.Info.Enabled;
      (Sender as TCheckBox).Hint := Format('Enabled: %s', [BoolToStr((Sender as TCheckBox).Checked, True)]);
    end;
  end;
  if((Sender is TTrackBar)) then begin
    if(((Sender as TTrackBar).Tag = 99)) then begin
      (Sender as TTrackBar).Position := (Sender as TTrackBar).Max - DSPMod.Info.Preamp                           + (Sender as TTrackBar).Min;
      (Sender as TTrackBar).Hint := Format('Gain: %s dB', [FloatToStr(((Sender as TTrackBar).Max - (Sender as TTrackBar).Position + (Sender as TTrackBar).Min) / 10)]);
    end                                  else begin
      (Sender as TTrackBar).Position := (Sender as TTrackBar).Max - DSPMod.Info.Bands[(Sender as TTrackBar).Tag] + (Sender as TTrackBar).Min;
      (Sender as TTrackBar).Hint := Format('Gain: %s dB', [FloatToStr(((Sender as TTrackBar).Max - (Sender as TTrackBar).Position + (Sender as TTrackBar).Min) / 10)]);
    end;
  end;
end;

procedure TWMPDSPForm.ControlsSave(const Sender: TObject);
begin
  self.ActiveControl := nil;
  if((Sender is TCheckBox)) then begin
    if(((Sender as TCheckBox).Tag = 99)) then begin
      DSPMod.Info.Enabled := (Sender as TCheckBox).Checked;
      (Sender as TCheckBox).Hint := Format('Enabled: %s', [BoolToStr((Sender as TCheckBox).Checked, True)]);
    end                                  else begin
      DSPMod.Info.Enabled := (Sender as TCheckBox).Checked;
      (Sender as TCheckBox).Hint := Format('Enabled: %s', [BoolToStr((Sender as TCheckBox).Checked, True)]);
    end;
  end;
  if((Sender is TTrackBar)) then begin
    if(((Sender as TTrackBar).Tag = 99)) then begin
      DSPMod.Info.Preamp                           := (Sender as TTrackBar).Max - (Sender as TTrackBar).Position + (Sender as TTrackBar).Min;
      (Sender as TTrackBar).Hint := Format('Gain: %s dB', [FloatToStr(((Sender as TTrackBar).Max - (Sender as TTrackBar).Position + (Sender as TTrackBar).Min) / 10)]);
    end                                  else begin
      DSPMod.Info.Bands[(Sender as TTrackBar).Tag] := (Sender as TTrackBar).Max - (Sender as TTrackBar).Position + (Sender as TTrackBar).Min;
      (Sender as TTrackBar).Hint := Format('Gain: %s dB', [FloatToStr(((Sender as TTrackBar).Max - (Sender as TTrackBar).Position + (Sender as TTrackBar).Min) / 10)]);
    end;
  end;
end;

procedure TWMPDSPForm.FormMainCreate(const Sender: TObject);
var
  f: file;
  i: LongWord;
begin
  try
    System.Assign(f, 'equalizer.cfg');
    System.ReSet(f, 1);
    System.BlockRead(f, DSPMod.Info^, SizeOf(TEQInfo) * 1);
    System.Close(f);
  except
    DSPMod.Info.Preamp := 0;
    DSPMod.Info.Enabled := False;
    for i := 0 to Length(DSPMod.Info.Bands) - 1 do begin
      DSPMod.Info.Bands[i] := 0;
    end;
  end;
end;

procedure TWMPDSPForm.FormMainDestroy(const Sender: TObject);
var
  f: file;
  i: LongWord;
begin
  try
    System.Assign(f, 'equalizer.cfg');
    System.ReWrite(f, 1);
    System.BlockWrite(f, DSPMod.Info^, SizeOf(TEQInfo) * 1);
    System.Close(f);
  except
    DSPMod.Info.Preamp := 0;
    DSPMod.Info.Enabled := False;
    for i := 0 to Length(DSPMod.Info.Bands) - 1 do begin
      DSPMod.Info.Bands[i] := 0;
    end;
  end;
end;

procedure TWMPDSPForm.FormMainShow(const Sender: TObject);
var
  i: LongWord;
begin
  for i := 0 to self.ControlCount - 1 do begin
    self.ControlsLoad(self.Controls[i]);
  end;
end;

procedure TWMPDSPForm.FormMainHide(const Sender: TObject);
var
  i: LongWord;
begin
  for i := 0 to self.ControlCount - 1 do begin
    self.ControlsSave(self.Controls[i]);
  end;
end;

initialization
  CFGForm := TWMPDSPForm.Create(Screen.Owner);

finalization
  CFGForm.Destroy();

end.
