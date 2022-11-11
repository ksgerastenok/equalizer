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
    function getData(): TData;
    function getSamples(const Sample: LongWord; const Channel: LongWord): Double;
    procedure setSamples(const Sample: LongWord; const Channel: LongWord; const Value: Double);
  public
    procedure Init(const Data: PData);
    procedure Done();
    property Data: TData read getData;
    property Samples[const Sample: LongWord; const Channel: LongWord]: Double read getSamples write setSamples;
  end;

implementation

procedure TQMPDSP.Init(const Data: PData);
begin
  self.fdata.Data := Data.Data;
  self.fdata.Bits := Data.Bits;
  self.fdata.Rates := Data.Rates;
  self.fdata.Start := Data.Start;
  self.fdata.Finish := Data.Finish;
  self.fdata.Length := Data.Length;
  self.fdata.Samples := Data.Samples;
  self.fdata.Channels := Data.Channels;
end;

procedure TQMPDSP.Done();
begin
  self.fdata.Data := 0;
  self.fdata.Bits := 0;
  self.fdata.Rates := 0;
  self.fdata.Start := 0;
  self.fdata.Finish := 0;
  self.fdata.Length := 0;
  self.fdata.Samples := 0;
  self.fdata.Channels := 0;
end;

function TQMPDSP.clip(const Value: Double): Double;
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

function TQMPDSP.getData(): TData;
begin
  Result := self.fdata;
end;

function TQMPDSP.getSamples(const Sample: LongWord; const Channel: LongWord): Double;
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

procedure TQMPDSP.setSamples(const Sample: LongWord; const Channel: LongWord; const Value: Double);
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
