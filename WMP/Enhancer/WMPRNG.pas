unit
  WMPRNG;

interface

type
  PWMPRNG = ^TWMPRNG;
  TWMPRNG = record
  private
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
    property Limit: Double read getLimit write setLimit;
  end;

implementation

uses
  Math;

procedure TWMPRNG.Init();
begin
  self.fsqr := 0.0;
  self.favg := 0.0;
  self.fmax := 10.0;
end;

procedure TWMPRNG.Done();
begin
  self.fsqr := 0.0;
  self.favg := 0.0;
  self.fmax := 10.0;
end;

procedure TWMPRNG.addSample(const Value: Double);
begin
  self.fsqr := self.fsqr + (Sqr(Value) - self.fsqr) / IfThen(self.getValue() * Abs(Value) <= 1.0, 250000, 50000);
  self.favg := self.favg + (Abs(Value) - self.favg) / IfThen(self.getValue() * Abs(Value) <= 1.0, 250000, 50000);
end;

function TWMPRNG.getValue(): Double;
begin
  Result := Min(Max(1.0, 1.0 / (1.75 * (self.favg + Sqrt(self.fsqr - Sqr(self.favg))))), self.fmax);
end;

function TWMPRNG.getLimit(): Double;
begin
  Result := self.fmax;
end;

procedure TWMPRNG.setLimit(const Value: Double);
begin
  self.fmax := Value;
end;

function TWMPRNG.Process(const Value: Double): Double;
begin
  self.addSample(Value);
  Result := self.getValue();
end;

begin
end.
