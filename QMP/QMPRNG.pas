unit
  QMPRNG;

interface

type
  PQMPRNG = ^TQMPRNG;
  TQMPRNG = record
  private
    var fvalue: Double;
    var flimit: Double;
    var fcount: Integer;
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
  if (isNan(self.fvalue)) then begin
    self.fvalue := 1.0;
  end;
  if (isInfinite(self.fvalue)) then begin
    self.fvalue := self.flimit;
  end;
end;

function TQMPRNG.getValue(): Double;
begin
  Result := Min(Max(self.fvalue, 1.0), self.flimit);
end;

function TQMPRNG.getLimit(): Double;
begin
  Result := self.flimit;
end;

procedure TQMPRNG.setLimit(const Value: Double);
begin
  self.flimit := Value;
end;

function TQMPRNG.Process(const Value: Double): Double;
begin
  self.addSample(Value);
  Result := Value * self.getValue();
end;

begin
end.
