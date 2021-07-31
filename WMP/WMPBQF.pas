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
    var fomega: Double;
    var falpha: Double;
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

function TWMPBQF.Process(const Input: Double): Double;
begin
  try
    case(self.fgain) of
      gtDb: begin
        self.fomega := Sqrt(Power(10, self.famp / 20));
      end;
      gtAmp: begin
        self.fomega := Sqrt(self.famp);
      end;
      else begin
        self.fomega := 0.0;
      end;
    end;
  except
    self.fomega := 0.0;
  end;
  try
    case(self.fband) of
      btQ: begin
        self.falpha := (Sin(2 * Pi * self.ffreq / self.frate) / 2) * (1 / self.fwidth);
      end;
      btSlope: begin
        self.falpha := (Sin(2 * Pi * self.ffreq / self.frate) / 2) * Sqrt((self.fomega + 1 / self.fomega) * (1 / self.fwidth - 1) + 2);
      end;
      btOctave: begin
        self.falpha := (Sin(2 * Pi * self.ffreq / self.frate) / 2) * 2 * Sinh((Ln(2) / 2) * (self.fwidth / 1) / (Sin(2 * Pi * self.ffreq / self.frate) / (2 * Pi * self.ffreq / self.frate)));
      end;
      btSemitone: begin
        self.falpha := (Sin(2 * Pi * self.ffreq / self.frate) / 2) * 2 * Sinh((Ln(2) / 2) * (self.fwidth / 12) / (Sin(2 * Pi * self.ffreq / self.frate) / (2 * Pi * self.ffreq / self.frate)));
      end;
      else begin
        self.falpha := 0.0;
      end;
    end;
  except
    self.falpha := 0.0;
  end;
  try
    case(self.ffilter) of
      ftEqu: begin
        self.fconfig[0, 2] := 1 - self.falpha * self.fomega;
        self.fconfig[0, 1] := -2 * Cos(2 * Pi * self.ffreq / self.frate);
        self.fconfig[0, 0] := 1 + self.falpha * self.fomega;
        self.fconfig[1, 2] := 1 - self.falpha / self.fomega;
        self.fconfig[1, 1] := -2 * Cos(2 * Pi * self.ffreq / self.frate);
        self.fconfig[1, 0] := 1 + self.falpha / self.fomega;
      end;
      ftInv: begin
        self.fconfig[0, 2] := 1 + self.falpha;
        self.fconfig[0, 1] := -2 * Cos(2 * Pi * self.ffreq / self.frate);
        self.fconfig[0, 0] := 1 - self.falpha;
        self.fconfig[1, 2] := 1 - self.falpha;
        self.fconfig[1, 1] := -2 * Cos(2 * Pi * self.ffreq / self.frate);
        self.fconfig[1, 0] := 1 + self.falpha;
      end;
      ftLow: begin
        self.fconfig[0, 2] := (1 - Cos(2 * Pi * self.ffreq / self.frate)) / 2;
        self.fconfig[0, 1] := (1 - Cos(2 * Pi * self.ffreq / self.frate)) / +1;
        self.fconfig[0, 0] := (1 - Cos(2 * Pi * self.ffreq / self.frate)) / 2;
        self.fconfig[1, 2] := 1 - self.falpha;
        self.fconfig[1, 1] := -2 * Cos(2 * Pi * self.ffreq / self.frate);
        self.fconfig[1, 0] := 1 + self.falpha;
      end;
      ftHigh: begin
        self.fconfig[0, 2] := (1 + Cos(2 * Pi * self.ffreq / self.frate)) / 2;
        self.fconfig[0, 1] := (1 + Cos(2 * Pi * self.ffreq / self.frate)) / -1;
        self.fconfig[0, 0] := (1 + Cos(2 * Pi * self.ffreq / self.frate)) / 2;
        self.fconfig[1, 2] := 1 - self.falpha;
        self.fconfig[1, 1] := -2 * Cos(2 * Pi * self.ffreq / self.frate);
        self.fconfig[1, 0] := 1 + self.falpha;
      end;
      ftPeak: begin
        self.fconfig[0, 2] := -1 * Sin(2 * Pi * self.ffreq / self.frate) / 2;
        self.fconfig[0, 1] := 0.0;
        self.fconfig[0, 0] := +1 * Sin(2 * Pi * self.ffreq / self.frate) / 2;
        self.fconfig[1, 2] := 1 - self.falpha;
        self.fconfig[1, 1] := -2 * Cos(2 * Pi * self.ffreq / self.frate);
        self.fconfig[1, 0] := 1 + self.falpha;
      end;
      ftBand: begin
        self.fconfig[0, 2] := -1 * self.falpha;
        self.fconfig[0, 1] := 0.0;
        self.fconfig[0, 0] := +1 * self.falpha;
        self.fconfig[1, 2] := 1 - self.falpha;
        self.fconfig[1, 1] := -2 * Cos(2 * Pi * self.ffreq / self.frate);
        self.fconfig[1, 0] := 1 + self.falpha;
      end;
      ftNotch: begin
        self.fconfig[0, 2] := 1;
        self.fconfig[0, 1] := -2 * Cos(2 * Pi * self.ffreq / self.frate);
        self.fconfig[0, 0] := 1;
        self.fconfig[1, 2] := 1 - self.falpha;
        self.fconfig[1, 1] := -2 * Cos(2 * Pi * self.ffreq / self.frate);
        self.fconfig[1, 0] := 1 + self.falpha;
      end;
      ftBass: begin
        self.fconfig[0, 2] := self.fomega * ((self.fomega + 1) - (self.fomega - 1) * Cos(2 * Pi * self.ffreq / self.frate) - 2 * Sqrt(self.fomega) * self.falpha);
        self.fconfig[0, 1] := +2 * self.fomega * ((self.fomega - 1) - (self.fomega + 1) * Cos(2 * Pi * self.ffreq / self.frate));
        self.fconfig[0, 0] := self.fomega * ((self.fomega + 1) - (self.fomega - 1) * Cos(2 * Pi * self.ffreq / self.frate) + 2 * Sqrt(self.fomega) * self.falpha);
        self.fconfig[1, 2] := (self.fomega + 1) + (self.fomega - 1) * Cos(2 * Pi * self.ffreq / self.frate) - 2 * Sqrt(self.fomega) * self.falpha;
        self.fconfig[1, 1] := -2 *      1      * ((self.fomega - 1) + (self.fomega + 1) * Cos(2 * Pi * self.ffreq / self.frate));
        self.fconfig[1, 0] := (self.fomega + 1) + (self.fomega - 1) * Cos(2 * Pi * self.ffreq / self.frate) + 2 * Sqrt(self.fomega) * self.falpha;
      end;
      ftTreble: begin
        self.fconfig[0, 2] := self.fomega * ((self.fomega + 1) + (self.fomega - 1) * Cos(2 * Pi * self.ffreq / self.frate) - 2 * Sqrt(self.fomega) * self.falpha);
        self.fconfig[0, 1] := -2 * self.fomega * ((self.fomega - 1) + (self.fomega + 1) * Cos(2 * Pi * self.ffreq / self.frate));
        self.fconfig[0, 0] := self.fomega * ((self.fomega + 1) + (self.fomega - 1) * Cos(2 * Pi * self.ffreq / self.frate) + 2 * Sqrt(self.fomega) * self.falpha);
        self.fconfig[1, 2] := (self.fomega + 1) - (self.fomega - 1) * Cos(2 * Pi * self.ffreq / self.frate) - 2 * Sqrt(self.fomega) * self.falpha;
        self.fconfig[1, 1] := +2 *      1      * ((self.fomega - 1) - (self.fomega + 1) * Cos(2 * Pi * self.ffreq / self.frate));
        self.fconfig[1, 0] := (self.fomega + 1) - (self.fomega - 1) * Cos(2 * Pi * self.ffreq / self.frate) + 2 * Sqrt(self.fomega) * self.falpha;
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
  try
    Result := ((Input * self.fconfig[0, 0] + self.fsignal[0, 0] * self.fconfig[0, 1] + self.fsignal[0, 1] * self.fconfig[0, 2]) - (self.fsignal[1, 0] * self.fconfig[1, 1] + self.fsignal[1, 1] * self.fconfig[1, 2])) / self.fconfig[1, 0];
  except
    Result := 0.0;
  end;
  self.fsignal[0, 2] := self.fsignal[0, 1];
  self.fsignal[0, 1] := self.fsignal[0, 0];
  self.fsignal[0, 0] := Input;
  self.fsignal[1, 2] := self.fsignal[1, 1];
  self.fsignal[1, 1] := self.fsignal[1, 0];
  self.fsignal[1, 0] := Result;
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
  self.famp := Value;
end;

function TWMPBQF.getFreq(): Double;
begin
  Result := self.ffreq;
end;

procedure TWMPBQF.setFreq(const Value: Double);
begin
  self.ffreq := Value;
end;

function TWMPBQF.getRate(): Double;
begin
  Result := self.frate;
end;

procedure TWMPBQF.setRate(const Value: Double);
begin
  self.frate := Value;
end;

function TWMPBQF.getWidth(): Double;
begin
  Result := self.fwidth;
end;

procedure TWMPBQF.setWidth(const Value: Double);
begin
  self.fwidth := Value;
end;

begin
end.
