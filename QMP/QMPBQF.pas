unit
  QMPBQF;

interface

type
  TBand = (btQ, btSlope, btOctave, btSemitone);

type
  TGain = (gtDb, gtAmp);

type
  TFilter = (ftEqu, ftInv, ftLow, ftBand, ftBass, ftHigh, ftPeak, ftNotch, ftTreble);

type
  PQMPBQF = ^TQMPBQF;
  TQMPBQF = record
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
    function calcOmega(): Double;
    function calcAlpha(): Double;
    procedure calcConfig();
    procedure calcSignal(const Input: Double; const Output: Double);
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

procedure TQMPBQF.Init(const Filter: TFilter; const Band: TBand; const Gain: TGain);
begin
  self.fband := Band;
  self.fgain := Gain;
  self.ffilter := Filter;
end;

procedure TQMPBQF.Done();
begin
end;

function TQMPBQF.calcOmega(): Double;
begin
  try
    case(self.fgain) of
      gtDb: begin
        Result := Sqrt(Power(10, self.famp / 20));
      end;
      gtAmp: begin
        Result := Sqrt(self.famp);
      end;
      else begin
        Result := 0.0;
      end;
    end;
  except
    Result := 0.0;
  end;
end;

function TQMPBQF.calcAlpha(): Double;
begin
  try
    case(self.fband) of
      btQ: begin
        Result := (Sin(2 * Pi * self.ffreq / self.frate) / 2) * (1 / self.fwidth);
      end;
      btSlope: begin
        Result := (Sin(2 * Pi * self.ffreq / self.frate) / 2) * Sqrt((self.calcOmega() + 1 / self.calcOmega()) * (1 / self.fwidth - 1) + 2);
      end;
      btOctave: begin
        Result := (Sin(2 * Pi * self.ffreq / self.frate) / 2) * 2 * Sinh((Ln(2) / 2) * (self.fwidth / 1) / (Sin(2 * Pi * self.ffreq / self.frate) / (2 * Pi * self.ffreq / self.frate)));
      end;
      btSemitone: begin
        Result := (Sin(2 * Pi * self.ffreq / self.frate) / 2) * 2 * Sinh((Ln(2) / 2) * (self.fwidth / 12) / (Sin(2 * Pi * self.ffreq / self.frate) / (2 * Pi * self.ffreq / self.frate)));
      end;
      else begin
        Result := 0.0;
      end;
    end;
  except
    Result := 0.0;
  end;
end;

procedure TQMPBQF.calcConfig();
begin
  try
    case(self.ffilter) of
      ftEqu: begin
        self.fconfig[0, 2] := 1 - self.calcAlpha() * self.calcOmega();
        self.fconfig[0, 1] := -2 * Cos(2 * Pi * self.ffreq / self.frate);
        self.fconfig[0, 0] := 1 + self.calcAlpha() * self.calcOmega();
        self.fconfig[1, 2] := 1 - self.calcAlpha() / self.calcOmega();
        self.fconfig[1, 1] := -2 * Cos(2 * Pi * self.ffreq / self.frate);
        self.fconfig[1, 0] := 1 + self.calcAlpha() / self.calcOmega();
      end;
      ftInv: begin
        self.fconfig[0, 2] := 1 + self.calcAlpha();
        self.fconfig[0, 1] := -2 * Cos(2 * Pi * self.ffreq / self.frate);
        self.fconfig[0, 0] := 1 - self.calcAlpha();
        self.fconfig[1, 2] := 1 - self.calcAlpha();
        self.fconfig[1, 1] := -2 * Cos(2 * Pi * self.ffreq / self.frate);
        self.fconfig[1, 0] := 1 + self.calcAlpha();
      end;
      ftLow: begin
        self.fconfig[0, 2] := (1 - Cos(2 * Pi * self.ffreq / self.frate)) / 2;
        self.fconfig[0, 1] := (1 - Cos(2 * Pi * self.ffreq / self.frate)) / +1;
        self.fconfig[0, 0] := (1 - Cos(2 * Pi * self.ffreq / self.frate)) / 2;
        self.fconfig[1, 2] := 1 - self.calcAlpha();
        self.fconfig[1, 1] := -2 * Cos(2 * Pi * self.ffreq / self.frate);
        self.fconfig[1, 0] := 1 + self.calcAlpha();
      end;
      ftHigh: begin
        self.fconfig[0, 2] := (1 + Cos(2 * Pi * self.ffreq / self.frate)) / 2;
        self.fconfig[0, 1] := (1 + Cos(2 * Pi * self.ffreq / self.frate)) / -1;
        self.fconfig[0, 0] := (1 + Cos(2 * Pi * self.ffreq / self.frate)) / 2;
        self.fconfig[1, 2] := 1 - self.calcAlpha();
        self.fconfig[1, 1] := -2 * Cos(2 * Pi * self.ffreq / self.frate);
        self.fconfig[1, 0] := 1 + self.calcAlpha();
      end;
      ftPeak: begin
        self.fconfig[0, 2] := -1 * Sin(2 * Pi * self.ffreq / self.frate) / 2;
        self.fconfig[0, 1] := 0.0;
        self.fconfig[0, 0] := +1 * Sin(2 * Pi * self.ffreq / self.frate) / 2;
        self.fconfig[1, 2] := 1 - self.calcAlpha();
        self.fconfig[1, 1] := -2 * Cos(2 * Pi * self.ffreq / self.frate);
        self.fconfig[1, 0] := 1 + self.calcAlpha();
      end;
      ftBand: begin
        self.fconfig[0, 2] := -1 * self.calcAlpha();
        self.fconfig[0, 1] := 0.0;
        self.fconfig[0, 0] := +1 * self.calcAlpha();
        self.fconfig[1, 2] := 1 - self.calcAlpha();
        self.fconfig[1, 1] := -2 * Cos(2 * Pi * self.ffreq / self.frate);
        self.fconfig[1, 0] := 1 + self.calcAlpha();
      end;
      ftNotch: begin
        self.fconfig[0, 2] := 1;
        self.fconfig[0, 1] := -2 * Cos(2 * Pi * self.ffreq / self.frate);
        self.fconfig[0, 0] := 1;
        self.fconfig[1, 2] := 1 - self.calcAlpha();
        self.fconfig[1, 1] := -2 * Cos(2 * Pi * self.ffreq / self.frate);
        self.fconfig[1, 0] := 1 + self.calcAlpha();
      end;
      ftBass: begin
        self.fconfig[0, 2] := self.calcOmega() * ((self.calcOmega() + 1) - (self.calcOmega() - 1) * Cos(2 * Pi * self.ffreq / self.frate) - 2 * Sqrt(self.calcOmega()) * self.calcAlpha());
        self.fconfig[0, 1] := +2 * self.calcOmega() * ((self.calcOmega() - 1) - (self.calcOmega() + 1) * Cos(2 * Pi * self.ffreq / self.frate));
        self.fconfig[0, 0] := self.calcOmega() * ((self.calcOmega() + 1) - (self.calcOmega() - 1) * Cos(2 * Pi * self.ffreq / self.frate) + 2 * Sqrt(self.calcOmega()) * self.calcAlpha());
        self.fconfig[1, 2] := (self.calcOmega() + 1) + (self.calcOmega() - 1) * Cos(2 * Pi * self.ffreq / self.frate) - 2 * Sqrt(self.calcOmega()) * self.calcAlpha();
        self.fconfig[1, 1] := -2 *        1         * ((self.calcOmega() - 1) + (self.calcOmega() + 1) * Cos(2 * Pi * self.ffreq / self.frate));
        self.fconfig[1, 0] := (self.calcOmega() + 1) + (self.calcOmega() - 1) * Cos(2 * Pi * self.ffreq / self.frate) + 2 * Sqrt(self.calcOmega()) * self.calcAlpha();
      end;
      ftTreble: begin
        self.fconfig[0, 2] := self.calcOmega() * ((self.calcOmega() + 1) + (self.calcOmega() - 1) * Cos(2 * Pi * self.ffreq / self.frate) - 2 * Sqrt(self.calcOmega()) * self.calcAlpha());
        self.fconfig[0, 1] := -2 * self.calcOmega() * ((self.calcOmega() - 1) + (self.calcOmega() + 1) * Cos(2 * Pi * self.ffreq / self.frate));
        self.fconfig[0, 0] := self.calcOmega() * ((self.calcOmega() + 1) + (self.calcOmega() - 1) * Cos(2 * Pi * self.ffreq / self.frate) + 2 * Sqrt(self.calcOmega()) * self.calcAlpha());
        self.fconfig[1, 2] := (self.calcOmega() + 1) - (self.calcOmega() - 1) * Cos(2 * Pi * self.ffreq / self.frate) - 2 * Sqrt(self.calcOmega()) * self.calcAlpha();
        self.fconfig[1, 1] := +2 *        1         * ((self.calcOmega() - 1) - (self.calcOmega() + 1) * Cos(2 * Pi * self.ffreq / self.frate));
        self.fconfig[1, 0] := (self.calcOmega() + 1) - (self.calcOmega() - 1) * Cos(2 * Pi * self.ffreq / self.frate) + 2 * Sqrt(self.calcOmega()) * self.calcAlpha();
      end;
      else begin
        self.fconfig[0, 2] := 0.0;
        self.fconfig[0, 1] := 0.0;
        self.fconfig[0, 0] := 0.0;
        self.fconfig[1, 2] := 0.0;
        self.fconfig[1, 1] := 0.0;
        self.fconfig[1, 0] := 0.0;
      end;
    end;
  except
    self.fconfig[0, 2] := 0.0;
    self.fconfig[0, 1] := 0.0;
    self.fconfig[0, 0] := 0.0;
    self.fconfig[1, 2] := 0.0;
    self.fconfig[1, 1] := 0.0;
    self.fconfig[1, 0] := 0.0;
  end;
end;

procedure TQMPBQF.calcSignal(const Input: Double; const Output: Double);
begin
  self.fsignal[0, 2] := self.fsignal[0, 1];
  self.fsignal[0, 1] := self.fsignal[0, 0];
  self.fsignal[0, 0] := Input;
  self.fsignal[1, 2] := self.fsignal[1, 1];
  self.fsignal[1, 1] := self.fsignal[1, 0];
  self.fsignal[1, 0] := Output;
end;

function TQMPBQF.Process(const Input: Double): Double;
begin
  try
    Result := ((Input * self.fconfig[0, 0] + self.fsignal[0, 0] * self.fconfig[0, 1] + self.fsignal[0, 1] * self.fconfig[0, 2]) - (self.fsignal[1, 0] * self.fconfig[1, 1] + self.fsignal[1, 1] * self.fconfig[1, 2])) / self.fconfig[1, 0];
  except
    Result := 0.0;
  end;
  self.calcSignal(Input, Result);
end;

function TQMPBQF.getBand(): TBand;
begin
  Result := self.fband;
end;

function TQMPBQF.getGain(): TGain;
begin
  Result := self.fgain;
end;

function TQMPBQF.getFilter(): TFilter;
begin
  Result := self.ffilter;
end;

function TQMPBQF.getAmp(): Double;
begin
  Result := self.famp;
end;

procedure TQMPBQF.setAmp(const Value: Double);
begin
  if((self.famp <> Value)) then begin
    self.famp := Value;
    self.calcConfig();
  end;
end;

function TQMPBQF.getFreq(): Double;
begin
  Result := self.ffreq;
end;

procedure TQMPBQF.setFreq(const Value: Double);
begin
  if((self.ffreq <> Value)) then begin
    self.ffreq := Value;
    self.calcConfig();
  end;
end;

function TQMPBQF.getRate(): Double;
begin
  Result := self.frate;
end;

procedure TQMPBQF.setRate(const Value: Double);
begin
  if((self.frate <> Value)) then begin
    self.frate := Value;
    self.calcConfig();
  end;
end;

function TQMPBQF.getWidth(): Double;
begin
  Result := self.fwidth;
end;

procedure TQMPBQF.setWidth(const Value: Double);
begin
  if((self.fwidth <> Value)) then begin
    self.fwidth := Value;
    self.calcConfig();
  end;
end;

begin
end.
