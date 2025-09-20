unit
  QMPRNG;

interface

type
  PQMPRNG = ^TQMPRNG;
  TQMPRNG = record
  private
    var fvalue: Double;
    var fcount: Integer;
  public
    procedure Init();
    procedure Done();
    procedure addSample(const Value: Double);
    function getAvg(): Double;
  end;

implementation

procedure TQMPRNG.Init();
begin
  self.fcount := 0;
  self.fvalue := 0.0;
end;

procedure TQMPRNG.Done();
begin
  self.fcount := 0;
  self.fvalue := 0.0;
end;

procedure TQMPRNG.addSample(const Value: Double);
begin
  self.fcount := self.fcount + 1;
  self.fvalue := self.fvalue + (Sqr(Value) - self.fvalue) / self.fcount;;
end;

function TQMPRNG.getAvg(): Double;
begin
  Result := Sqrt(self.fvalue);
end;

begin
end.
