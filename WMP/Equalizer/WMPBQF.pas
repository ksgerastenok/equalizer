unit
  WMPBQF;

interface

type
  TBand = (bqfQ, bqfSlope, bqfOctave, bqfSemitone);

type
  TGain = (bqfDb, bqfAmp);

type
  TFilter = (bqfEqu, bqfInv, bqfLow, bqfBand, bqfBass, bqfHigh, bqfPeak, bqfNotch, bqfTreble);

type
  PWMPBQF = ^TWMPBQF;
  TWMPBQF = record
  private
    var fband: TBand;
    var fgain: TGain;
    var ffilter: TFilter;
    var fconfig: array[0..1, 0..2] of Double;
    var fsignal: array[0..1, 0..2] of Double;
    var famp: Double;
    var ffreq: Double;
    var frate: Double;
    var fwidth: Double;
    function calcAmp(): Double;
    function calcAlpha(): Double;
    function calcOmega(): Double;
    procedure calcConfig();
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
  public
    procedure Init(const Filter: TFilter; const Band: TBand; const Gain: TGain);
    procedure Done();
    function Process(const Input: Double): Double;
    property Band: TBand read getBand;
    property Gain: TGain read getGain;
    property Filter: TFilter read getFilter;
    property Amp: Double read getAmp write setAmp;
    property Freq: Double read getFreq write setFreq;
    property Rate: Double read getRate write setRate;
    property Width: Double read getWidth write setWidth;
  end;

implementation

uses
  Math;

procedure TWMPBQF.Init(const Filter: TFilter; const Band: TBand; const Gain: TGain);
begin
  self.fband := Band;
  self.fgain := Gain;
  self.ffilter := Filter;
end;

procedure TWMPBQF.Done();
begin
end;

function TWMPBQF.calcAmp(): Double;
begin
  case (self.fgain) of
    bqfDb: begin
      Result := Power(10, self.famp / 20);
    end;
    bqfAmp: begin
      Result := self.famp;
    end;
  end;
end;

function TWMPBQF.calcAlpha(): Double;
begin
  case (self.fband) of
    bqfQ: begin
      Result := (1 / self.fwidth);
    end;
    bqfOctave: begin
      Result := 2 * Sinh((Ln(2) / 2) * (self.fwidth /  1) / (Sin(self.calcOmega()) / self.calcOmega()));
    end;
    bqfSemitone: begin
      Result := 2 * Sinh((Ln(2) / 2) * (self.fwidth / 12) / (Sin(self.calcOmega()) / self.calcOmega()));
    end;
    bqfSlope: begin
      Result := Sqrt((Sqrt(self.calcAmp()) + 1 / Sqrt(self.calcAmp())) * (1 / self.fwidth - 1) + 2);
    end;
  end;
end;

function TWMPBQF.calcOmega(): Double;
begin
  Result := (2 * Pi * self.ffreq / self.frate);
end;

procedure TWMPBQF.calcConfig();
begin
  case (self.ffilter) of
    bqfLow: begin
      self.fconfig[0, 2] :=  1 * ((1 - Cos(self.calcOmega())) / 2);
      self.fconfig[0, 1] := +2 * ((1 - Cos(self.calcOmega())) / 2);
      self.fconfig[0, 0] :=  1 * ((1 - Cos(self.calcOmega())) / 2);
      self.fconfig[1, 2] :=  1 - (Sin(self.calcOmega()) / 2) * self.calcAlpha();
      self.fconfig[1, 1] := -2 * (Cos(self.calcOmega()));
      self.fconfig[1, 0] :=  1 + (Sin(self.calcOmega()) / 2) * self.calcAlpha();
    end;
    bqfHigh: begin
      self.fconfig[0, 2] :=  1 * ((1 + Cos(self.calcOmega())) / 2);
      self.fconfig[0, 1] := -2 * ((1 + Cos(self.calcOmega())) / 2);
      self.fconfig[0, 0] :=  1 * ((1 + Cos(self.calcOmega())) / 2);
      self.fconfig[1, 2] :=  1 - (Sin(self.calcOmega()) / 2) * self.calcAlpha();
      self.fconfig[1, 1] := -2 * (Cos(self.calcOmega()));
      self.fconfig[1, 0] :=  1 + (Sin(self.calcOmega()) / 2) * self.calcAlpha();
    end;
    bqfPeak: begin
      self.fconfig[0, 2] :=  0 - (Sin(self.calcOmega()) / 2) *        1        ;
      self.fconfig[0, 1] :=  0;
      self.fconfig[0, 0] :=  0 + (Sin(self.calcOmega()) / 2) *        1        ;
      self.fconfig[1, 2] :=  1 - (Sin(self.calcOmega()) / 2) * self.calcAlpha();
      self.fconfig[1, 1] := -2 * (Cos(self.calcOmega()));
      self.fconfig[1, 0] :=  1 + (Sin(self.calcOmega()) / 2) * self.calcAlpha();
    end;
    bqfBand: begin
      self.fconfig[0, 2] :=  0 - (Sin(self.calcOmega()) / 2) * self.calcAlpha();
      self.fconfig[0, 1] :=  0;
      self.fconfig[0, 0] :=  0 + (Sin(self.calcOmega()) / 2) * self.calcAlpha();
      self.fconfig[1, 2] :=  1 - (Sin(self.calcOmega()) / 2) * self.calcAlpha();
      self.fconfig[1, 1] := -2 * (Cos(self.calcOmega()));
      self.fconfig[1, 0] :=  1 + (Sin(self.calcOmega()) / 2) * self.calcAlpha();
    end;
    bqfNotch: begin
      self.fconfig[0, 2] :=  1;
      self.fconfig[0, 1] := -2 * (Cos(self.calcOmega()));
      self.fconfig[0, 0] :=  1;
      self.fconfig[1, 2] :=  1 - (Sin(self.calcOmega()) / 2) * self.calcAlpha();
      self.fconfig[1, 1] := -2 * (Cos(self.calcOmega()));
      self.fconfig[1, 0] :=  1 + (Sin(self.calcOmega()) / 2) * self.calcAlpha();
    end;
    bqfInv: begin
      self.fconfig[0, 2] :=  1 + (Sin(self.calcOmega()) / 2) * self.calcAlpha();
      self.fconfig[0, 1] := -2 * (Cos(self.calcOmega()));
      self.fconfig[0, 0] :=  1 - (Sin(self.calcOmega()) / 2) * self.calcAlpha();
      self.fconfig[1, 2] :=  1 - (Sin(self.calcOmega()) / 2) * self.calcAlpha();
      self.fconfig[1, 1] := -2 * (Cos(self.calcOmega()));
      self.fconfig[1, 0] :=  1 + (Sin(self.calcOmega()) / 2) * self.calcAlpha();
    end;
    bqfEqu: begin
      self.fconfig[0, 2] :=  1 - (Sin(self.calcOmega()) / 2) * self.calcAlpha() * Sqrt(self.calcAmp());
      self.fconfig[0, 1] := -2 * (Cos(self.calcOmega()));
      self.fconfig[0, 0] :=  1 + (Sin(self.calcOmega()) / 2) * self.calcAlpha() * Sqrt(self.calcAmp());
      self.fconfig[1, 2] :=  1 - (Sin(self.calcOmega()) / 2) * self.calcAlpha() / Sqrt(self.calcAmp());
      self.fconfig[1, 1] := -2 * (Cos(self.calcOmega()));
      self.fconfig[1, 0] :=  1 + (Sin(self.calcOmega()) / 2) * self.calcAlpha() / Sqrt(self.calcAmp());
    end;
    bqfBass: begin
      self.fconfig[0, 2] :=  1 * Sqrt(self.calcAmp()) * ((Sqrt(self.calcAmp()) + 1) - (Sqrt(self.calcAmp()) - 1) * Cos(self.calcOmega()) - 2 * Sqrt(Sqrt(self.calcAmp())) * (Sin(self.calcOmega()) / 2) * self.calcAlpha());
      self.fconfig[0, 1] := +2 * Sqrt(self.calcAmp()) * ((Sqrt(self.calcAmp()) - 1) - (Sqrt(self.calcAmp()) + 1) * Cos(self.calcOmega()));
      self.fconfig[0, 0] :=  1 * Sqrt(self.calcAmp()) * ((Sqrt(self.calcAmp()) + 1) - (Sqrt(self.calcAmp()) - 1) * Cos(self.calcOmega()) + 2 * Sqrt(Sqrt(self.calcAmp())) * (Sin(self.calcOmega()) / 2) * self.calcAlpha());
      self.fconfig[1, 2] :=  1 *           1          * ((Sqrt(self.calcAmp()) + 1) + (Sqrt(self.calcAmp()) - 1) * Cos(self.calcOmega()) - 2 * Sqrt(Sqrt(self.calcAmp())) * (Sin(self.calcOmega()) / 2) * self.calcAlpha());
      self.fconfig[1, 1] := -2 *           1          * ((Sqrt(self.calcAmp()) - 1) + (Sqrt(self.calcAmp()) + 1) * Cos(self.calcOmega()));
      self.fconfig[1, 0] :=  1 *           1          * ((Sqrt(self.calcAmp()) + 1) + (Sqrt(self.calcAmp()) - 1) * Cos(self.calcOmega()) + 2 * Sqrt(Sqrt(self.calcAmp())) * (Sin(self.calcOmega()) / 2) * self.calcAlpha());
    end;
    bqfTreble: begin
      self.fconfig[0, 2] :=  1 * Sqrt(self.calcAmp()) * ((Sqrt(self.calcAmp()) + 1) + (Sqrt(self.calcAmp()) - 1) * Cos(self.calcOmega()) - 2 * Sqrt(Sqrt(self.calcAmp())) * (Sin(self.calcOmega()) / 2) * self.calcAlpha());
      self.fconfig[0, 1] := -2 * Sqrt(self.calcAmp()) * ((Sqrt(self.calcAmp()) - 1) + (Sqrt(self.calcAmp()) + 1) * Cos(self.calcOmega()));
      self.fconfig[0, 0] :=  1 * Sqrt(self.calcAmp()) * ((Sqrt(self.calcAmp()) + 1) + (Sqrt(self.calcAmp()) - 1) * Cos(self.calcOmega()) + 2 * Sqrt(Sqrt(self.calcAmp())) * (Sin(self.calcOmega()) / 2) * self.calcAlpha());
      self.fconfig[1, 2] :=  1 *           1          * ((Sqrt(self.calcAmp()) + 1) - (Sqrt(self.calcAmp()) - 1) * Cos(self.calcOmega()) - 2 * Sqrt(Sqrt(self.calcAmp())) * (Sin(self.calcOmega()) / 2) * self.calcAlpha());
      self.fconfig[1, 1] := +2 *           1          * ((Sqrt(self.calcAmp()) - 1) - (Sqrt(self.calcAmp()) + 1) * Cos(self.calcOmega()));
      self.fconfig[1, 0] :=  1 *           1          * ((Sqrt(self.calcAmp()) + 1) - (Sqrt(self.calcAmp()) - 1) * Cos(self.calcOmega()) + 2 * Sqrt(Sqrt(self.calcAmp())) * (Sin(self.calcOmega()) / 2) * self.calcAlpha());
    end;
  end;
end;

function TWMPBQF.Process(const Input: Double): Double;
begin
  self.fsignal[0, 2] := self.fsignal[0, 1];
  self.fsignal[0, 1] := self.fsignal[0, 0];
  self.fsignal[0, 0] := Input;
  self.fsignal[1, 2] := self.fsignal[1, 1];
  self.fsignal[1, 1] := self.fsignal[1, 0];
  self.fsignal[1, 0] := ((self.fsignal[0, 0] * self.fconfig[0, 0] + self.fsignal[0, 1] * self.fconfig[0, 1] + self.fsignal[0, 2] * self.fconfig[0, 2]) - (self.fsignal[1, 1] * self.fconfig[1, 1] + self.fsignal[1, 2] * self.fconfig[1, 2])) / self.fconfig[1, 0];
  Result := self.fsignal[1, 0];
end;

function TWMPBQF.getBand(): TBand;
begin
  Result := self.fband;
end;

function TWMPBQF.getGain(): TGain;
begin
  Result := self.fgain;
end;

function TWMPBQF.getFilter(): TFilter;
begin
  Result := self.ffilter;
end;

function TWMPBQF.getAmp(): Double;
begin
  Result := self.famp;
end;

procedure TWMPBQF.setAmp(const Value: Double);
begin
  if (self.famp <> Value) then begin
    self.famp := Value;
    self.calcConfig();
  end;
end;

function TWMPBQF.getFreq(): Double;
begin
  Result := self.ffreq;
end;

procedure TWMPBQF.setFreq(const Value: Double);
begin
  if (self.ffreq <> Value) then begin
    self.ffreq := Value;
    self.calcConfig();
  end;
end;

function TWMPBQF.getRate(): Double;
begin
  Result := self.frate;
end;

procedure TWMPBQF.setRate(const Value: Double);
begin
  if (self.frate <> Value) then begin
    self.frate := Value;
    self.calcConfig();
  end;
end;

function TWMPBQF.getWidth(): Double;
begin
  Result := self.fwidth;
end;

procedure TWMPBQF.setWidth(const Value: Double);
begin
  if (self.fwidth <> Value) then begin
    self.fwidth := Value;
    self.calcConfig();
  end;
end;

begin
end.
