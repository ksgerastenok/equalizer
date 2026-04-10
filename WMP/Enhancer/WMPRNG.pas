unit
  WMPRNG;

interface

uses
  WMPBQF;

type
  TWMPRNG = record
  private
    var fbqf: TWMPBQF;
    var fsqr: Double;
    var favg: Double;
    var famp: Double;
    function getGain(): TGain;
    function getBand(): TBand;
    function getFilter(): TFilter;
    function getTransform(): TTransform;
    function getAmp(): Double;
    procedure setAmp(const Value: Double);
    function getFreq(): Double;
    procedure setFreq(const Value: Double);
    function getRate(): Double;
    procedure setRate(const Value: Double);
    function getWidth(): Double;
    procedure setWidth(const Value: Double);
    function calcAmp(): Double;
    function calcValue(): Double;
    procedure addSample(const Value: Double);
  public
    procedure Init(const Transform: TTransform; const Filter: TFilter; const Band: TBand; const Gain: TGain);
    procedure Done();
    function Process(const Value: Double): Double;
    property Gain: TGain read getGain;
    property Band: TBand read getBand;
    property Filter: TFilter read getFilter;
    property Transform: TTransform read getTransform;
    property Amp: Double read getAmp write setAmp;
    property Freq: Double read getFreq write setFreq;
    property Rate: Double read getRate write setRate;
    property Width: Double read getWidth write setWidth;
  end;

implementation

uses
  Math;

procedure TWMPRNG.Init(const Transform: TTransform; const Filter: TFilter; const Band: TBand; const Gain: TGain);
begin
  self.fbqf.Init(Transform, Filter, Band, Gain);
end;

procedure TWMPRNG.Done();
begin
  self.fbqf.Done();
end;

function TWMPRNG.getBand(): TBand;
begin
  Result := self.fbqf.Band;
end;

function TWMPRNG.getGain(): TGain;
begin
  Result := self.fbqf.Gain;
end;

function TWMPRNG.getFilter(): TFilter;
begin
  Result := self.fbqf.Filter;
end;

function TWMPRNG.getTransform(): TTransform;
begin
  Result := self.fbqf.Transform;
end;

function TWMPRNG.calcAmp(): Double;
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

function TWMPRNG.getAmp(): Double;
begin
  case (self.fbqf.Gain) of
    gtDb: begin
      Result := Log10(self.calcValue()) * 20.0;
    end;
    gtAmp: begin
      Result := self.calcValue();
    end;
    else begin
      Result := 0.0;
    end;
  end;
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

function TWMPRNG.calcValue(): Double;
begin
  Result := Min(Max(1.0 / self.calcAmp(), 1.0 / (self.favg + 3.0 * Sqrt(self.fsqr - Sqr(self.favg)))), 1.0 * self.calcAmp());
end;

procedure TWMPRNG.addSample(const Value: Double);
begin
  if (self.calcValue() * Abs(Value) < 1.0) then begin
    self.fsqr := self.fsqr - (self.fsqr - Sqr(Value)) / (5.0 * self.fbqf.Rate);
    self.favg := self.favg - (self.favg - Abs(Value)) / (5.0 * self.fbqf.Rate);
  end                                     else begin
    self.fsqr := self.fsqr - (self.fsqr - Sqr(Value)) / (0.5 * self.fbqf.Rate);
    self.favg := self.favg - (self.favg - Abs(Value)) / (0.5 * self.fbqf.Rate);
  end;
end;

function TWMPRNG.Process(const Value: Double): Double;
begin
  self.addSample(self.fbqf.Process(Value));
  Result := self.calcValue() * Value;
end;

begin
end.
