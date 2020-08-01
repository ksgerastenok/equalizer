unit
  WMPDSPMod;

interface

uses
  BQFilter,
  WMPDSPDecl,
  WMPDSPPlug;

type
  TWMPDSPMod = class(TWMPDSPPlug)
  private
    feqz: array[0..4, 0..18] of TBQFilter;
    finfo: PEQInfo;
    function getInfo(): PEQInfo;
  public
    constructor Create(); override;
    destructor Destroy(); override;
    procedure Process(); override;
    property Info: PEQInfo read getInfo;
  end;

var
  DSPMod: TWMPDSPMod;

implementation

uses
  Math;

constructor TWMPDSPMod.Create();
var
  k: LongWord;
  i: LongWord;
begin
  inherited Create();
  New(self.finfo);
  for k := 0 to Length(self.feqz) - 1 do begin
    for i := 0 to Length(self.feqz[k]) - 1 do begin
      self.feqz[k, i] := TBQFilter.Create(ftEqu, btOctave, gtDb);
    end;
  end;
end;

destructor TWMPDSPMod.Destroy();
var
  k: LongWord;
  i: LongWord;
begin
  for k := 0 to Length(self.feqz) - 1 do begin
    for i := 0 to Length(self.feqz[k]) - 1 do begin
      self.feqz[k, i].Destroy();
    end;
  end;
  Dispose(self.finfo);
  inherited Destroy();
end;

function TWMPDSPMod.getInfo(): PEQInfo;
begin
  Result := self.finfo;
end;

procedure TWMPDSPMod.Process();
var
  k: LongWord;
  i: LongWord;
  x: LongWord;
begin
  for k := 0 to self.Data.channels - 1 do begin
    for i := 0 to Length(self.Info.bands) - 1 do begin
      self.feqz[k, i].Amp := (self.Info.preamp + self.Info.bands[i]) / 10;
      self.feqz[k, i].Freq := 35 * Power(2, 0.5 * i);
      self.feqz[k, i].Rate := self.Data.rates;
      self.feqz[k, i].Width := 0.5;
      self.feqz[k, i].Enabled := self.Info.enabled;
      for x := 0 to self.Data.samples - 1 do begin
        self.Samples[x, k] := self.feqz[k, i].Process(self.Samples[x, k]);
      end;
    end;
  end;
end;

initialization
  DSPMod := TWMPDSPMod.Create();

finalization
  DSPMod.Destroy();

end.
