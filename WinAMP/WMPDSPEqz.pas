unit
  WMPDSPEqz;

interface

uses
  BQFilter,
  WMPDSPDecl,
  WMPDSPPlug;

type
  TFilters = array[0..4, 0..18] of TBQFilter;

type
  TWMPDSPEqz = class(TWMPDSPPlug)
  private
    feqz: TFilters;
    finfo: PEQInfo;
    function getInfo(): PEQInfo;
  public
    constructor Create(); override;
    destructor Destroy(); override;
    procedure Process(); override;
    property Info: PEQInfo read getInfo;
  end;

var
  DSPEqz: TWMPDSPEqz;

implementation

uses
  Math;

constructor TWMPDSPEqz.Create();
var
  f: file;
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
  try
    System.Assign(f, 'equalizer.cfg');
    System.ReSet(f, 1);
    System.BlockRead(f, self.Info^, SizeOf(TEQInfo) * 1);
    System.Close(f);
  except
    self.Info.preamp := 0;
    self.Info.enabled := False;
    for i := 0 to Length(self.Info.bands) - 1 do begin
      self.Info.bands[i] := 0;
    end;
  end;
end;

destructor TWMPDSPEqz.Destroy();
var
  f: file;
  k: LongWord;
  i: LongWord;
begin
  try
    System.Assign(f, 'equalizer.cfg');
    System.ReWrite(f, 1);
    System.BlockWrite(f, self.Info^, SizeOf(TEQInfo) * 1);
    System.Close(f);
  except
    self.Info.preamp := 0;
    self.Info.enabled := False;
    for i := 0 to Length(self.Info.bands) - 1 do begin
      self.Info.bands[i] := 0;
    end;
  end;
  for k := 0 to Length(self.feqz) - 1 do begin
    for i := 0 to Length(self.feqz[k]) - 1 do begin
      self.feqz[k, i].Destroy();
    end;
  end;
  Dispose(self.finfo);
  inherited Destroy();
end;

function TWMPDSPEqz.getInfo(): PEQInfo;
begin
  Result := self.finfo;
end;

procedure TWMPDSPEqz.Process();
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

begin
end.
