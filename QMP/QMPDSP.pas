unit
  QMPDSP;

interface

uses
  QMPDCL;

type
  PQMPDSP = ^TQMPDSP;
  TQMPDSP = record
  private
    var fdata: TData;
    function clip(const Value: Double): Double;
    function getBuffer(const Sample: LongWord; const Channel: LongWord): Double;
    procedure setBuffer(const Sample: LongWord; const Channel: LongWord; const Value: Double);
  public
    procedure Init(const Data: PData);
    procedure Done();
    property Buffer[const Sample: LongWord; const Channel: LongWord]: Double read getBuffer write setBuffer;
  end;

implementation

uses
  Math;

procedure TQMPDSP.Init(const Data: PData);
begin
  self.fdata.Data := Data.Data;
  self.fdata.Bits := Data.Bits;
  self.fdata.Rates := Data.Rates;
  self.fdata.Samples := Data.Samples;
  self.fdata.Channels := Data.Channels;
end;

procedure TQMPDSP.Done();
begin
end;

function TQMPDSP.clip(const Value: Double): Double;
begin
  Result := Min(Max(-1.0, Value), +1.0);
end;

function TQMPDSP.getBuffer(const Sample: LongWord; const Channel: LongWord): Double;
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

procedure TQMPDSP.setBuffer(const Sample: LongWord; const Channel: LongWord; const Value: Double);
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
