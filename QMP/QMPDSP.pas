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
    function Clip(const Value: Double): Double;
    function GetData(const Channel: LongWord; const Sample: LongWord): Double;
    procedure SetData(const Channel: LongWord; const Sample: LongWord; const Value: Double);
  public
    procedure Init(const Data: PData);
    procedure Done();
    property Data[const Channel: LongWord; const Sample: LongWord]: Double read GetData write SetData;
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

function TQMPDSP.Clip(const Value: Double): Double;
begin
  Result := Min(Max(-1.0, Value), +1.0);
end;

function TQMPDSP.GetData(const Channel: LongWord; const Sample: LongWord): Double;
begin
  case (self.fdata.Bits) of
    8: begin
      Result := self.Clip(PShortInt(self.fdata.Data)[Channel + Sample * self.fdata.Channels] / $0000007F);
    end;
    16: begin
      Result := self.Clip(PSmallInt(self.fdata.Data)[Channel + Sample * self.fdata.Channels] / $00007FFF);
    end;
    32: begin
      Result := self.Clip(PLongInt(self.fdata.Data)[Channel + Sample * self.fdata.Channels] / $7FFFFFFF);
    end;
  end;
end;

procedure TQMPDSP.SetData(const Channel: LongWord; const Sample: LongWord; const Value: Double);
begin
  case (self.fdata.Bits) of
    8: begin
      PShortInt(self.fdata.Data)[Channel + Sample * self.fdata.Channels] := Round(self.Clip(Value) * $0000007F);
    end;
    16: begin
      PSmallInt(self.fdata.Data)[Channel + Sample * self.fdata.Channels] := Round(self.Clip(Value) * $00007FFF);
    end;
    32: begin
      PLongInt(self.fdata.Data)[Channel + Sample * self.fdata.Channels] := Round(self.Clip(Value) * $7FFFFFFF);
    end;
  end;
end;

begin
end.
