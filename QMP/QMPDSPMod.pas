unit
  QMPDSPMod;

interface

uses
  BQFilter,
  QMPDSPDecl,
  QMPDSPPlug;

type
  TQMPDSPMod = class(TQMPDSPPlug)
  private
    feqz: array[0..4, 0..9] of TBQFilter;
    finfo: PEQInfo;
    function getInfo(): PEQInfo;
  public
    constructor Create(); override;
    destructor Destroy(); override;
    procedure Process(); override;
    property Info: PEQInfo read getInfo;
  end;

var
  DSPMod: TQMPDSPMod;

implementation

uses
  Math;

constructor TQMPDSPMod.Create();
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

destructor TQMPDSPMod.Destroy();
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

function TQMPDSPMod.getInfo(): PEQInfo;
begin
  Result := self.finfo;
end;

procedure TQMPDSPMod.Process();
var
  k: LongWord;
  i: LongWord;
  x: LongWord;
begin
  for k := 0 to self.Data.Channels - 1 do begin
    for i := 0 to Length(self.Info.Bands) - 1 do begin
      self.feqz[k, i].Amp := (self.Info.Preamp + self.Info.Bands[i]) / 10;
      self.feqz[k, i].Freq := 35 * Power(2, 1.0 * i);
      self.feqz[k, i].Rate := self.Data.Rates;
      self.feqz[k, i].Width := 1.0;
      self.feqz[k, i].Enabled := self.Info.Enabled;
      for x := 0 to self.Data.Samples - 1 do begin
        self.Samples[x, k] := self.feqz[k, i].Process(self.Samples[x, k]);
      end;
    end;
  end;
end;

initialization
  DSPMod := TQMPDSPMod.Create();

finalization
  DSPMod.Destroy();

end.
