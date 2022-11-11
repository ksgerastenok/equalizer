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
    procedure setData(const Value: TData);
    function getSamples(const Sample: LongWord; const Channel: LongWord): Double;
    procedure setSamples(const Sample: LongWord; const Channel: LongWord; const Value: Double);
  public
    procedure Init();
    procedure Done();
    property Data: TData read getData write setData;
    property Samples[const Sample: LongWord; const Channel: LongWord]: Double read getSamples write setSamples;
  end;

implementation

procedure TQMPDSP.Init();
begin
end;

procedure TQMPDSP.Done();
begin
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

procedure TQMPDSP.setData(const Value: TData);
begin
  self.fdata := Value;
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
