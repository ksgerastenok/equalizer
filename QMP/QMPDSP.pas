unit
  QMPDSP;

interface

uses
  QMPDCL;

type
  TQMPDSP = record
  private
    var fdata: TData;
    function clip(const Value: Double): Double;
    function getData(const Channel: LongWord; const Sample: LongWord): Double;
    procedure setData(const Channel: LongWord; const Sample: LongWord; const Value: Double);
  public
    procedure Init(const Data: PData);
    procedure Done();
    property Data[const Channel: LongWord; const Sample: LongWord]: Double read getData write setData;
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

function TQMPDSP.getData(const Channel: LongWord; const Sample: LongWord): Double;
begin
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
      Result := self.clip(PShortInt(self.fdata.Data)[Channel + Sample * self.fdata.Channels] / $0000007F);
    end;
  end;
end;

procedure TQMPDSP.setData(const Channel: LongWord; const Sample: LongWord; const Value: Double);
begin
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
      PShortInt(self.fdata.Data)[Channel + Sample * self.fdata.Channels] := Round(self.clip(Value) * $0000007F);
    end;
  end;
end;

begin
end.
