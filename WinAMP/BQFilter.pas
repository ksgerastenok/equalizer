unit
  BQFilter;

interface

type
  TBand = (btQ, btSlope, btOctave, btSemitone);

type
  TGain = (gtDb, gtAmp);

type
  TFilter = (ftEqu, ftInv, ftLow, ftBand, ftBass, ftHigh, ftPeak, ftNotch, ftTreble);

type
  TBQFilter = class(TObject)
  private
    fband: TBand;
    fgain: TGain;
    ffilter: TFilter;
    famp: Double;
    ffreq: Double;
    frate: Double;
    fwidth: Double;
    falpha: Double;
    ffactor: Double;
    fenabled: Boolean;
    fconfig: array[0..1, 0..2] of Double;
    fsignal: array[0..1, 0..2] of Double;
    function getBand(): TBand;
    function getGain(): TGain;
    function getFilter(): TFilter;
    function getAmp(): Double;
    procedure setAmp(const value: Double);
    function getFreq(): Double;
    procedure setFreq(const value: Double);
    function getRate(): Double;
    procedure setRate(const value: Double);
    function getWidth(): Double;
    procedure setWidth(const value: Double);
    function getEnabled(): Boolean;
    procedure setEnabled(const value: Boolean);
  public
    constructor Create(const filter: TFilter; const band: TBand; const gain: TGain);
    destructor Destroy(); override;
    function Process(const input: Double): Double;
    property Band: TBand read getBand;
    property Gain: TGain read getGain;
    property Filter: TFilter read getFilter;
    property Amp: Double read getAmp write setAmp;
    property Freq: Double read getFreq write setFreq;
    property Rate: Double read getRate write setRate;
    property Width: Double read getWidth write setWidth;
    property Enabled: Boolean read getEnabled write setEnabled;
  end;

implementation

uses
  Math;

constructor TBQFilter.Create(const filter: TFilter; const band: TBand; const gain: TGain);
begin
  inherited Create();
  self.fband := band;
  self.fgain := gain;
  self.ffilter := filter;
  self.fenabled := False;
end;

destructor TBQFilter.Destroy();
begin
  self.fband := self.Band;
  self.fgain := self.Gain;
  self.ffilter := self.Filter;
  self.fenabled := self.Enabled;
  inherited Destroy();
end;

function TBQFilter.Process(const input: Double): Double;
begin
  try
    case(self.fgain) of
      gtDb: begin
        self.ffactor := Sqrt(Power(10, self.famp / 20));
      end;
      gtAmp: begin
        self.ffactor := Sqrt(self.famp);
      end;
      else begin
        self.ffactor := 0;
      end;
    end;
    case(self.fband) of
      btQ: begin
        self.falpha := (Sin(2 * Pi * self.ffreq / self.frate) / 2) * (1 / self.fwidth);
      end;
      btSlope: begin
        self.falpha := (Sin(2 * Pi * self.ffreq / self.frate) / 2) * Sqrt((self.ffactor + 1 / self.ffactor) * (1 / self.fwidth - 1) + 2);
      end;
      btOctave: begin
        self.falpha := (Sin(2 * Pi * self.ffreq / self.frate) / 2) * 2 * Sinh((Ln(2) / 2) * (self.fwidth / 1) / (Sin(2 * Pi * self.ffreq / self.frate) / (2 * Pi * self.ffreq / self.frate)));
      end;
      btSemitone: begin
        self.falpha := (Sin(2 * Pi * self.ffreq / self.frate) / 2) * 2 * Sinh((Ln(2) / 2) * (self.fwidth / 12) / (Sin(2 * Pi * self.ffreq / self.frate) / (2 * Pi * self.ffreq / self.frate)));
      end;
      else begin
        self.falpha := 0;
      end;
    end;
    case(self.ffilter) of
      ftEqu: begin
        self.fconfig[0, 0] := 1 + self.falpha * self.ffactor;
        self.fconfig[0, 1] := -2 * Cos(2 * Pi * self.ffreq / self.frate);
        self.fconfig[0, 2] := 1 - self.falpha * self.ffactor;
        self.fconfig[1, 0] := 1 + self.falpha / self.ffactor;
        self.fconfig[1, 1] := -2 * Cos(2 * Pi * self.ffreq / self.frate);
        self.fconfig[1, 2] := 1 - self.falpha / self.ffactor;
      end;
      ftInv: begin
        self.fconfig[0, 0] := 1 - self.falpha;
        self.fconfig[0, 1] := -2 * Cos(2 * Pi * self.ffreq / self.frate);
        self.fconfig[0, 2] := 1 + self.falpha;
        self.fconfig[1, 0] := 1 + self.falpha;
        self.fconfig[1, 1] := -2 * Cos(2 * Pi * self.ffreq / self.frate);
        self.fconfig[1, 2] := 1 - self.falpha;
      end;
      ftLow: begin
        self.fconfig[0, 0] := (1 - Cos(2 * Pi * self.ffreq / self.frate)) / 2;
        self.fconfig[0, 1] := (1 - Cos(2 * Pi * self.ffreq / self.frate)) / +1;
        self.fconfig[0, 2] := (1 - Cos(2 * Pi * self.ffreq / self.frate)) / 2;
        self.fconfig[1, 0] := 1 + self.falpha;
        self.fconfig[1, 1] := -2 * Cos(2 * Pi * self.ffreq / self.frate);
        self.fconfig[1, 2] := 1 - self.falpha;
      end;
      ftHigh: begin
        self.fconfig[0, 0] := (1 + Cos(2 * Pi * self.ffreq / self.frate)) / 2;
        self.fconfig[0, 1] := (1 + Cos(2 * Pi * self.ffreq / self.frate)) / -1;
        self.fconfig[0, 2] := (1 + Cos(2 * Pi * self.ffreq / self.frate)) / 2;
        self.fconfig[1, 0] := 1 + self.falpha;
        self.fconfig[1, 1] := -2 * Cos(2 * Pi * self.ffreq / self.frate);
        self.fconfig[1, 2] := 1 - self.falpha;
      end;
      ftPeak: begin
        self.fconfig[0, 0] := +1 * Sin(2 * Pi * self.ffreq / self.frate) / 2;
        self.fconfig[0, 1] := 0;
        self.fconfig[0, 2] := -1 * Sin(2 * Pi * self.ffreq / self.frate) / 2;
        self.fconfig[1, 0] := 1 + self.falpha;
        self.fconfig[1, 1] := -2 * Cos(2 * Pi * self.ffreq / self.frate);
        self.fconfig[1, 2] := 1 - self.falpha;
      end;
      ftBand: begin
        self.fconfig[0, 0] := +1 * self.falpha;
        self.fconfig[0, 1] := 0;
        self.fconfig[0, 2] := -1 * self.falpha;
        self.fconfig[1, 0] := 1 + self.falpha;
        self.fconfig[1, 1] := -2 * Cos(2 * Pi * self.ffreq / self.frate);
        self.fconfig[1, 2] := 1 - self.falpha;
      end;
      ftNotch: begin
        self.fconfig[0, 0] := 1;
        self.fconfig[0, 1] := -2 * Cos(2 * Pi * self.ffreq / self.frate);
        self.fconfig[0, 2] := 1;
        self.fconfig[1, 0] := 1 + self.falpha;
        self.fconfig[1, 0] := -2 * Cos(2 * Pi * self.ffreq / self.frate);
        self.fconfig[1, 0] := 1 - self.falpha;
      end;
      ftBass: begin
        self.fconfig[0, 0] := self.ffactor * ((self.ffactor + 1) - (self.ffactor - 1) * Cos(2 * Pi * self.ffreq / self.frate) + 2 * Sqrt(self.ffactor) * self.falpha);
        self.fconfig[0, 1] := +2 * self.ffactor * ((self.ffactor - 1) - (self.ffactor + 1) * Cos(2 * Pi * self.ffreq / self.frate));
        self.fconfig[0, 2] := self.ffactor * ((self.ffactor + 1) - (self.ffactor - 1) * Cos(2 * Pi * self.ffreq / self.frate) - 2 * Sqrt(self.ffactor) * self.falpha);
        self.fconfig[1, 0] := (self.ffactor + 1) + (self.ffactor - 1) * Cos(2 * Pi * self.ffreq / self.frate) + 2 * Sqrt(self.ffactor) * self.falpha;
        self.fconfig[1, 1] := -2 *      1       * ((self.ffactor - 1) + (self.ffactor + 1) * Cos(2 * Pi * self.ffreq / self.frate));
        self.fconfig[1, 2] := (self.ffactor + 1) + (self.ffactor - 1) * Cos(2 * Pi * self.ffreq / self.frate) - 2 * Sqrt(self.ffactor) * self.falpha;
      end;
      ftTreble: begin
        self.fconfig[0, 0] := self.ffactor * ((self.ffactor + 1) + (self.ffactor - 1) * Cos(2 * Pi * self.ffreq / self.frate) + 2 * Sqrt(self.ffactor) * self.falpha);
        self.fconfig[0, 1] := -2 * self.ffactor * ((self.ffactor - 1) + (self.ffactor + 1) * Cos(2 * Pi * self.ffreq / self.frate));
        self.fconfig[0, 2] := self.ffactor * ((self.ffactor + 1) + (self.ffactor - 1) * Cos(2 * Pi * self.ffreq / self.frate) - 2 * Sqrt(self.ffactor) * self.falpha);
        self.fconfig[1, 0] := (self.ffactor + 1) - (self.ffactor - 1) * Cos(2 * Pi * self.ffreq / self.frate) + 2 * Sqrt(self.ffactor) * self.falpha;
        self.fconfig[1, 1] := +2 *      1       * ((self.ffactor - 1) - (self.ffactor + 1) * Cos(2 * Pi * self.ffreq / self.frate));
        self.fconfig[1, 2] := (self.ffactor + 1) - (self.ffactor - 1) * Cos(2 * Pi * self.ffreq / self.frate) - 2 * Sqrt(self.ffactor) * self.falpha;
      end;
      else begin
        self.fconfig[0, 0] := 0;
        self.fconfig[0, 1] := 0;
        self.fconfig[0, 2] := 0;
        self.fconfig[1, 0] := 0;
        self.fconfig[1, 1] := 0;
        self.fconfig[1, 2] := 0;
      end;
    end;
    case(self.fenabled) of
      True: begin
        self.fsignal[0, 2] := self.fsignal[0, 1];
        self.fsignal[0, 1] := self.fsignal[0, 0];
        self.fsignal[0, 0] := input;
        self.fsignal[1, 2] := self.fsignal[1, 1];
        self.fsignal[1, 1] := self.fsignal[1, 0];
        self.fsignal[1, 0] := ((self.fsignal[0, 0] * self.fconfig[0, 0] + self.fsignal[0, 1] * self.fconfig[0, 1] + self.fsignal[0, 2] * self.fconfig[0, 2]) - (self.fsignal[1, 1] * self.fconfig[1, 1] + self.fsignal[1, 2] * self.fconfig[1, 2])) / self.fconfig[1, 0];
      end;
      False: begin
        self.fsignal[0, 2] := self.fsignal[0, 1];
        self.fsignal[0, 1] := self.fsignal[0, 0];
        self.fsignal[0, 0] := input;
        self.fsignal[1, 2] := self.fsignal[1, 1];
        self.fsignal[1, 1] := self.fsignal[1, 0];
        self.fsignal[1, 0] := input;
      end;
      else begin
        self.fsignal[0, 2] := 0;
        self.fsignal[0, 1] := 0;
        self.fsignal[0, 0] := 0;
        self.fsignal[1, 2] := 0;
        self.fsignal[1, 1] := 0;
        self.fsignal[1, 0] := 0;
      end;
    end;
  except
    self.falpha := 0;
    self.ffactor := 0;
    self.fconfig[0, 0] := 0;
    self.fconfig[0, 1] := 0;
    self.fconfig[0, 2] := 0;
    self.fconfig[1, 0] := 0;
    self.fconfig[1, 1] := 0;
    self.fconfig[1, 2] := 0;
    self.fsignal[0, 2] := 0;
    self.fsignal[0, 1] := 0;
    self.fsignal[0, 0] := 0;
    self.fsignal[1, 2] := 0;
    self.fsignal[1, 1] := 0;
    self.fsignal[1, 0] := 0;
  end;

  Result := self.fsignal[1, 0];
end;

function TBQFilter.getBand(): TBand;
begin
  Result := self.fband;
end;

function TBQFilter.getGain(): TGain;
begin
  Result := self.fgain;
end;

function TBQFilter.getFilter(): TFilter;
begin
  Result := self.ffilter;
end;

function TBQFilter.getAmp(): Double;
begin
  Result := self.famp;
end;

procedure TBQFilter.setAmp(const value: Double);
begin
  self.famp := value;
end;

function TBQFilter.getFreq(): Double;
begin
  Result := self.ffreq;
end;

procedure TBQFilter.setFreq(const value: Double);
begin
  self.ffreq := value;
end;

function TBQFilter.getRate(): Double;
begin
  Result := self.frate;
end;

procedure TBQFilter.setRate(const value: Double);
begin
  self.frate := value;
end;

function TBQFilter.getWidth(): Double;
begin
  Result := self.fwidth;
end;

procedure TBQFilter.setWidth(const value: Double);
begin
  self.fwidth := value;
end;

function TBQFilter.getEnabled(): Boolean;
begin
  Result := self.fenabled;
end;

procedure TBQFilter.setEnabled(const value: Boolean);
begin
  self.fenabled := value;
end;

begin
end.
