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
    var favg: Double;
    var fsqr: Double;
    var famp: Double;
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
  self.favg := 0.0;
  self.fsqr := 0.0;
  self.famp := 0.0;
  self.fcount := 0;
  self.flimit := 10.0;
end;

procedure TQMPRNG.Done();
begin
  self.fgain := self.fgain;
  self.favg := 0.0;
  self.fsqr := 0.0;
  self.famp := 0.0;
  self.fcount := 0;
  self.flimit := 10.0;
end;

procedure TQMPRNG.addSample(const Value: Double);
begin
  self.fcount := Min(Max(1, self.fcount + 1), 250000);
  self.fsqr := Sqrt((1 - 1 / self.fcount) * (Sqr(self.fsqr) + Sqr(Abs(Value) - self.favg) / self.fcount));
  self.favg := self.favg + (Abs(Value) - self.favg) / self.fcount;
  self.famp := Min(Max(1.0, 1.0 / (1.75 * (self.favg + self.fsqr))), self.flimit);
end;

function TQMPRNG.getValue(): Double;
begin
  case (self.fgain) of
    rngDb: begin
      Result := 20 * Log10(self.famp);
    end;
    rngAmp: begin
      Result := self.famp;
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
  Result := self.famp * Value;
end;

begin
end.
