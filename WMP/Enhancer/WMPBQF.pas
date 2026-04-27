unit
  WMPBQF;

interface

type
  TGain = (gtDb, gtAmp);

type
  TBand = (btQ, btOctave, btSlope);

type
  TFilter = (ftLow, ftHigh, ftPeak, ftBand, ftNotch, ftAll, ftEqu, ftBass, ftTreble);

type
  TTransform = (ttTDI, ttSVF, ttZDF);

type
  TWMPBQF = record
  private
    var fgain: TGain;
    var fband: TBand;
    var ffilter: TFilter;
    var ftransform: TTransform;
    var fconfig: array[0..1, 0..2] of Double;
    var fsignal: array[0..1, 0..2] of Double;
    var famp: Double;
    var ffreq: Double;
    var frate: Double;
    var fwidth: Double;
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
    function calcAlpha(): Double;
    function calcOmega(): Double;
    procedure calcConfig();
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

procedure TWMPBQF.Init(const Transform: TTransform; const Filter: TFilter; const Band: TBand; const Gain: TGain);
begin
  self.fband := Band;
  self.fgain := Gain;
  self.ffilter := Filter;
  self.ftransform := Transform;
end;

procedure TWMPBQF.Done();
begin
end;

function TWMPBQF.calcOmega(): Double;
begin
  Result := (2.0 * Pi * self.ffreq / self.frate);
end;

function TWMPBQF.calcAmp(): Double;
begin
  case (self.fgain) of
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

function TWMPBQF.calcAlpha(): Double;
begin
  case (self.fband) of
    btQ: begin
      Result := 1.0 / self.fwidth;
    end;
    btOctave: begin
      Result := 2.0 * Sinh((Ln(2.0) / 2.0) * self.fwidth / (Sin(self.calcOmega()) / self.calcOmega()));
    end;
    btSlope: begin
      Result := Sqrt(Sqrt(self.calcAmp()) * (1.0 / self.calcAmp() + 1.0) * (1.0 / self.fwidth - 1.0) + 2.0);
    end;
    else begin
      Result := 0.0;
    end;
  end;
end;

procedure TWMPBQF.calcConfig();
begin
  case (self.ftransform) of
    ttTDI: begin
      case (self.ffilter) of
        ftLow: begin
          self.fconfig[0, 2] :=  1.0 * 0.5 * (1.0 - Cos(self.calcOmega()));
          self.fconfig[0, 1] := +2.0 * 0.5 * (1.0 - Cos(self.calcOmega()));
          self.fconfig[0, 0] :=  1.0 * 0.5 * (1.0 - Cos(self.calcOmega()));
          self.fconfig[1, 2] :=  1.0 - 0.5 * Sin(self.calcOmega()) * self.calcAlpha();
          self.fconfig[1, 1] := -2.0 * 1.0 * Cos(self.calcOmega());
          self.fconfig[1, 0] :=  1.0 + 0.5 * Sin(self.calcOmega()) * self.calcAlpha();
        end;
        ftHigh: begin
          self.fconfig[0, 2] :=  1.0 * 0.5 * (1.0 + Cos(self.calcOmega()));
          self.fconfig[0, 1] := -2.0 * 0.5 * (1.0 + Cos(self.calcOmega()));
          self.fconfig[0, 0] :=  1.0 * 0.5 * (1.0 + Cos(self.calcOmega()));
          self.fconfig[1, 2] :=  1.0 - 0.5 * Sin(self.calcOmega()) * self.calcAlpha();
          self.fconfig[1, 1] := -2.0 * 1.0 * Cos(self.calcOmega());
          self.fconfig[1, 0] :=  1.0 + 0.5 * Sin(self.calcOmega()) * self.calcAlpha();
        end;
        ftPeak: begin
          self.fconfig[0, 2] :=  0.0 - 0.5 * Sin(self.calcOmega()) *       1.0       ;
          self.fconfig[0, 1] :=  0.0;
          self.fconfig[0, 0] :=  0.0 + 0.5 * Sin(self.calcOmega()) *       1.0       ;
          self.fconfig[1, 2] :=  1.0 - 0.5 * Sin(self.calcOmega()) * self.calcAlpha();
          self.fconfig[1, 1] := -2.0 * 1.0 * Cos(self.calcOmega());
          self.fconfig[1, 0] :=  1.0 + 0.5 * Sin(self.calcOmega()) * self.calcAlpha();
        end;
        ftBand: begin
          self.fconfig[0, 2] :=  0.0 - 0.5 * Sin(self.calcOmega()) * self.calcAlpha();
          self.fconfig[0, 1] :=  0.0;
          self.fconfig[0, 0] :=  0.0 + 0.5 * Sin(self.calcOmega()) * self.calcAlpha();
          self.fconfig[1, 2] :=  1.0 - 0.5 * Sin(self.calcOmega()) * self.calcAlpha();
          self.fconfig[1, 1] := -2.0 * 1.0 * Cos(self.calcOmega());
          self.fconfig[1, 0] :=  1.0 + 0.5 * Sin(self.calcOmega()) * self.calcAlpha();
        end;
        ftNotch: begin
          self.fconfig[0, 2] :=  1.0;
          self.fconfig[0, 1] := -2.0 * 1.0 * Cos(self.calcOmega());
          self.fconfig[0, 0] :=  1.0;
          self.fconfig[1, 2] :=  1.0 - 0.5 * Sin(self.calcOmega()) * self.calcAlpha();
          self.fconfig[1, 1] := -2.0 * 1.0 * Cos(self.calcOmega());
          self.fconfig[1, 0] :=  1.0 + 0.5 * Sin(self.calcOmega()) * self.calcAlpha();
        end;
        ftAll: begin
          self.fconfig[0, 2] :=  1.0 + 0.5 * Sin(self.calcOmega()) * self.calcAlpha();
          self.fconfig[0, 1] := -2.0 * 1.0 * Cos(self.calcOmega());
          self.fconfig[0, 0] :=  1.0 - 0.5 * Sin(self.calcOmega()) * self.calcAlpha();
          self.fconfig[1, 2] :=  1.0 - 0.5 * Sin(self.calcOmega()) * self.calcAlpha();
          self.fconfig[1, 1] := -2.0 * 1.0 * Cos(self.calcOmega());
          self.fconfig[1, 0] :=  1.0 + 0.5 * Sin(self.calcOmega()) * self.calcAlpha();
        end;
        ftEqu: begin
          self.fconfig[0, 2] :=  1.0 - 0.5 * Sin(self.calcOmega()) * self.calcAlpha() * Sqrt(self.calcAmp());
          self.fconfig[0, 1] := -2.0 * 1.0 * Cos(self.calcOmega());
          self.fconfig[0, 0] :=  1.0 + 0.5 * Sin(self.calcOmega()) * self.calcAlpha() * Sqrt(self.calcAmp());
          self.fconfig[1, 2] :=  1.0 - 0.5 * Sin(self.calcOmega()) * self.calcAlpha() / Sqrt(self.calcAmp());
          self.fconfig[1, 1] := -2.0 * 1.0 * Cos(self.calcOmega());
          self.fconfig[1, 0] :=  1.0 + 0.5 * Sin(self.calcOmega()) * self.calcAlpha() / Sqrt(self.calcAmp());
        end;
        ftBass: begin
          self.fconfig[0, 2] :=  1.0 * Sqrt(self.calcAmp()) * ((Sqrt(self.calcAmp()) + 1.0) - (Sqrt(self.calcAmp()) - 1.0) * Cos(self.calcOmega()) - Sqrt(Sqrt(self.calcAmp())) * Sin(self.calcOmega()) * self.calcAlpha());
          self.fconfig[0, 1] := +2.0 * Sqrt(self.calcAmp()) * ((Sqrt(self.calcAmp()) - 1.0) - (Sqrt(self.calcAmp()) + 1.0) * Cos(self.calcOmega()));
          self.fconfig[0, 0] :=  1.0 * Sqrt(self.calcAmp()) * ((Sqrt(self.calcAmp()) + 1.0) - (Sqrt(self.calcAmp()) - 1.0) * Cos(self.calcOmega()) + Sqrt(Sqrt(self.calcAmp())) * Sin(self.calcOmega()) * self.calcAlpha());
          self.fconfig[1, 2] :=  1.0 *          1.0         * ((Sqrt(self.calcAmp()) + 1.0) + (Sqrt(self.calcAmp()) - 1.0) * Cos(self.calcOmega()) - Sqrt(Sqrt(self.calcAmp())) * Sin(self.calcOmega()) * self.calcAlpha());
          self.fconfig[1, 1] := -2.0 *          1.0         * ((Sqrt(self.calcAmp()) - 1.0) + (Sqrt(self.calcAmp()) + 1.0) * Cos(self.calcOmega()));
          self.fconfig[1, 0] :=  1.0 *          1.0         * ((Sqrt(self.calcAmp()) + 1.0) + (Sqrt(self.calcAmp()) - 1.0) * Cos(self.calcOmega()) + Sqrt(Sqrt(self.calcAmp())) * Sin(self.calcOmega()) * self.calcAlpha());
        end;
        ftTreble: begin
          self.fconfig[0, 2] :=  1.0 * Sqrt(self.calcAmp()) * ((Sqrt(self.calcAmp()) + 1.0) + (Sqrt(self.calcAmp()) - 1.0) * Cos(self.calcOmega()) - Sqrt(Sqrt(self.calcAmp())) * Sin(self.calcOmega()) * self.calcAlpha());
          self.fconfig[0, 1] := -2.0 * Sqrt(self.calcAmp()) * ((Sqrt(self.calcAmp()) - 1.0) + (Sqrt(self.calcAmp()) + 1.0) * Cos(self.calcOmega()));
          self.fconfig[0, 0] :=  1.0 * Sqrt(self.calcAmp()) * ((Sqrt(self.calcAmp()) + 1.0) + (Sqrt(self.calcAmp()) - 1.0) * Cos(self.calcOmega()) + Sqrt(Sqrt(self.calcAmp())) * Sin(self.calcOmega()) * self.calcAlpha());
          self.fconfig[1, 2] :=  1.0 *          1.0         * ((Sqrt(self.calcAmp()) + 1.0) - (Sqrt(self.calcAmp()) - 1.0) * Cos(self.calcOmega()) - Sqrt(Sqrt(self.calcAmp())) * Sin(self.calcOmega()) * self.calcAlpha());
          self.fconfig[1, 1] := +2.0 *          1.0         * ((Sqrt(self.calcAmp()) - 1.0) - (Sqrt(self.calcAmp()) + 1.0) * Cos(self.calcOmega()));
          self.fconfig[1, 0] :=  1.0 *          1.0         * ((Sqrt(self.calcAmp()) + 1.0) - (Sqrt(self.calcAmp()) - 1.0) * Cos(self.calcOmega()) + Sqrt(Sqrt(self.calcAmp())) * Sin(self.calcOmega()) * self.calcAlpha());
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
    end;
    ttSVF: begin
      case (self.ffilter) of
        ftLow: begin
          self.fconfig[0, 2] :=  (1.0 * Sqr(Tan(0.5 * self.calcOmega())));
          self.fconfig[0, 1] := +2.0 * Sqr(Tan(0.5 * self.calcOmega()));
          self.fconfig[0, 0] :=  (1.0 * Sqr(Tan(0.5 * self.calcOmega())));
          self.fconfig[1, 2] :=  (1.0 - Tan(0.5 * self.calcOmega()) * self.calcAlpha() + Sqr(Tan(0.5 * self.calcOmega())));
          self.fconfig[1, 1] := +2.0 * (Sqr(Tan(0.5 * self.calcOmega())) - 1.0);
          self.fconfig[1, 0] :=  (1.0 + Tan(0.5 * self.calcOmega()) * self.calcAlpha() + Sqr(Tan(0.5 * self.calcOmega())));
        end;
        ftHigh: begin
          self.fconfig[0, 2] :=  (1.0);
          self.fconfig[0, 1] := -2.0;
          self.fconfig[0, 0] :=  (1.0);
          self.fconfig[1, 2] :=  (1.0 - Tan(0.5 * self.calcOmega()) * self.calcAlpha() + Sqr(Tan(0.5 * self.calcOmega())));
          self.fconfig[1, 1] := +2.0 * (Sqr(Tan(0.5 * self.calcOmega())) - 1.0);
          self.fconfig[1, 0] :=  (1.0 + Tan(0.5 * self.calcOmega()) * self.calcAlpha() + Sqr(Tan(0.5 * self.calcOmega())));
        end;
        ftPeak: begin
          self.fconfig[0, 2] :=  (0.0 - Tan(0.5 * self.calcOmega()) *       1.0       );
          self.fconfig[0, 1] :=  0.0;
          self.fconfig[0, 0] :=  (0.0 + Tan(0.5 * self.calcOmega()) *       1.0       );
          self.fconfig[1, 2] :=  (1.0 - Tan(0.5 * self.calcOmega()) * self.calcAlpha() + Sqr(Tan(0.5 * self.calcOmega())));
          self.fconfig[1, 1] := +2.0 * (Sqr(Tan(0.5 * self.calcOmega())) - 1.0);
          self.fconfig[1, 0] :=  (1.0 + Tan(0.5 * self.calcOmega()) * self.calcAlpha() + Sqr(Tan(0.5 * self.calcOmega())));
        end;
        ftBand: begin
          self.fconfig[0, 2] :=  (0.0 - Tan(0.5 * self.calcOmega()) * self.calcAlpha());
          self.fconfig[0, 1] :=  0.0;
          self.fconfig[0, 0] :=  (0.0 + Tan(0.5 * self.calcOmega()) * self.calcAlpha());
          self.fconfig[1, 2] :=  (1.0 - Tan(0.5 * self.calcOmega()) * self.calcAlpha() + Sqr(Tan(0.5 * self.calcOmega())));
          self.fconfig[1, 1] := +2.0 * (Sqr(Tan(0.5 * self.calcOmega())) - 1.0);
          self.fconfig[1, 0] :=  (1.0 + Tan(0.5 * self.calcOmega()) * self.calcAlpha() + Sqr(Tan(0.5 * self.calcOmega())));
        end;
        ftNotch: begin
          self.fconfig[0, 2] :=  (1.0 + (Sqr(Tan(0.5 * self.calcOmega()))));
          self.fconfig[0, 1] := +2.0 * (Sqr(Tan(0.5 * self.calcOmega())) - 1.0);
          self.fconfig[0, 0] :=  (1.0 + (Sqr(Tan(0.5 * self.calcOmega()))));
          self.fconfig[1, 2] :=  (1.0 - Tan(0.5 * self.calcOmega()) * self.calcAlpha() + Sqr(Tan(0.5 * self.calcOmega())));
          self.fconfig[1, 1] := +2.0 * (Sqr(Tan(0.5 * self.calcOmega())) - 1.0);
          self.fconfig[1, 0] :=  (1.0 + Tan(0.5 * self.calcOmega()) * self.calcAlpha() + Sqr(Tan(0.5 * self.calcOmega())));
        end;
        ftAll: begin
          self.fconfig[0, 2] :=  (1.0 + Tan(0.5 * self.calcOmega()) * self.calcAlpha() + Sqr(Tan(0.5 * self.calcOmega())));
          self.fconfig[0, 1] := +2.0 * (Sqr(Tan(0.5 * self.calcOmega())) - 1.0);
          self.fconfig[0, 0] :=  (1.0 - Tan(0.5 * self.calcOmega()) * self.calcAlpha() + Sqr(Tan(0.5 * self.calcOmega())));
          self.fconfig[1, 2] :=  (1.0 - Tan(0.5 * self.calcOmega()) * self.calcAlpha() + Sqr(Tan(0.5 * self.calcOmega())));
          self.fconfig[1, 1] := +2.0 * (Sqr(Tan(0.5 * self.calcOmega())) - 1.0);
          self.fconfig[1, 0] :=  (1.0 + Tan(0.5 * self.calcOmega()) * self.calcAlpha() + Sqr(Tan(0.5 * self.calcOmega())));
        end;
        ftEqu: begin
          self.fconfig[0, 2] :=  (1.0 - Tan(0.5 * self.calcOmega()) * self.calcAlpha() * self.calcAmp() + Sqr(Tan(0.5 * self.calcOmega())));
          self.fconfig[0, 1] := +2.0 * (Sqr(Tan(0.5 * self.calcOmega())) - 1.0);
          self.fconfig[0, 0] :=  (1.0 + Tan(0.5 * self.calcOmega()) * self.calcAlpha() * self.calcAmp() + Sqr(Tan(0.5 * self.calcOmega())));
          self.fconfig[1, 2] :=  (1.0 - Tan(0.5 * self.calcOmega()) * self.calcAlpha() *      1.0       + Sqr(Tan(0.5 * self.calcOmega())));
          self.fconfig[1, 1] := +2.0 * (Sqr(Tan(0.5 * self.calcOmega())) - 1.0);
          self.fconfig[1, 0] :=  (1.0 + Tan(0.5 * self.calcOmega()) * self.calcAlpha() *      1.0       + Sqr(Tan(0.5 * self.calcOmega())));
        end;
        ftBass: begin
          self.fconfig[0, 2] :=  (      1.0      - Tan(0.5 * self.calcOmega()) * self.calcAlpha() *         1.0          + Sqr(Tan(0.5 * self.calcOmega()))) /      1.0      ;
          self.fconfig[0, 1] := +2.0 * (Sqr(Tan(0.5 * self.calcOmega())) -      1.0      ) /      1.0      ;
          self.fconfig[0, 0] :=  (      1.0      + Tan(0.5 * self.calcOmega()) * self.calcAlpha() *         1.0          + Sqr(Tan(0.5 * self.calcOmega()))) /      1.0      ;
          self.fconfig[1, 2] :=  (self.calcAmp() - Tan(0.5 * self.calcOmega()) * self.calcAlpha() * Sqrt(self.calcAmp()) + Sqr(Tan(0.5 * self.calcOmega()))) / self.calcAmp();
          self.fconfig[1, 1] := +2.0 * (Sqr(Tan(0.5 * self.calcOmega())) - self.calcAmp()) / self.calcAmp();
          self.fconfig[1, 0] :=  (self.calcAmp() + Tan(0.5 * self.calcOmega()) * self.calcAlpha() * Sqrt(self.calcAmp()) + Sqr(Tan(0.5 * self.calcOmega()))) / self.calcAmp();
        end;
        ftTreble: begin
          self.fconfig[0, 2] :=  (self.calcAmp() - Tan(0.5 * self.calcOmega()) * self.calcAlpha() * Sqrt(self.calcAmp()) + Sqr(Tan(0.5 * self.calcOmega())));
          self.fconfig[0, 1] := +2.0 * (Sqr(Tan(0.5 * self.calcOmega())) - self.calcAmp());
          self.fconfig[0, 0] :=  (self.calcAmp() + Tan(0.5 * self.calcOmega()) * self.calcAlpha() * Sqrt(self.calcAmp()) + Sqr(Tan(0.5 * self.calcOmega())));
          self.fconfig[1, 2] :=  (      1.0      - Tan(0.5 * self.calcOmega()) * self.calcAlpha() *         1.0          + Sqr(Tan(0.5 * self.calcOmega())));
          self.fconfig[1, 1] := +2.0 * (Sqr(Tan(0.5 * self.calcOmega())) -      1.0      );
          self.fconfig[1, 0] :=  (      1.0      + Tan(0.5 * self.calcOmega()) * self.calcAlpha() *         1.0          + Sqr(Tan(0.5 * self.calcOmega())));
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
    end;
    ttZDF: begin
      case (self.ffilter) of
        ftLow: begin
          self.fconfig[0, 2] :=  (1.0 * Sqr(Tan(0.5 * self.calcOmega())));
          self.fconfig[0, 1] := +2.0 * Sqr(Tan(0.5 * self.calcOmega()));
          self.fconfig[0, 0] :=  (1.0 * Sqr(Tan(0.5 * self.calcOmega())));
          self.fconfig[1, 2] :=  (1.0 - Tan(0.5 * self.calcOmega()) * self.calcAlpha() + Sqr(Tan(0.5 * self.calcOmega())));
          self.fconfig[1, 1] := +2.0 * (Sqr(Tan(0.5 * self.calcOmega())) - 1.0);
          self.fconfig[1, 0] :=  (1.0 + Tan(0.5 * self.calcOmega()) * self.calcAlpha() + Sqr(Tan(0.5 * self.calcOmega())));
        end;
        ftHigh: begin
          self.fconfig[0, 2] :=  (1.0);
          self.fconfig[0, 1] := -2.0;
          self.fconfig[0, 0] :=  (1.0);
          self.fconfig[1, 2] :=  (1.0 - Tan(0.5 * self.calcOmega()) * self.calcAlpha() + Sqr(Tan(0.5 * self.calcOmega())));
          self.fconfig[1, 1] := +2.0 * (Sqr(Tan(0.5 * self.calcOmega())) - 1.0);
          self.fconfig[1, 0] :=  (1.0 + Tan(0.5 * self.calcOmega()) * self.calcAlpha() + Sqr(Tan(0.5 * self.calcOmega())));
        end;
        ftPeak: begin
          self.fconfig[0, 2] :=  (0.0 - Tan(0.5 * self.calcOmega()) *       1.0       );
          self.fconfig[0, 1] :=  0.0;
          self.fconfig[0, 0] :=  (0.0 + Tan(0.5 * self.calcOmega()) *       1.0       );
          self.fconfig[1, 2] :=  (1.0 - Tan(0.5 * self.calcOmega()) * self.calcAlpha() + Sqr(Tan(0.5 * self.calcOmega())));
          self.fconfig[1, 1] := +2.0 * (Sqr(Tan(0.5 * self.calcOmega())) - 1.0);
          self.fconfig[1, 0] :=  (1.0 + Tan(0.5 * self.calcOmega()) * self.calcAlpha() + Sqr(Tan(0.5 * self.calcOmega())));
        end;
        ftBand: begin
          self.fconfig[0, 2] :=  (0.0 - Tan(0.5 * self.calcOmega()) * self.calcAlpha());
          self.fconfig[0, 1] :=  0.0;
          self.fconfig[0, 0] :=  (0.0 + Tan(0.5 * self.calcOmega()) * self.calcAlpha());
          self.fconfig[1, 2] :=  (1.0 - Tan(0.5 * self.calcOmega()) * self.calcAlpha() + Sqr(Tan(0.5 * self.calcOmega())));
          self.fconfig[1, 1] := +2.0 * (Sqr(Tan(0.5 * self.calcOmega())) - 1.0);
          self.fconfig[1, 0] :=  (1.0 + Tan(0.5 * self.calcOmega()) * self.calcAlpha() + Sqr(Tan(0.5 * self.calcOmega())));
        end;
        ftNotch: begin
          self.fconfig[0, 2] :=  (1.0 + (Sqr(Tan(0.5 * self.calcOmega()))));
          self.fconfig[0, 1] := +2.0 * (Sqr(Tan(0.5 * self.calcOmega())) - 1.0);
          self.fconfig[0, 0] :=  (1.0 + (Sqr(Tan(0.5 * self.calcOmega()))));
          self.fconfig[1, 2] :=  (1.0 - Tan(0.5 * self.calcOmega()) * self.calcAlpha() + Sqr(Tan(0.5 * self.calcOmega())));
          self.fconfig[1, 1] := +2.0 * (Sqr(Tan(0.5 * self.calcOmega())) - 1.0);
          self.fconfig[1, 0] :=  (1.0 + Tan(0.5 * self.calcOmega()) * self.calcAlpha() + Sqr(Tan(0.5 * self.calcOmega())));
        end;
        ftAll: begin
          self.fconfig[0, 2] :=  (1.0 + Tan(0.5 * self.calcOmega()) * self.calcAlpha() + Sqr(Tan(0.5 * self.calcOmega())));
          self.fconfig[0, 1] := +2.0 * (Sqr(Tan(0.5 * self.calcOmega())) - 1.0);
          self.fconfig[0, 0] :=  (1.0 - Tan(0.5 * self.calcOmega()) * self.calcAlpha() + Sqr(Tan(0.5 * self.calcOmega())));
          self.fconfig[1, 2] :=  (1.0 - Tan(0.5 * self.calcOmega()) * self.calcAlpha() + Sqr(Tan(0.5 * self.calcOmega())));
          self.fconfig[1, 1] := +2.0 * (Sqr(Tan(0.5 * self.calcOmega())) - 1.0);
          self.fconfig[1, 0] :=  (1.0 + Tan(0.5 * self.calcOmega()) * self.calcAlpha() + Sqr(Tan(0.5 * self.calcOmega())));
        end;
        ftEqu: begin
          self.fconfig[0, 2] :=  (1.0 - Tan(0.5 * self.calcOmega()) * self.calcAlpha() /      1.0       + Sqr(Tan(0.5 * self.calcOmega())));
          self.fconfig[0, 1] := +2.0 * (Sqr(Tan(0.5 * self.calcOmega())) - 1.0);
          self.fconfig[0, 0] :=  (1.0 + Tan(0.5 * self.calcOmega()) * self.calcAlpha() /      1.0       + Sqr(Tan(0.5 * self.calcOmega())));
          self.fconfig[1, 2] :=  (1.0 - Tan(0.5 * self.calcOmega()) * self.calcAlpha() / self.calcAmp() + Sqr(Tan(0.5 * self.calcOmega())));
          self.fconfig[1, 1] := +2.0 * (Sqr(Tan(0.5 * self.calcOmega())) - 1.0);
          self.fconfig[1, 0] :=  (1.0 + Tan(0.5 * self.calcOmega()) * self.calcAlpha() / self.calcAmp() + Sqr(Tan(0.5 * self.calcOmega())));
        end;
        ftBass: begin
          self.fconfig[0, 2] :=  (1.0 - Tan(0.5 * self.calcOmega()) * self.calcAlpha() * Sqrt(self.calcAmp()) + Sqr(Tan(0.5 * self.calcOmega())) * self.calcAmp());
          self.fconfig[0, 1] := +2.0 * (Sqr(Tan(0.5 * self.calcOmega())) * self.calcAmp() - 1.0);
          self.fconfig[0, 0] :=  (1.0 + Tan(0.5 * self.calcOmega()) * self.calcAlpha() * Sqrt(self.calcAmp()) + Sqr(Tan(0.5 * self.calcOmega())) * self.calcAmp());
          self.fconfig[1, 2] :=  (1.0 - Tan(0.5 * self.calcOmega()) * self.calcAlpha() *         1.0          + Sqr(Tan(0.5 * self.calcOmega())) *      1.0      );
          self.fconfig[1, 1] := +2.0 * (Sqr(Tan(0.5 * self.calcOmega())) *       1.0      - 1.0);
          self.fconfig[1, 0] :=  (1.0 + Tan(0.5 * self.calcOmega()) * self.calcAlpha() *         1.0          + Sqr(Tan(0.5 * self.calcOmega())) *      1.0      );
        end;
        ftTreble: begin
          self.fconfig[0, 2] :=  (1.0 - Tan(0.5 * self.calcOmega()) * self.calcAlpha() *         1.0          + Sqr(Tan(0.5 * self.calcOmega())) *      1.0      ) /      1.0      ;
          self.fconfig[0, 1] := +2.0 * (Sqr(Tan(0.5 * self.calcOmega())) *       1.0      - 1.0) /      1.0      ;
          self.fconfig[0, 0] :=  (1.0 + Tan(0.5 * self.calcOmega()) * self.calcAlpha() *         1.0          + Sqr(Tan(0.5 * self.calcOmega())) *      1.0      ) /      1.0      ;
          self.fconfig[1, 2] :=  (1.0 - Tan(0.5 * self.calcOmega()) * self.calcAlpha() * Sqrt(self.calcAmp()) + Sqr(Tan(0.5 * self.calcOmega())) * self.calcAmp()) / self.calcAmp();
          self.fconfig[1, 1] := +2.0 * (Sqr(Tan(0.5 * self.calcOmega())) * self.calcAmp() - 1.0) / self.calcAmp();
          self.fconfig[1, 0] :=  (1.0 + Tan(0.5 * self.calcOmega()) * self.calcAlpha() * Sqrt(self.calcAmp()) + Sqr(Tan(0.5 * self.calcOmega())) * self.calcAmp()) / self.calcAmp();
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
end;

function TWMPBQF.Process(const Value: Double): Double;
begin
  self.fsignal[0, 2] := self.fsignal[0, 1];
  self.fsignal[0, 1] := self.fsignal[0, 0];
  self.fsignal[0, 0] := Value;
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

function TWMPBQF.getTransform(): TTransform;
begin
  Result := self.ftransform;
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
