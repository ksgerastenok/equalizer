unit
  QMPDSP;

interface

uses
  QMPDCL;

type
  PQMPDSP = ^TQMPDSP;
  TQMPDSP = record
  private
    class function getSamples(const Data: PData; const Sample: Integer; const Channel: Integer): Double; static;
    class procedure setSamples(const Data: PData; const Sample: Integer; const Channel: Integer; const Value: Double); static;
  public
    class property Samples[const Data: PData; const Sample: Integer; const Channel: Integer]: Double read getSamples write setSamples;
  end;

implementation

class function TQMPDSP.getSamples(const Data: PData; const Sample: Integer; const Channel: Integer): Double;
var
  x: Double;
  p: Pointer;
begin
  if((Sample < Data.Samples) and (Channel < Data.Channels)) then begin
    p := Pointer(Integer(Data.Data) + ((Data.Bits div 8) * (Channel + Sample * Data.Channels)));
  end                                                       else begin
    p := nil;
  end;
  try
    case (Data.Bits div 8) of
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

class procedure TQMPDSP.setSamples(const Data: PData; const Sample: Integer; const Channel: Integer; const Value: Double);
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
  if((Sample < Data.Samples) and (Channel < Data.Channels)) then begin
    p := Pointer(Integer(Data.Data) + ((Data.Bits div 8) * (Channel + Sample * Data.Channels)));
  end                                                       else begin
    p := nil;
  end;
  try
    case (Data.Bits div 8) of
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

begin
end.
