unit
  WMPRNG;

interface

type
  PWMPRNG = ^TWMPRNG;
  TWMPRNG = record
  private
    var fdata: array of Double;
    var fcurr: Integer;
    procedure addSample(const Value: Double);
    function getAvg(): Double;
    procedure setScale(const Value: Double);
  public
    procedure Init(const Size: Integer);
    procedure Done();
    function getSample(const Value: Double): Double;
  end;

implementation

procedure TWMPRNG.Init(const Size: Integer);
var
  i: Integer;
begin
  self.fcurr := -1;
  SetLength(self.fdata, Size);
  for i := 0 to Length(self.fdata) - 1 do begin
    self.fdata[i] := 1.0;
  end;
end;

procedure TWMPRNG.Done();
var
  i: Integer;
begin
  self.fcurr := -1;
  SetLength(self.fdata, 0);
  for i := 0 to Length(self.fdata) - 1 do begin
    self.fdata[i] := 1.0;
  end;
end;

procedure TWMPRNG.addSample(const Value: Double);
begin
  self.fcurr := (self.fcurr + 1) mod Length(self.fdata);
  self.fdata[self.fcurr] := Value;
end;

function TWMPRNG.getAvg(): Double;
var
  i: Integer;
begin
  Result := 0.0;
  for i := 0 to Length(self.fdata) - 1 do begin
    Result := Result + (self.fdata[i] - Result) / (i + 1);
  end;
end;

procedure TWMPRNG.setScale(const Value: Double);
var
  i: Integer;
begin
  for i := 0 to Length(self.fdata) - 1 do begin
    self.fdata[i] := self.fdata[i] * Value;
  end;
end;

function TWMPRNG.getSample(const Value: Double): Double;
begin
  self.addSample(Value);
  if (Value / self.getAvg() < 0.50) then begin
    self.setScale(0.95);
  end;
  Result := self.getAvg();
end;

begin
end.
