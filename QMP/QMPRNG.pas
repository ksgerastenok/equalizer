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
    var fflt: TQMPBQF;
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
  self.fflt.Init(Filter, Band, Gain);
end;

procedure TQMPRNG.Done();
begin
  self.fflt.Done();
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
  Result := self.fflt.Freq;
end;

procedure TQMPRNG.setFreq(const Value: Double);
begin
  self.fflt.Freq := Value;
end;

function TQMPRNG.getRate(): Double;
begin
  Result := self.fflt.Rate;
end;

procedure TQMPRNG.setRate(const Value: Double);
begin
  self.fflt.Rate := Value;
end;

function TQMPRNG.getWidth(): Double;
begin
  Result := self.fflt.Width;
end;

procedure TQMPRNG.setWidth(const Value: Double);
begin
  self.fflt.Width := Value;
end;

function TQMPRNG.getGain(): Double;
begin
  case (self.fflt.Gain) of
    gtDb: begin
      Result := 20 * Log10(self.calcGain());
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
  case (self.fflt.Gain) of
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

function TQMPRNG.calcGain(): Double;
begin
  Result := Min(Max(1.0, 1.0 / self.fval), self.calcAmp());
end;

procedure TQMPRNG.addSample(const Value: Double);
const
  fsqr: Double = 0.0;
  favg: Double = 0.0;
begin
  fsqr := fsqr - (fsqr - Sqr(Value)) / IfThen(Abs(Value) < self.fval, 250000, 25000);
  favg := favg - (favg - Abs(Value)) / IfThen(Abs(Value) < self.fval, 250000, 25000);
  self.fval := 1.75 * (favg + Sqrt(fsqr - Sqr(favg)));
end;

function TQMPRNG.Process(const Value: Double): Double;
begin
  self.addSample(self.fflt.Process(Value));
  Result := self.calcGain() * Value;
end;

begin
end.
