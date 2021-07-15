unit
  WMPDSPMod;

interface

uses
  BQFilter,
  WMPDSPDecl;

type
  TWMPDSPMod = class(TObject)
  private
    feqz: array[0..4, 0..18] of TBQFilter;
    finfo: PEQInfo;
    fdata: PWriteData;
    function getInfo(): PEQInfo;
    function getData(): PWriteData;
    function getSamples(const Sample: LongWord; const Channel: LongWord): Double;
    procedure setSamples(const Sample: LongWord; const Channel: LongWord; const Value: Double);
    property Samples[const Sample: LongWord; const Channel: LongWord]: Double read getSamples write setSamples;
  public
    constructor Create(); virtual;
    destructor Destroy(); override;
    procedure Process();
    property Info: PEQInfo read getInfo;
    property Data: PWriteData read getData;
  end;

implementation

uses
  Math;

constructor TWMPDSPMod.Create();
var
  k: LongWord;
  i: LongWord;
begin
  inherited Create();
  self.finfo := New(PEQInfo);
  self.fdata := New(PWriteData);
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
  Dispose(self.fdata);
  Dispose(self.finfo);
  inherited Destroy();
end;

function TWMPDSPMod.getInfo(): PEQInfo;
begin
  Result := self.finfo;
end;

function TWMPDSPMod.getData(): PWriteData;
begin
  Result := self.fdata;
end;

function TWMPDSPMod.getSamples(const Sample: LongWord; const Channel: LongWord): Double;
var
  x: Double;
  p: Pointer;
begin
  if((Sample < self.Data.Samples) and (Channel < self.Data.Channels)) then begin
    p := Pointer(LongWord(self.Data.Data) + ((self.Data.Bits div 8) * (Channel + Sample * self.Data.Channels)));
  end                                                                 else begin
    p := nil;
  end;
  try
    case (self.Data.Bits div 8) of
      1: begin
        x := ShortInt(p^) / $0000007F;
      end;
      2: begin
        x := SmallInt(p^) / $00007FFF;
      end;
      4: begin
        x := LongInt(p^) / $7FFFFFFF;
      end;
      else begin
        x := 0;
      end;
    end;
  except
    x := 0;
  end;
  if((x < -1.0)) then begin
    x := -1.0;
  end;
  if((x = 0.0)) then begin
    x := 0.0;
  end;
  if((x > +1.0)) then begin
    x := +1.0;
  end;
  Result := x;
end;

procedure TWMPDSPMod.setSamples(const Sample: LongWord; const Channel: LongWord; const Value: Double);
var
  x: Double;
  p: Pointer;
begin
  x := Value;
  if((x < -1.0)) then begin
    x := -1.0;
  end;
  if((x = 0.0)) then begin
    x := 0.0;
  end;
  if((x > +1.0)) then begin
    x := +1.0;
  end;
  if((Sample < self.Data.Samples) and (Channel < self.Data.Channels)) then begin
    p := Pointer(LongWord(self.Data.Data) + ((self.Data.Bits div 8) * (Channel + Sample * self.Data.Channels)));
  end                                                                 else begin
    p := nil;
  end;
  try
    case (self.Data.Bits div 8) of
      1: begin
        ShortInt(p^) := Round(x * $0000007F);
      end;
      2: begin
        SmallInt(p^) := Round(x * $00007FFF);
      end;
      4: begin
        LongInt(p^) := Round(x * $7FFFFFFF);
      end;
      else begin
        SmallInt(p^) := 0;
      end;
    end;
  except
    SmallInt(p^) := 0;
  end;
end;

procedure TWMPDSPMod.Process();
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

begin
end.
