unit
  WMPDSPPLG;

interface

uses
  WMPDSPDCL;

type
  TWMPDSPPLG = class(TObject)
  private
    fdata: PWriteData;
    function getData(): PWriteData;
    function getSamples(const Sample: LongWord; const Channel: LongWord): Double;
    procedure setSamples(const Sample: LongWord; const Channel: LongWord; const Value: Double);
  protected
    constructor Create();
    property Samples[const Sample: LongWord; const Channel: LongWord]: Double read getSamples write setSamples;
  public
    destructor Destroy(); override;
    procedure Process(); virtual; abstract;
    property Data: PWriteData read getData;
  end;

implementation

constructor TWMPDSPPLG.Create();
begin
  inherited Create();
  self.fdata := New(PWriteData);
end;

destructor TWMPDSPPLG.Destroy();
begin
  Dispose(self.fdata);
  inherited Destroy();
end;

function TWMPDSPPLG.getData(): PWriteData;
begin
  Result := self.fdata;
end;

function TWMPDSPPLG.getSamples(const Sample: LongWord; const Channel: LongWord): Double;
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
        x := 0.0;
      end;
    end;
  except
    x := 0.0;
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

procedure TWMPDSPPLG.setSamples(const Sample: LongWord; const Channel: LongWord; const Value: Double);
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
        SmallInt(p^) := Round(x * $00000000);
      end;
    end;
  except
    SmallInt(p^) := Round(x * $00000000);
  end;
end;

initialization

finalization

end.
