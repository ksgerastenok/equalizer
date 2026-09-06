unit
  QMPNRM;

interface

type
  TGain = (gtDb, gtAmp);

type
  TTransform = (ttABS, ttRMS);

type
  TQMPNRM = record
  private
    var fgain: TGain;
    var ftransform: TTransform;
    var famp: Double;
    var fval: Double;
    var frate: Double;
    var fattack: Double;
    var frelease: Double;
    function getGain(): TGain;
    function getTransform(): TTransform;
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
  public
    procedure Init(const Transform: TTransform; const Gain: TGain);
    procedure Done();
    function Process(const Value: Double): Double;
    property Gain: TGain read getGain;
    property Transform: TTransform read getTransform;
    property Val: Double read getVal;
    property Amp: Double read getAmp write setAmp;
    property Rate: Double read getRate write setRate;
    property Attack: Double read getAttack write setAttack;
    property Release: Double read getRelease write setRelease;
  end;

implementation

uses
  Math;

procedure TQMPNRM.Init(const Transform: TTransform; const Gain: TGain);
begin
  self.fgain := Gain;
  self.ftransform := Transform;
end;

procedure TQMPNRM.Done();
begin
end;

function TQMPNRM.getGain(): TGain;
begin
  Result := self.fgain;
end;

function TQMPNRM.getTransform(): TTransform;
begin
  Result := self.ftransform;
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

function TQMPNRM.Process(const Value: Double): Double;
begin
  self.fval := IfThen(self.fval <> 0.0, self.fval, 1.0);
  case (self.ftransform) of
    ttABS: begin
      self.fval := self.fval /  Abs(1.0 - (1.0 - Abs(2.0 * self.fval * Value)) / IfThen(Abs(2.0 * self.fval * Value) < 1.0, self.fattack * self.frate, self.frelease * self.frate));
    end;
    ttRMS: begin
      self.fval := self.fval / Sqrt(1.0 - (1.0 - Sqr(3.0 * self.fval * Value)) / IfThen(Sqr(3.0 * self.fval * Value) < 1.0, self.fattack * self.frate, self.frelease * self.frate));
    end;
  end;
  self.fval := Min(Max(1.0 / self.calcAmp(), self.fval), 1.0 * self.calcAmp());
  Result := self.fval * Value;
end;

begin
end.
