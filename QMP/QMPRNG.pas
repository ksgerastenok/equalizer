unit
  QMPRNG;

interface

uses
  QMPBQF;

type
  TQMPRNG = record
  private
    var fbqf: TQMPBQF;
    var fsqr: Double;
    var favg: Double;
    function getGain(): TGain;
    function getBand(): TBand;
    function getFilter(): TFilter;
    function getTransform(): TTransform;
    function getValue(): Double;
    function getAmp(): Double;
    procedure setAmp(const Data: Double);
    function getFreq(): Double;
    procedure setFreq(const Data: Double);
    function getRate(): Double;
    procedure setRate(const Data: Double);
    function getWidth(): Double;
    procedure setWidth(const Data: Double);
    procedure addSample(const Data: Double);
  public
    procedure Init(const Transform: TTransform; const Filter: TFilter; const Band: TBand; const Gain: TGain);
    procedure Done();
    function Process(const Data: Double): Double;
    property Gain: TGain read getGain;
    property Band: TBand read getBand;
    property Filter: TFilter read getFilter;
    property Transform: TTransform read getTransform;
    property Value: Double read getValue;
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

function TQMPRNG.getBand(): TBand;
begin
  Result := self.fbqf.Band;
end;

function TQMPRNG.getGain(): TGain;
begin
  Result := self.fbqf.Gain;
end;

function TQMPRNG.getFilter(): TFilter;
begin
  Result := self.fbqf.Filter;
end;

function TQMPRNG.getTransform(): TTransform;
begin
  Result := self.fbqf.Transform;
end;

function TQMPRNG.getAmp(): Double;
begin
  case (self.fbqf.Gain) of
    gtDb: begin
      Result := Log10(self.getValue()) * 20.0;
    end;
    gtAmp: begin
      Result := self.getValue();
    end;
    else begin
      Result := 0.0;
    end;
  end;
end;

procedure TQMPRNG.setAmp(const Data: Double);
begin
  self.fbqf.Amp := Data;
end;

function TQMPRNG.getFreq(): Double;
begin
  Result := self.fbqf.Freq;
end;

procedure TQMPRNG.setFreq(const Data: Double);
begin
  self.fbqf.Freq := Data;
end;

function TQMPRNG.getRate(): Double;
begin
  Result := self.fbqf.Rate;
end;

procedure TQMPRNG.setRate(const Data: Double);
begin
  self.fbqf.Rate := Data;
end;

function TQMPRNG.getWidth(): Double;
begin
  Result := self.fbqf.Width;
end;

procedure TQMPRNG.setWidth(const Data: Double);
begin
  self.fbqf.Width := Data;
end;

function TQMPRNG.getValue(): Double;
begin
  Result := Min(Max(1.0 / self.fbqf.Value, 1.0 / (self.favg + 3.0 * Sqrt(self.fsqr - Sqr(self.favg)))), 1.0 * self.fbqf.Value);
end;

procedure TQMPRNG.addSample(const Data: Double);
begin
  if (self.getValue() * Abs(Data) < 1.0) then begin
    self.fsqr := self.fsqr - (self.fsqr - Sqr(Data)) / (5.0 * self.fbqf.Rate);
    self.favg := self.favg - (self.favg - Abs(Data)) / (5.0 * self.fbqf.Rate);
  end                                     else begin
    self.fsqr := self.fsqr - (self.fsqr - Sqr(Data)) / (0.5 * self.fbqf.Rate);
    self.favg := self.favg - (self.favg - Abs(Data)) / (0.5 * self.fbqf.Rate);
  end;
end;

function TQMPRNG.Process(const Data: Double): Double;
begin
  self.addSample(self.fbqf.Process(Data));
  Result := self.getValue() * Data;
end;

begin
end.
