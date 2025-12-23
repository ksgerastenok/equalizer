unit
  QMPRNG;

interface

uses
  QMPBQF;

type
  TQMPRNG = record
  private
    var fbqf: TQMPBQF;
    var famp: Double;
    var fsqr: Double;
    var favg: Double;
    function getAmp(): Double;
    procedure setAmp(const Value: Double);
    function getFreq(): Double;
    procedure setFreq(const Value: Double);
    function getRate(): Double;
    procedure setRate(const Value: Double);
    function getWidth(): Double;
    procedure setWidth(const Value: Double);
    function getGain(): Double;
    function calcAmp(): Double;
    function calcGain(): Double;
    procedure addSample(const Value: Double);
  public
    procedure Init(const Transform: TTransform; const Filter: TFilter; const Band: TBand; const Gain: TGain);
    procedure Done();
    function Process(const Value: Double): Double;
    property Gain: Double read getGain;
    property Amp: Double read getAmp write setAmp;
    property Freq: Double read getFreq write setFreq;
    property Rate: Double read getRate write setRate;
    property Width: Double read getWidth write setWidth;
  end;

implementation

uses
  Math;

procedure TQMPRNG.Init(const Transform: TTransform; const Filter: TFilter; const Band: TBand; const Gain: TGain);
begin
  self.fbqf.Init(Transform, Filter, Band, Gain);
end;

procedure TQMPRNG.Done();
begin
  self.fbqf.Done();
end;

function TQMPRNG.getAmp(): Double;
begin
  Result := self.famp;
end;

procedure TQMPRNG.setAmp(const Value: Double);
begin
  self.famp := Value;
end;

function TQMPRNG.getFreq(): Double;
begin
  Result := self.fbqf.Freq;
end;

procedure TQMPRNG.setFreq(const Value: Double);
begin
  self.fbqf.Freq := Value;
end;

function TQMPRNG.getRate(): Double;
begin
  Result := self.fbqf.Rate;
end;

procedure TQMPRNG.setRate(const Value: Double);
begin
  self.fbqf.Rate := Value;
end;

function TQMPRNG.getWidth(): Double;
begin
  Result := self.fbqf.Width;
end;

procedure TQMPRNG.setWidth(const Value: Double);
begin
  self.fbqf.Width := Value;
end;

function TQMPRNG.getGain(): Double;
begin
  case (self.fbqf.Gain) of
    gtDb: begin
      Result := 20.0 * Log10(self.calcGain());
    end;
    gtAmp: begin
      Result := self.calcGain();
    end;
    else begin
      Result := 0.0;
    end;
  end;
end;

function TQMPRNG.calcAmp(): Double;
begin
  case (self.fbqf.Gain) of
    gtDb: begin
      Result := Power(10.0, self.famp / 20.0);
    end;
    gtAmp: begin
      Result := self.famp;
    end;
    else begin
      Result := 0.0;
    end;
  end;
end;

function TQMPRNG.calcGain(): Double;
begin
  Result := Min(Max(1.0, 1.0 / (1.75 * (self.favg + Sqrt(self.fsqr - Sqr(self.favg))))), self.calcAmp());
end;

procedure TQMPRNG.addSample(const Value: Double);
begin
  if (self.calcGain() * Abs(Value) < 1.0) then begin
    self.fsqr := self.fsqr - (self.fsqr - Sqr(Value)) / 250000.0;
    self.favg := self.favg - (self.favg - Abs(Value)) / 250000.0;
  end                                     else begin
    self.fsqr := self.fsqr - (self.fsqr - Sqr(Value)) / 25000.0;
    self.favg := self.favg - (self.favg - Abs(Value)) / 25000.0;
  end;
end;

function TQMPRNG.Process(const Value: Double): Double;
begin
  self.addSample(self.fbqf.Process(Value));
  Result := self.calcGain() * Value;
end;

begin
end.
