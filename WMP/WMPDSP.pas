unit
  WMPDSP;

interface

uses
  WMPDCL;

type
  PWMPDSP = ^TWMPDSP;
  TWMPDSP = record
  private
    var fdata: PData;
    function clip(const Value: Double): Double;
    function getSamples(const Sample: LongWord; const Channel: LongWord): Double;
    procedure setSamples(const Sample: LongWord; const Channel: LongWord; const Value: Double);
  public
    procedure Init(const Data: PData);
    procedure Done();
    property Samples[const Sample: LongWord; const Channel: LongWord]: Double read getSamples write setSamples;
  end;

implementation

procedure TWMPDSP.Init(const Data: PData);
begin
  self.fdata := Data;
end;

procedure TWMPDSP.Done();
begin
  self.fdata := nil;
end;

function TWMPDSP.clip(const Value: Double): Double;
begin
  Result := Value;
  if (Result < -1.0) then begin
    Result := -1.0;
  end;
  if (Result = 0.0) then begin
    Result := 0.0;
  end;
  if (Result > +1.0) then begin
    Result := +1.0;
  end;
end;

function TWMPDSP.getSamples(const Sample: LongWord; const Channel: LongWord): Double;
begin
  try
    case (self.fdata.Bits) of
      8: begin
        Result := self.clip(PShortInt(self.fdata.Data)[Channel + Sample * self.fdata.Channels] / $0000007F);
      end;
      16: begin
        Result := self.clip(PSmallInt(self.fdata.Data)[Channel + Sample * self.fdata.Channels] / $00007FFF);
      end;
      32: begin
        Result := self.clip(PLongInt(self.fdata.Data)[Channel + Sample * self.fdata.Channels] / $7FFFFFFF);
      end;
      else begin
      end;
    end;
  except
  end;
end;

procedure TWMPDSP.setSamples(const Sample: LongWord; const Channel: LongWord; const Value: Double);
begin
  try
    case (self.fdata.Bits) of
      8: begin
        PShortInt(self.fdata.Data)[Channel + Sample * self.fdata.Channels] := Round(self.clip(Value) * $0000007F);
      end;
      16: begin
        PSmallInt(self.fdata.Data)[Channel + Sample * self.fdata.Channels] := Round(self.clip(Value) * $00007FFF);
      end;
      32: begin
        PLongInt(self.fdata.Data)[Channel + Sample * self.fdata.Channels] := Round(self.clip(Value) * $7FFFFFFF);
      end;
      else begin
      end;
    end;
  except
  end;
end;

begin
end.
