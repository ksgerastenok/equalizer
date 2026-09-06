unit
  WMPNRM;

interface

type
  TGain = (gtDb, gtAmp);

type
  TTransform = (ttABS, ttRMS);

type
  TWMPNRM = record
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

procedure TWMPNRM.Init(const Transform: TTransform; const Gain: TGain);
begin
  self.fgain := Gain;
  self.ftransform := Transform;
end;

procedure TWMPNRM.Done();
begin
end;

function TWMPNRM.getGain(): TGain;
begin
  Result := self.fgain;
end;

function TWMPNRM.getTransform(): TTransform;
begin
  Result := self.ftransform;
end;

function TWMPNRM.calcAmp(): Double;
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

function TWMPNRM.calcVal(): Double;
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

function TWMPNRM.getVal(): Double;
begin
  Result := self.calcVal();
end;

function TWMPNRM.getAmp(): Double;
begin
  Result := self.famp;
end;

procedure TWMPNRM.setAmp(const Value: Double);
begin
  self.famp := Value;
end;

function TWMPNRM.getRate(): Double;
begin
  Result := self.frate;
end;

procedure TWMPNRM.setRate(const Value: Double);
begin
  self.frate := Value;
end;

function TWMPNRM.getAttack(): Double;
begin
  Result := self.fattack;
end;

procedure TWMPNRM.setAttack(const Value: Double);
begin
  self.fattack := Value;
end;

function TWMPNRM.getRelease(): Double;
begin
  Result := self.frelease;
end;

procedure TWMPNRM.setRelease(const Value: Double);
begin
  self.frelease := Value;
end;

function TWMPNRM.Process(const Value: Double): Double;
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
