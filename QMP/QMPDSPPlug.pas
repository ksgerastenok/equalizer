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
    function getData(): PWriteData;
    function getSamples(const Channel: LongWord; const Sample: LongWord): Double;
    procedure setSamples(const Channel: LongWord; const Sample: LongWord; const Value: Double);
  public
    constructor Create(); virtual;
    destructor Destroy(); virtual;
    procedure Process(); virtual; abstract;
    property Info: PEQInfo read getInfo;
    property Data: PWriteData read getData;
    property Samples[const Channel: LongWord; const Sample: LongWord]: Double read getSamples write setSamples;
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

function TQMPDSPPlug.getInfo(): PEQInfo;
begin
  Result := self.finfo;
end;

function TQMPDSPPlug.getData(): PWriteData;
begin
  Result := self.fdata;
end;

function TQMPDSPPlug.getSamples(const Channel: LongWord; const Sample: LongWord): Double;
var
  x: Double;
  p: Pointer;
begin
  p := Pointer(LongWord(self.fdata.data) + ((self.fdata.bps div 8) * (Channel + Sample * self.fdata.nch)));
  case (self.fdata.bps div 8) of
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
  if((x <= -1.0)) then begin
    x := -1.0;
  end;
  if((x = 0)) then begin
    x := 0.0;
  end;
  if((x >= +1.0)) then begin
    x := +1.0;
  end;
  Result := x;
end;

procedure TQMPDSPPlug.setSamples(const Channel: LongWord; const Sample: LongWord; const Value: Double);
var
  x: Double;
  p: Pointer;
begin
  x := Value;
  if((x <= -1.0)) then begin
    x := -1.0;
  end;
  if((x = 0)) then begin
    x := 0.0;
  end;
  if((x >= +1.0)) then begin
    x := +1.0;
  end;
  p := Pointer(LongWord(self.fdata.data) + ((self.fdata.bps div 8) * (Channel + Sample * self.fdata.nch)));
  case (self.fdata.bps div 8) of
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
end;

begin
end.
