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
    var fval: Double;
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
  self.fval := 1.0;
end;

procedure TWMPRNG.Done();
begin
  self.fval := 1.0;
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

function TWMPRNG.getAmp(): Double;
begin
  case (self.fbqf.Gain) of
    gtDb: begin
      Result := Log10(self.fval) * 20.0;
    end;
    gtAmp: begin
      Result := self.fval;
    end;
    else begin
      Result := 0.0;
    end;
  end;
end;

procedure TWMPRNG.setAmp(const Value: Double);
begin
  case (self.fbqf.Gain) of
    gtDb: begin
      self.famp := Power(10.0, Value / 20.0);
    end;
    gtAmp: begin
      self.famp := Value;
    end;
    else begin
      self.famp := 0.0;
    end;
  end;
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

procedure TWMPRNG.addSample(const Value: Double);
begin
  self.fval := Min(Max(1.0 / self.famp, self.fval / Sqrt(1.0 - (1.0 - Sqr(3.0 * self.fval * Value)) / IfThen(Abs(self.fval * Value) < 1.0, 5.0 * self.fbqf.Rate, 0.5 * self.fbqf.Rate))), 1.0 * self.famp);
end;

function TWMPRNG.Process(const Value: Double): Double;
begin
  self.addSample(self.fbqf.Process(Value));
  Result := self.fval * Value;
end;

begin
end.
