unit
  QMPRNG;

interface

type
  PQMPRNG = ^TQMPRNG;
  TQMPRNG = record
  private
    var fcnt: Integer;
    var fsqr: Double;
    var favg: Double;
    var fmax: Double;
    procedure addSample(const Value: Double);
    function getValue(): Double;
    function getLimit(): Double;
    procedure setLimit(const Value: Double);
  public
    procedure Init();
    procedure Done();
    function Process(const Value: Double): Double;
    property Value: Double read getValue;
    property Limit: Double read getLimit write setLimit;
  end;

implementation

uses
  Math;

procedure TQMPRNG.Init();
begin
  self.fcnt := 0;
  self.fsqr := 0.0;
  self.favg := 0.0;
  self.fmax := 10.0;
end;

procedure TQMPRNG.Done();
begin
  self.fcnt := 0;
  self.fsqr := 0.0;
  self.favg := 0.0;
  self.fmax := 10.0;
end;

procedure TQMPRNG.addSample(const Value: Double);
begin
  self.fcnt := Min(Max(1, self.fcnt + 1), 250000);
  self.fsqr := self.fsqr + (Sqr(Value) - self.fsqr) / self.fcnt;
  self.favg := self.favg + (Abs(Value) - self.favg) / self.fcnt;
end;

function TQMPRNG.getValue(): Double;
begin
  Result := Min(Max(1.0, 1.0 / (2.25 * (self.favg + Sqrt(self.fsqr - Sqr(self.favg))))), self.fmax);
end;

function TQMPRNG.getLimit(): Double;
begin
  Result := self.fmax;
end;

procedure TQMPRNG.setLimit(const Value: Double);
begin
  self.fmax := Value;
end;

function TQMPRNG.Process(const Value: Double): Double;
begin
  self.addSample(Value);
  Result := self.Value * Value;
end;

begin
end.
