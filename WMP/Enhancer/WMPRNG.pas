unit
  WMPRNG;

interface

uses
  WMPBQF;

type
  TWMPRNG = record
  private
    var fbqf: TWMPBQF;
    var famp: Double;
    var fsqr: Double;
    var favg: Double;
    var fval: Double;
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
  self.fval := 1.0;
  self.fbqf.Init(Filter, Band, Gain);
end;

procedure TWMPRNG.Done();
begin
  self.fval := 1.0;
  self.fbqf.Done();
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
  Result := self.fbqf.Freq;
end;

procedure TWMPRNG.setFreq(const Value: Double);
begin
  self.fbqf.Freq := Value;
end;

function TWMPRNG.getRate(): Double;
begin
  Result := self.fbqf.Rate;
end;

procedure TWMPRNG.setRate(const Value: Double);
begin
  self.fbqf.Rate := Value;
end;

function TWMPRNG.getWidth(): Double;
begin
  Result := self.fbqf.Width;
end;

procedure TWMPRNG.setWidth(const Value: Double);
begin
  self.fbqf.Width := Value;
end;

function TWMPRNG.getGain(): Double;
begin
  case (self.fbqf.Gain) of
    gtDb: begin
      Result := 20.0 * Log10(self.fval);
    end;
    gtAmp: begin
      Result := self.fval;
    end;
    else begin
      Result := 0.0;
    end;
  end;
end;

function TWMPRNG.calcAmp(): Double;
begin
  case (self.fbqf.Gain) of
    gtDb: begin
      Result := Power(10, self.famp / 20.0);
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
  Result := Min(Max(1.0, 1.0 / (1.75 * (self.favg + Sqrt(self.fsqr - Sqr(self.favg))))), self.calcAmp());
end;

procedure TWMPRNG.addSample(const Value: Double);
begin
  if (self.fval * Abs(Value) < 1.0) then begin
    self.fsqr := self.fsqr - (self.fsqr - Sqr(Value)) / 250000;
    self.favg := self.favg - (self.favg - Abs(Value)) / 250000;
    self.fval := self.fval - (self.fval - self.calcGain()) / 1000;
  end                               else begin
    self.fsqr := self.fsqr - (self.fsqr - Sqr(Value)) / 25000;
    self.favg := self.favg - (self.favg - Abs(Value)) / 25000;
    self.fval := self.fval - (self.fval - self.calcGain()) / 100;
  end;
end;

function TWMPRNG.Process(const Value: Double): Double;
begin
  self.addSample(self.fbqf.Process(Value));
  Result := self.fval * Value;
end;

begin
end.
