unit
  WMPRNG;

interface

uses
  WMPBQF;

type
  PWMPRNG = ^TWMPRNG;
  TWMPRNG = record
  private
    var fsqr: Double;
    var favg: Double;
    var famp: Double;
    var fflt: TWMPBQF;
    function getBand(): TBand;
    function getGain(): TGain;
    function getFilter(): TFilter;
    function getAmp(): Double;
    procedure setAmp(const Value: Double);
    function getFreq(): Double;
    procedure setFreq(const Value: Double);
    function getRate(): Double;
    procedure setRate(const Value: Double);
    function getWidth(): Double;
    procedure setWidth(const Value: Double);
    function getValue(): Double;
    procedure addSample(const Value: Double);
    function getResult(): Double;
  public
    procedure Init(const Filter: TFilter; const Band: TBand; const Gain: TGain);
    procedure Done();
    function Process(const Value: Double): Double;
    property Value: Double read getValue;
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
  self.fsqr := 0.0;
  self.favg := 0.0;
  self.famp := 10.0;
  self.fflt.Init(Filter, Band, Gain);
end;

procedure TWMPRNG.Done();
begin
  self.fsqr := 0.0;
  self.favg := 0.0;
  self.famp := 10.0;
  self.fflt.Done();
end;

function TWMPRNG.getBand(): TBand;
begin
  Result := self.fflt.Band;
end;

function TWMPRNG.getGain(): TGain;
begin
  Result := self.fflt.Gain;
end;

function TWMPRNG.getFilter(): TFilter;
begin
  Result := self.fflt.Filter;
end;

function TWMPRNG.getAmp(): Double;
begin
  case (self.fflt.Gain) of
    gtDb: begin
      Result := 20 * Log10(self.famp);
    end;
    gtAmp: begin
      Result := self.famp;
    end;
    else begin
      Result := 0.0;
    end;
  end;
end;

procedure TWMPRNG.setAmp(const Value: Double);
begin
  case (self.fflt.Gain) of
    gtDb: begin
      self.famp := Power(10, Value / 20);
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

function TWMPRNG.getValue(): Double;
begin
  case (self.fflt.Gain) of
    gtDb: begin
      Result := 20 * Log10(self.getResult());
    end;
    gtAmp: begin
      Result := self.getResult();
    end;
    else begin
      Result := 0.0;
    end;
  end;
end;

procedure TWMPRNG.addSample(const Value: Double);
begin
  self.fsqr := self.fsqr + (Sqr(Value) - self.fsqr) / IfThen(self.getResult() * Abs(Value) <= 1.0, 250000, 25000);
  self.favg := self.favg + (Abs(Value) - self.favg) / IfThen(self.getResult() * Abs(Value) <= 1.0, 250000, 25000);
end;

function TWMPRNG.getResult(): Double;
begin
  Result := Min(Max(1.0, 1.0 / (1.75 * (self.favg + Sqrt(self.fsqr - Sqr(self.favg))))), self.famp);
end;

function TWMPRNG.Process(const Value: Double): Double;
begin
  self.addSample(self.fflt.Process(Value));
  Result := self.getResult() * Value;
end;

begin
end.
