unit
  QMPDSPPlug;

interface

uses
  QMPDSPDecl;

type
  TQMPDSPPlug = class(TObject)
  private
    finfo: PEQInfo;
    fdata: PWriteData;
    function getInfo(): PEQInfo;
    function getSamples(const Sample: LongWord; const Channel: LongWord): Double;
    procedure setSamples(const Sample: LongWord; const Channel: LongWord; const Value: Double);
  public
    constructor Create(); virtual;
    destructor Destroy(); override;
    procedure Process(const Data: Pointer; const Samples: LongWord; const Bits: LongWord; const Channels: LongWord; const Rates: LongWord); virtual;
    property Info: PEQInfo read getInfo;
    property Samples[const Sample: LongWord; const Channel: LongWord]: Double read getSamples write setSamples;
  end;

implementation

constructor TQMPDSPPlug.Create();
begin
  inherited Create();
  New(self.finfo);
  New(self.fdata);
end;

destructor TQMPDSPPlug.Destroy();
begin
  Dispose(self.fdata);
  Dispose(self.finfo);
  inherited Destroy();
end;

procedure TQMPDSPPlug.Process(const Data: Pointer; const Samples: LongWord; const Bits: LongWord; const Channels: LongWord; const Rates: LongWord);
begin
  self.fdata.data := Data;
  self.fdata.bits := Bits;
  self.fdata.rates := Rates;
  self.fdata.samples := Samples;
  self.fdata.channels := Channels;
end;

function TQMPDSPPlug.getInfo(): PEQInfo;
begin
  Result := self.finfo;
end;

function TQMPDSPPlug.getSamples(const Sample: LongWord; const Channel: LongWord): Double;
var
  x: Double;
  p: Pointer;
begin
  if((Sample < self.fdata.samples) and (Channel < self.fdata.channels)) then begin
    p := Pointer(LongWord(self.fdata.data) + ((self.fdata.bits div 8) * (Channel + Sample * self.fdata.channels)));
    case (self.fdata.bits div 8) of
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
        x := 0 / $00007FFF;
      end;
    end;
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

procedure TQMPDSPPlug.setSamples(const Sample: LongWord; const Channel: LongWord; const Value: Double);
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
  if((Sample < self.fdata.samples) and (Channel < self.fdata.channels)) then begin
    p := Pointer(LongWord(self.fdata.data) + ((self.fdata.bits div 8) * (Channel + Sample * self.fdata.channels)));
    case (self.fdata.bits div 8) of
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
        SmallInt(p^) := Round(0 * $00007FFF);
      end;
    end;
  end;
end;

begin
end.
