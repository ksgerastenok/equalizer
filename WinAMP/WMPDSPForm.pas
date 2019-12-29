unit
  WMPDSPForm;

interface

uses
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
    procedure FormMainProcess(const Sender: TObject);
    procedure CheckBoxProcess(const Sender: TObject);
    procedure TrackBarProcess(const Sender: TObject);
  end;

var
  CFGForm: TWMPDSPForm;

implementation

uses
  WMPDSPEqz;

{$R *.dfm}

procedure TWMPDSPForm.FormMainProcess(const Sender: TObject);
begin
  self.ActiveControl := nil;
  self.tbPreamp.Position := self.tbPreamp.Max - DSPEqz.Info.preamp + self.tbPreamp.Min;
  self.tbBand00.Position := self.tbBand00.Max - DSPEqz.Info.bands[00] + self.tbBand00.Min;
  self.tbBand01.Position := self.tbBand01.Max - DSPEqz.Info.bands[01] + self.tbBand01.Min;
  self.tbBand02.Position := self.tbBand02.Max - DSPEqz.Info.bands[02] + self.tbBand02.Min;
  self.tbBand03.Position := self.tbBand03.Max - DSPEqz.Info.bands[03] + self.tbBand03.Min;
  self.tbBand04.Position := self.tbBand04.Max - DSPEqz.Info.bands[04] + self.tbBand04.Min;
  self.tbBand05.Position := self.tbBand05.Max - DSPEqz.Info.bands[05] + self.tbBand05.Min;
  self.tbBand06.Position := self.tbBand06.Max - DSPEqz.Info.bands[06] + self.tbBand06.Min;
  self.tbBand07.Position := self.tbBand07.Max - DSPEqz.Info.bands[07] + self.tbBand07.Min;
  self.tbBand08.Position := self.tbBand08.Max - DSPEqz.Info.bands[08] + self.tbBand08.Min;
  self.tbBand09.Position := self.tbBand09.Max - DSPEqz.Info.bands[09] + self.tbBand09.Min;
  self.tbBand10.Position := self.tbBand10.Max - DSPEqz.Info.bands[10] + self.tbBand10.Min;
  self.tbBand11.Position := self.tbBand11.Max - DSPEqz.Info.bands[11] + self.tbBand11.Min;
  self.tbBand12.Position := self.tbBand12.Max - DSPEqz.Info.bands[12] + self.tbBand12.Min;
  self.tbBand13.Position := self.tbBand13.Max - DSPEqz.Info.bands[13] + self.tbBand13.Min;
  self.tbBand14.Position := self.tbBand14.Max - DSPEqz.Info.bands[14] + self.tbBand14.Min;
  self.tbBand15.Position := self.tbBand15.Max - DSPEqz.Info.bands[15] + self.tbBand15.Min;
  self.tbBand16.Position := self.tbBand16.Max - DSPEqz.Info.bands[16] + self.tbBand16.Min;
  self.tbBand17.Position := self.tbBand17.Max - DSPEqz.Info.bands[17] + self.tbBand17.Min;
  self.tbBand18.Position := self.tbBand18.Max - DSPEqz.Info.bands[18] + self.tbBand18.Min;
  self.cbEnabled.Checked := DSPEqz.Info.enabled;
end;

procedure TWMPDSPForm.CheckBoxProcess(const Sender: TObject);
begin
  self.ActiveControl := nil;
  if(((Sender as TCheckBox).Tag = 99)) then begin
    DSPEqz.Info.enabled := (Sender as TCheckBox).Checked;
    (Sender as TCheckBox).Hint := Format('Enabled: %s', [BoolToStr(DSPEqz.Info.enabled, True)]);
  end                                  else begin
    DSPEqz.Info.enabled := (Sender as TCheckBox).Checked;
    (Sender as TCheckBox).Hint := Format('Enabled: %s', [BoolToStr(DSPEqz.Info.enabled, True)]);
  end;
end;

procedure TWMPDSPForm.TrackBarProcess(const Sender: TObject);
begin
  self.ActiveControl := nil;
  if(((Sender as TTrackBar).Tag = 99)) then begin
    DSPEqz.Info.preamp := (Sender as TTrackBar).Max - (Sender as TTrackBar).Position + (Sender as TTrackBar).Min;
    (Sender as TTrackBar).Hint := Format('Gain: %s dB', [FloatToStr(DSPEqz.Info.preamp / 10)]);
  end                                  else begin
    DSPEqz.Info.bands[(Sender as TTrackBar).Tag] := (Sender as TTrackBar).Max - (Sender as TTrackBar).Position + (Sender as TTrackBar).Min;
    (Sender as TTrackBar).Hint := Format('Gain: %s dB', [FloatToStr(DSPEqz.Info.bands[(Sender as TTrackBar).Tag] / 10)]);
  end;
end;

begin
end.
