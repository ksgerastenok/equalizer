unit
  QMPNRM;

interface

type
  TGain = (gtDb, gtAmp);

type
  TQMPNRM = record
  private
    var fgain: TGain;
    var famp: Double;
    var fval: Double;
    var frate: Double;
    var fattack: Double;
    var frelease: Double;
    function getGain(): TGain;
    function getVal(): Double;
    function getAmp(): Double;
    procedure setAmp(const Value: Double);
    function getRate(): Double;
    procedure setRate(const Value: Double);
    function getAttack(): Double;
    procedure setAttack(const Value: Double);
    function getRelease(): Double;
    procedure setRelease(const Value: Double);
    function calcAmp(): Double;
    function calcVal(): Double;
    function calcMax(const Value: Double): Double;
  public
    procedure Init(const Gain: TGain);
    procedure Done();
    function Process(const Value: Double): Double;
    property Gain: TGain read getGain;
    property Val: Double read getVal;
    property Amp: Double read getAmp write setAmp;
    property Rate: Double read getRate write setRate;
    property Attack: Double read getAttack write setAttack;
    property Release: Double read getRelease write setRelease;
  end;

implementation

uses
  Math;

procedure TQMPNRM.Init(const Gain: TGain);
begin
  self.fgain := Gain;
end;

procedure TQMPNRM.Done();
begin
end;

function TQMPNRM.getGain(): TGain;
begin
  Result := self.fgain;
end;

function TQMPNRM.getVal(): Double;
begin
  Result := self.calcVal();
end;

function TQMPNRM.getAmp(): Double;
begin
  Result := self.famp;
end;

procedure TQMPNRM.setAmp(const Value: Double);
begin
  self.famp := Value;
end;

function TQMPNRM.getRate(): Double;
begin
  Result := self.frate;
end;

procedure TQMPNRM.setRate(const Value: Double);
begin
  self.frate := Value;
end;

function TQMPNRM.getAttack(): Double;
begin
  Result := self.fattack;
end;

procedure TQMPNRM.setAttack(const Value: Double);
begin
  self.fattack := Value;
end;

function TQMPNRM.getRelease(): Double;
begin
  Result := self.frelease;
end;

procedure TQMPNRM.setRelease(const Value: Double);
begin
  self.frelease := Value;
end;

function TQMPNRM.calcAmp(): Double;
begin
  case (self.fgain) of
    gtDb: begin
      Result := Power(10.0, self.famp / 20.0);
    end;
    gtAmp: begin
      Result := self.famp;
    end;
  end;
end;

function TQMPNRM.calcVal(): Double;
begin
  case (self.fgain) of
    gtDb: begin
      Result := Log10(self.fval) * 20.0;
    end;
    gtAmp: begin
      Result := self.fval;
    end;
  end;
end;

function TQMPNRM.calcMax(const Value: Double): Double;
const
  rms: Double = 0.0;
  avg: Double = 0.0;
  val: Double = 0.0;
var
  env: Double;
  cnt: Double;
begin
  env := avg + 3.0 * Sqrt(rms - Sqr(avg));
  cnt := self.frate * IfThen(val > env, self.fattack, self.frelease);
  avg := avg - (avg - Abs(Value)) / cnt;
  rms := rms - (rms - Sqr(Value)) / cnt;
  val := val - (val - Abs( env )) / cnt;
  Result := val;
end;

function TQMPNRM.Process(const Value: Double): Double;
begin
  self.fval := Min(Max(1.0 / self.calcAmp(), 1.0 / self.calcMax(Value)), 1.0 * self.calcAmp());
  Result := self.fval * Value;
end;

begin
end.
