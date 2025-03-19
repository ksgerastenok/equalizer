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
    function clip(const Value: Double): Double;
    function getBuffer(const Sample: LongWord; const Channel: LongWord): Double;
    procedure setBuffer(const Sample: LongWord; const Channel: LongWord; const Value: Double);
  public
    procedure Init(const Data: Pointer; const Bits: LongWord; const Rates: LongWord; const Samples: LongWord; const Channels: LongWord);
    procedure Done();
    property Buffer[const Sample: LongWord; const Channel: LongWord]: Double read getBuffer write setBuffer;
  end;

implementation

uses
  Math;

procedure TWMPDSP.Init(const Data: Pointer; const Bits: LongWord; const Rates: LongWord; const Samples: LongWord; const Channels: LongWord);
begin
  self.fdata.Data := Data;
  self.fdata.Bits := Bits;
  self.fdata.Rates := Rates;
  self.fdata.Samples := Samples;
  self.fdata.Channels := Channels;
end;

procedure TWMPDSP.Done();
begin
end;

function TWMPDSP.clip(const Value: Double): Double;
begin
  Result := Min(Max(-1.0, Value), +1.0);
end;

function TWMPDSP.getBuffer(const Sample: LongWord; const Channel: LongWord): Double;
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
    end;
  except
  end;
end;

procedure TWMPDSP.setBuffer(const Sample: LongWord; const Channel: LongWord; const Value: Double);
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
    end;
  except
  end;
end;

begin
end.
