unit
  QMPRNG;

interface

type
  TGain = (rngDb, rngAmp);

type
  PQMPRNG = ^TQMPRNG;
  TQMPRNG = record
  private
    var fgain: TGain;
    var fvalue: Double;
    var flimit: Double;
    var fcount: Integer;
    procedure addSample(const Value: Double);
    function getValue(): Double;
    function getLimit(): Double;
    procedure setLimit(const Value: Double);
  public
    procedure Init(const Gain: TGain);
    procedure Done();
    function Process(const Value: Double): Double;
    property Value: Double read getValue;
    property Limit: Double read getLimit write setLimit;
  end;

implementation

uses
  Math;

procedure TQMPRNG.Init(const Gain: TGain);
begin
  self.fgain := Gain;
  self.fcount := 0;
  self.fvalue := 1.0;
  self.flimit := 10.0;
end;

procedure TQMPRNG.Done();
begin
  self.fcount := 0;
  self.fvalue := 1.0;
  self.flimit := 10.0;
end;

procedure TQMPRNG.addSample(const Value: Double);
begin
  self.fcount := self.fcount + 1;
  self.fvalue := self.fvalue / Sqrt(1.0 + (Sqr(3.5 * self.fvalue * Value) - 1.0) / self.fcount);
  self.fvalue := Min(Max(self.fvalue, 1.0), self.flimit);
end;

function TQMPRNG.getValue(): Double;
begin
  case (self.fgain) of
    rngDb: begin
      Result := 20 * Log10(self.fvalue);
    end;
    rngAmp: begin
      Result := self.fvalue;
    end;
    else begin
      Result := 0.0;
    end;
  end;
end;

function TQMPRNG.getLimit(): Double;
begin
  case (self.fgain) of
    rngDb: begin
      Result := 20 * Log10(self.flimit);
    end;
    rngAmp: begin
      Result := self.flimit;
    end;
    else begin
      Result := 0.0;
    end;
  end;
end;

procedure TQMPRNG.setLimit(const Value: Double);
begin
  case (self.fgain) of
    rngDb: begin
      self.flimit := Power(10, Value / 20);
    end;
    rngAmp: begin
      self.flimit := Value;
    end;
    else begin
      self.flimit := 0.0;
    end;
  end;
end;

function TQMPRNG.Process(const Value: Double): Double;
begin
  self.addSample(Value);
  Result := Value * self.fvalue;
end;

begin
end.
