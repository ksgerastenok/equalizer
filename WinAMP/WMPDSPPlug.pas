unit
  WMPDSPPlug;

interface

uses
  WMPDSPDecl;

type
  TWMPDSPPlug = class(TObject)
  private
    fdata: PWriteData;
    function getData(): PWriteData;
    function getSamples(const Sample: LongWord; const Channel: LongWord): Double;
    procedure setSamples(const Sample: LongWord; const Channel: LongWord; const Value: Double);
  public
    constructor Create(); virtual;
    destructor Destroy(); override;
    procedure Process(); virtual; abstract;
    property Data: PWriteData read getData;
    property Samples[const Sample: LongWord; const Channel: LongWord]: Double read getSamples write setSamples;
  end;

implementation

constructor TWMPDSPPlug.Create();
begin
  inherited Create();
  New(self.fdata);
end;

destructor TWMPDSPPlug.Destroy();
begin
  Dispose(self.fdata);
  inherited Destroy();
end;

function TWMPDSPPlug.getData(): PWriteData;
begin
  Result := self.fdata;
end;

function TWMPDSPPlug.getSamples(const Sample: LongWord; const Channel: LongWord): Double;
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

procedure TWMPDSPPlug.setSamples(const Sample: LongWord; const Channel: LongWord; const Value: Double);
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
  end;
end;

initialization

finalization

end.
