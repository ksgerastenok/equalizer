unit
  QMPRNG;

interface

uses
  QMPBQF;

type
  TQMPRNG = record
  private
    var fval: Double;
    var famp: Double;
    var fbqf: TQMPBQF;
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
    function calcGain(const Value: Double): Double;
  public
    procedure Init(const Filter: TFilter; const Band: TBand; const Gain: TGain);
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

procedure TQMPRNG.Init(const Filter: TFilter; const Band: TBand; const Gain: TGain);
begin
  self.fbqf.Init(Filter, Band, Gain);
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
      Result := 20 * Log10(self.fval);
    end;
    gtAmp: begin
      Result := self.fval;
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
      Result := Power(10, self.famp / 20);
    end;
    gtAmp: begin
      Result := self.famp;
    end;
    else begin
      Result := 0.0;
    end;
  end;
end;

function TQMPRNG.calcGain(const Value: Double): Double;
const
  fsqr: Double = 0.0;
  favg: Double = 0.0;
  fval: Double = 0.0;
begin
  fsqr := fsqr - (fsqr - Sqr(Value)) / IfThen(Abs(Value) < fval, 5.0 * self.Rate, 0.5 * self.Rate);
  favg := favg - (favg - Abs(Value)) / IfThen(Abs(Value) < fval, 5.0 * self.Rate, 0.5 * self.Rate);
  fval := 1.75 * (favg + Sqrt(fsqr - Sqr(favg)));
  Result := Min(Max(1.0, 1.0 / fval), self.calcAmp());
end;

function TQMPRNG.Process(const Value: Double): Double;
begin
  self.fval := self.calcGain(self.fbqf.Process(Value));
  Result := self.fval * Value;
end;

begin
end.
