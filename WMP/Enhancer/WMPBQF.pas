unit
  WMPBQF;

interface

type
  TBand = (btQ, btSlope, btOctave, btSemitone);

type
  TGain = (gtDb, gtAmp);

type
  TFilter = (ftEqu, ftInv, ftLow, ftBand, ftBass, ftHigh, ftPeak, ftNotch, ftTreble);

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
  self.fsignal[0, 2] := 0.0;
  self.fsignal[0, 1] := 0.0;
  self.fsignal[0, 0] := 0.0;
  self.fsignal[1, 2] := 0.0;
  self.fsignal[1, 1] := 0.0;
  self.fsignal[1, 0] := 0.0;
end;

procedure TWMPBQF.Done();
begin
  self.fsignal[0, 2] := 0.0;
  self.fsignal[0, 1] := 0.0;
  self.fsignal[0, 0] := 0.0;
  self.fsignal[1, 2] := 0.0;
  self.fsignal[1, 1] := 0.0;
  self.fsignal[1, 0] := 0.0;
end;

function TWMPBQF.calcAmp(): Double;
begin
  try
    case (self.fgain) of
      gtDb: begin
        Result := Sqrt(Power(10, self.famp / 20));
      end;
      gtAmp: begin
        Result := Sqrt(self.famp);
      end;
    end;
  except
  end;
end;

function TWMPBQF.calcAlpha(): Double;
begin
  try
    case (self.fband) of
      btQ: begin
        Result := (Sin(2 * Pi * self.ffreq / self.frate) / 2) * (1 / self.fwidth);
      end;
      btSlope: begin
        Result := (Sin(2 * Pi * self.ffreq / self.frate) / 2) * Sqrt((self.calcAmp() + 1 / self.calcAmp()) * (1 / self.fwidth - 1) + 2);
      end;
      btOctave: begin
        Result := (Sin(2 * Pi * self.ffreq / self.frate) / 2) * 2 * Sinh((Ln(2) / 2) * (self.fwidth / 1) / (Sin(2 * Pi * self.ffreq / self.frate) / (2 * Pi * self.ffreq / self.frate)));
      end;
      btSemitone: begin
        Result := (Sin(2 * Pi * self.ffreq / self.frate) / 2) * 2 * Sinh((Ln(2) / 2) * (self.fwidth / 12) / (Sin(2 * Pi * self.ffreq / self.frate) / (2 * Pi * self.ffreq / self.frate)));
      end;
    end;
  except
  end;
end;

procedure TWMPBQF.calcConfig();
begin
  try
    case (self.ffilter) of
      ftEqu: begin
        self.fconfig[0, 2] := 1 - self.calcAlpha() * self.calcAmp();
        self.fconfig[0, 1] := -2 * Cos(2 * Pi * self.ffreq / self.frate);
        self.fconfig[0, 0] := 1 + self.calcAlpha() * self.calcAmp();
        self.fconfig[1, 2] := 1 - self.calcAlpha() / self.calcAmp();
        self.fconfig[1, 1] := -2 * Cos(2 * Pi * self.ffreq / self.frate);
        self.fconfig[1, 0] := 1 + self.calcAlpha() / self.calcAmp();
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
        self.fconfig[0, 2] := +1 * ((self.calcAmp() + 1) - (self.calcAmp() - 1) * Cos(2 * Pi * self.ffreq / self.frate) - 2 * Sqrt(self.calcAmp()) * self.calcAlpha()) * self.calcAmp();
        self.fconfig[0, 1] := +2 * ((self.calcAmp() - 1) - (self.calcAmp() + 1) * Cos(2 * Pi * self.ffreq / self.frate)) * self.calcAmp();
        self.fconfig[0, 0] := +1 * ((self.calcAmp() + 1) - (self.calcAmp() - 1) * Cos(2 * Pi * self.ffreq / self.frate) + 2 * Sqrt(self.calcAmp()) * self.calcAlpha()) * self.calcAmp();
        self.fconfig[1, 2] := +1 * ((self.calcAmp() + 1) + (self.calcAmp() - 1) * Cos(2 * Pi * self.ffreq / self.frate) - 2 * Sqrt(self.calcAmp()) * self.calcAlpha()) * 1;
        self.fconfig[1, 1] := -2 * ((self.calcAmp() - 1) + (self.calcAmp() + 1) * Cos(2 * Pi * self.ffreq / self.frate)) * 1;
        self.fconfig[1, 0] := +1 * ((self.calcAmp() + 1) + (self.calcAmp() - 1) * Cos(2 * Pi * self.ffreq / self.frate) + 2 * Sqrt(self.calcAmp()) * self.calcAlpha()) * 1;
      end;
      ftTreble: begin
        self.fconfig[0, 2] := +1 * ((self.calcAmp() + 1) + (self.calcAmp() - 1) * Cos(2 * Pi * self.ffreq / self.frate) - 2 * Sqrt(self.calcAmp()) * self.calcAlpha()) * self.calcAmp();
        self.fconfig[0, 1] := -2 * ((self.calcAmp() - 1) + (self.calcAmp() + 1) * Cos(2 * Pi * self.ffreq / self.frate)) * self.calcAmp();
        self.fconfig[0, 0] := +1 * ((self.calcAmp() + 1) + (self.calcAmp() - 1) * Cos(2 * Pi * self.ffreq / self.frate) + 2 * Sqrt(self.calcAmp()) * self.calcAlpha()) * self.calcAmp();
        self.fconfig[1, 2] := +1 * ((self.calcAmp() + 1) - (self.calcAmp() - 1) * Cos(2 * Pi * self.ffreq / self.frate) - 2 * Sqrt(self.calcAmp()) * self.calcAlpha()) * 1;
        self.fconfig[1, 1] := +2 * ((self.calcAmp() - 1) - (self.calcAmp() + 1) * Cos(2 * Pi * self.ffreq / self.frate)) * 1;
        self.fconfig[1, 0] := +1 * ((self.calcAmp() + 1) - (self.calcAmp() - 1) * Cos(2 * Pi * self.ffreq / self.frate) + 2 * Sqrt(self.calcAmp()) * self.calcAlpha()) * 1;
      end;
    end;
  except
  end;
end;

function TWMPBQF.Process(const Input: Double): Double;
begin
  try
    self.fsignal[0, 2] := self.fsignal[0, 1];
    self.fsignal[0, 1] := self.fsignal[0, 0];
    self.fsignal[0, 0] := Input;
    self.fsignal[1, 2] := self.fsignal[1, 1];
    self.fsignal[1, 1] := self.fsignal[1, 0];
    self.fsignal[1, 0] := ((self.fsignal[0, 0] * self.fconfig[0, 0] + self.fsignal[0, 1] * self.fconfig[0, 1] + self.fsignal[0, 2] * self.fconfig[0, 2]) - (self.fsignal[1, 1] * self.fconfig[1, 1] + self.fsignal[1, 2] * self.fconfig[1, 2])) / self.fconfig[1, 0];
  except
  end;
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
