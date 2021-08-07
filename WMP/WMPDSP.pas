unit
  WMPDSP;

interface

uses
  WMPDCL;

type
  PWMPDSP = ^TWMPDSP;
  TWMPDSP = record
  private
    var fdata: TData;
    var finfo: TInfo;
    function clip(const Value: Double): Double;
    function getData(): PData;
    function getInfo(): PInfo;
    function getSamples(const Sample: LongWord; const Channel: LongWord): Double;
    procedure setSamples(const Sample: LongWord; const Channel: LongWord; const Value: Double);
  public
    property Data: PData read getData;
    property Info: PInfo read getInfo;
    property Samples[const Sample: LongWord; const Channel: LongWord]: Double read getSamples write setSamples;
  end;

implementation

function TWMPDSP.getData(): PData;
begin
  Result := Addr(self.fdata);
end;

function TWMPDSP.getInfo(): PInfo;
begin
  Result := Addr(self.finfo);
end;

function TWMPDSP.clip(const Value: Double): Double;
begin
  Result := Value;
  if((Result < -1.0)) then begin
    Result := -1.0;
  end;
  if((Result = 0.0)) then begin
    Result := 0.0;
  end;
  if((Result > +1.0)) then begin
    Result := +1.0;
  end;
end;

function TWMPDSP.getSamples(const Sample: LongWord; const Channel: LongWord): Double;
begin
  try
    case (self.Data.Bits div 8) of
      1: begin
        Result := clip(PShortInt(self.Data.Data)[Channel + Sample * self.Data.Channels] / $0000007F);
      end;
      2: begin
        Result := clip(PSmallInt(self.Data.Data)[Channel + Sample * self.Data.Channels] / $00007FFF);
      end;
      4: begin
        Result := clip(PLongInt(self.Data.Data)[Channel + Sample * self.Data.Channels] / $7FFFFFFF);
      end;
      else begin
        Result := clip(0.0);
      end;
    end;
  except
    Result := clip(0.0);
  end;
end;

procedure TWMPDSP.setSamples(const Sample: LongWord; const Channel: LongWord; const Value: Double);
begin
  try
    case (self.Data.Bits div 8) of
      1: begin
        PShortInt(self.Data.Data)[Channel + Sample * self.Data.Channels] := Round(clip(Value) * $0000007F);
      end;
      2: begin
        PSmallInt(self.Data.Data)[Channel + Sample * self.Data.Channels] := Round(clip(Value) * $00007FFF);
      end;
      4: begin
        PLongInt(self.Data.Data)[Channel + Sample * self.Data.Channels] := Round(clip(Value) * $7FFFFFFF);
      end;
      else begin
        PSmallInt(self.Data.Data)[Channel + Sample * self.Data.Channels] := Round(clip(Value) * $00000000);
      end;
    end;
  except
    PSmallInt(self.Data.Data)[Channel + Sample * self.Data.Channels] := Round(clip(Value) * $00000000);
  end;
end;

begin
end.
