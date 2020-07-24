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
    constructor Create(); virtual;
    destructor Destroy(); override;
    procedure FormMainProcess(const Sender: TObject);
    procedure ControlsProcess(const Sender: TObject);
  end;

var
  CFGForm: TWMPDSPForm;

implementation

uses
  WMPDSPEqz;

{$R *.dfm}

constructor TWMPDSPForm.Create();
begin
  inherited Create(nil);
end;

destructor TWMPDSPForm.Destroy();
begin
  inherited Destroy();
end;

procedure TWMPDSPForm.FormMainProcess(const Sender: TObject);
var
  i: Integer;
begin
  self.ActiveControl := nil;
  for i := 0 to self.ControlCount - 1 do begin
    if((self.Controls[i] = self.Controls[i])) then begin
      if((self.Controls[i] is TCheckBox)) then begin
        if(((self.Controls[i] as TCheckBox).Tag = 99)) then begin
          (self.Controls[i] as TCheckBox).Checked := DSPEqz.Info.enabled;
        end                               else begin
          (self.Controls[i] as TCheckBox).Checked := DSPEqz.Info.enabled;
        end;
        (self.Controls[i] as TCheckBox).Hint := Format('Enabled: %s', [BoolToStr((self.Controls[i] as TCheckBox).Checked, True)]);
      end;
      if((self.Controls[i] is TTrackBar)) then begin
        if(((self.Controls[i] as TTrackBar).Tag = 99)) then begin
          (self.Controls[i] as TTrackBar).Position := (self.Controls[i] as TTrackBar).Max - DSPEqz.Info.preamp                                     + (self.Controls[i] as TTrackBar).Min;
        end                               else begin
          (self.Controls[i] as TTrackBar).Position := (self.Controls[i] as TTrackBar).Max - DSPEqz.Info.bands[(self.Controls[i] as TTrackBar).Tag] + (self.Controls[i] as TTrackBar).Min;
        end;
        (self.Controls[i] as TTrackBar).Hint := Format('Gain: %s dB', [FloatToStr(((self.Controls[i] as TTrackBar).Max - (self.Controls[i] as TTrackBar).Position + (self.Controls[i] as TTrackBar).Min) / 10)]);
      end;
    end;
  end;
end;

procedure TWMPDSPForm.ControlsProcess(const Sender: TObject);
var
  i: Integer;
begin
  self.ActiveControl := nil;
  for i := 0 to self.ControlCount - 1 do begin
    if((self.Controls[i] = Sender)) then begin
      if((self.Controls[i] is TCheckBox)) then begin
        if(((self.Controls[i] as TCheckBox).Tag = 99)) then begin
          DSPEqz.Info.enabled := (self.Controls[i] as TCheckBox).Checked;
        end                               else begin
          DSPEqz.Info.enabled := (self.Controls[i] as TCheckBox).Checked;
        end;
        (self.Controls[i] as TCheckBox).Hint := Format('Enabled: %s', [BoolToStr((self.Controls[i] as TCheckBox).Checked, True)]);
      end;
      if((self.Controls[i] is TTrackBar)) then begin
        if(((self.Controls[i] as TTrackBar).Tag = 99)) then begin
          DSPEqz.Info.preamp                                     := (self.Controls[i] as TTrackBar).Max - (self.Controls[i] as TTrackBar).Position + (self.Controls[i] as TTrackBar).Min;
        end                               else begin
          DSPEqz.Info.bands[(self.Controls[i] as TTrackBar).Tag] := (self.Controls[i] as TTrackBar).Max - (self.Controls[i] as TTrackBar).Position + (self.Controls[i] as TTrackBar).Min;
        end;
        (self.Controls[i] as TTrackBar).Hint := Format('Gain: %s dB', [FloatToStr(((self.Controls[i] as TTrackBar).Max - (self.Controls[i] as TTrackBar).Position + (self.Controls[i] as TTrackBar).Min) / 10)]);
      end;
    end;
  end;
end;

begin
end.
