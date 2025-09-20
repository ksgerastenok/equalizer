unit
  WMPRNG;

interface

type
  PWMPRNG = ^TWMPRNG;
  TWMPRNG = record
  private
    var fvalue: Double;
    var fcount: LongWord;
  public
    procedure Init();
    procedure Done();
    procedure addSample(const Value: Double);
    function getAvg(): Double;
  end;

implementation

procedure TWMPRNG.Init();
begin
  self.fcount := 0;
  self.fvalue := 0.0;
end;

procedure TWMPRNG.Done();
begin
  self.fcount := 0;
  self.fvalue := 0.0;
end;

procedure TWMPRNG.addSample(const Value: Double);
begin
  self.fcount := self.fcount + 1;
  self.fvalue := self.fvalue + (Sqr(Value) - self.fvalue) / self.fcount;
end;

function TWMPRNG.getAvg(): Double;
begin
  Result := Sqrt(self.fvalue);
end;

begin
end.
