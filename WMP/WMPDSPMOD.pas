unit
  WMPDSPMOD;

interface

uses
  WMPDSPBQF,
  WMPDSPPLG,
  WMPDSPDCL;

type
  TWMPDSPMOD = class(TWMPDSPPLG)
  private
    feqz: array[0..4, 0..18] of TWMPDSPBQF;
    finfo: PEQInfo;
    function getInfo(): PEQInfo;
    constructor Create();
  public
    class function Instance(): TWMPDSPMod;
    destructor Destroy(); override;
    procedure Process(); override;
    property Info: PEQInfo read getInfo;
  end;

implementation

uses
  Math;

var
  DSPMod: TWMPDSPMOD;

class function TWMPDSPMOD.Instance(): TWMPDSPMod;
begin
  Result := DSPMod;
end;

constructor TWMPDSPMOD.Create();
var
  k: LongWord;
  i: LongWord;
begin
  inherited Create();
  self.finfo := New(PEQInfo);
  for k := 0 to Length(self.feqz) - 1 do begin
    for i := 0 to Length(self.feqz[k]) - 1 do begin
      self.feqz[k, i] := TWMPDSPBQF.Create(ftEqu, btOctave, gtDb);
    end;
  end;
end;

destructor TWMPDSPMOD.Destroy();
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

function TWMPDSPMOD.getInfo(): PEQInfo;
begin
  Result := self.finfo;
end;

procedure TWMPDSPMOD.Process();
var
  k: LongWord;
  i: LongWord;
  x: LongWord;
begin
  for k := 0 to self.Data.Channels - 1 do begin
    for i := 0 to Length(self.Info.Bands) - 1 do begin
      self.feqz[k, i].Amp := (self.Info.Preamp + self.Info.Bands[i]) / 10;
      self.feqz[k, i].Freq := 35 * Power(2, 0.5 * i);
      self.feqz[k, i].Rate := self.Data.Rates;
      self.feqz[k, i].Width := 0.5;
      self.feqz[k, i].Enabled := self.Info.Enabled;
      for x := 0 to self.Data.Samples - 1 do begin
        self.Samples[x, k] := self.feqz[k, i].Process(self.Samples[x, k]);
      end;
    end;
  end;
end;

initialization
  DSPMod := TWMPDSPMOD.Create();

finalization
  DSPMod.Destroy();

end.
