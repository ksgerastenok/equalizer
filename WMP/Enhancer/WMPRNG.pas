unit
  WMPRNG;

interface

uses
  WMPBQF;

type
  TWMPRNG = record
  private
    var fval: Double;
    var famp: Double;
    var fflt: TWMPBQF;
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

procedure TWMPRNG.Init(const Filter: TFilter; const Band: TBand; const Gain: TGain);
begin
  self.fflt.Init(Filter, Band, Gain);
end;

procedure TWMPRNG.Done();
begin
  self.fflt.Done();
end;

function TWMPRNG.getAmp(): Double;
begin
  Result := self.famp;
end;

procedure TWMPRNG.setAmp(const Value: Double);
begin
  self.famp := Value;
end;

function TWMPRNG.getFreq(): Double;
begin
  Result := self.fflt.Freq;
end;

procedure TWMPRNG.setFreq(const Value: Double);
begin
  self.fflt.Freq := Value;
end;

function TWMPRNG.getRate(): Double;
begin
  Result := self.fflt.Rate;
end;

procedure TWMPRNG.setRate(const Value: Double);
begin
  self.fflt.Rate := Value;
end;

function TWMPRNG.getWidth(): Double;
begin
  Result := self.fflt.Width;
end;

procedure TWMPRNG.setWidth(const Value: Double);
begin
  self.fflt.Width := Value;
end;

function TWMPRNG.getGain(): Double;
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

function TWMPRNG.calcAmp(): Double;
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

function TWMPRNG.calcGain(): Double;
begin
  Result := Min(Max(1.0, 1.0 / self.fval), self.calcAmp());
end;

procedure TWMPRNG.addSample(const Value: Double);
const
  fsqr: Double = 0.0;
  favg: Double = 0.0;
begin
  fsqr := fsqr - (fsqr - Sqr(Value)) / IfThen(Abs(Value) < self.fval, 250000, 25000);
  favg := favg - (favg - Abs(Value)) / IfThen(Abs(Value) < self.fval, 250000, 25000);
  self.fval := 1.75 * (favg + Sqrt(fsqr - Sqr(favg)));
end;

function TWMPRNG.Process(const Value: Double): Double;
begin
  self.addSample(self.fflt.Process(Value));
  Result := self.calcGain() * Value;
end;

begin
end.
