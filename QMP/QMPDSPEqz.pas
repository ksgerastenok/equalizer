unit
  QMPDSPEqz;

interface

uses
  BQFilter,
  QMPDSPDecl,
  QMPDSPPlug;

type
  TFilters = array[0..4, 0..9] of TBQFilter;

type
  TQMPDSPEqz = class(TQMPDSPPlug)
  private
    feqz: TFilters;
  public
    constructor Create(); override;
    destructor Destroy(); override;
    procedure Process(const Data: Pointer; const Samples: LongWord; const Bits: LongWord; const Channels: LongWord; const Rates: LongWord); override;
  end;

var
  DSPEqz: TQMPDSPEqz;

implementation

uses
  Math;

constructor TQMPDSPEqz.Create();
var
  k: LongWord;
  i: LongWord;
begin
  inherited Create();
  for k := 0 to Length(self.feqz) - 1 do begin
    for i := 0 to Length(self.feqz[k]) - 1 do begin
      self.feqz[k, i] := TBQFilter.Create();
    end;
  end;
end;

destructor TQMPDSPEqz.Destroy();
var
  k: LongWord;
  i: LongWord;
begin
  for k := 0 to Length(self.feqz) - 1 do begin
    for i := 0 to Length(self.feqz[k]) - 1 do begin
      self.feqz[k, i].Destroy();
    end;
  end;
  inherited Destroy();
end;

procedure TQMPDSPEqz.Process(const Data: Pointer; const Samples: LongWord; const Bits: LongWord; const Channels: LongWord; const Rates: LongWord);
var
  k: LongWord;
  i: LongWord;
  x: LongWord;
begin
  inherited Process(Data, Samples, Bits, Channels, Rates);
  for k := 0 to Channels - 1 do begin
    for i := 0 to Length(self.feqz[k]) - 1 do begin
      self.feqz[k, i].Gain := Power(10, ((self.Info.preamp + self.Info.bands[i]) / 10) / 20);
      self.feqz[k, i].Band := btOctave;
      self.feqz[k, i].Filter := ftEqu;
      self.feqz[k, i].Enabled := self.Info.enabled;
      self.feqz[k, i].Width := 1.0;
      self.feqz[k, i].Freq := 35 * Power(2, self.feqz[k, i].Width * i);
      self.feqz[k, i].Rate := Rates;
      for x := 0 to Samples - 1 do begin
        self.Samples[x, k] := self.feqz[k, i].Process(self.Samples[x, k]);
      end;
    end;
  end;
end;

begin
end.
