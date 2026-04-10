unit
  QMPBQF;

interface

type
  TGain = (gtDb, gtAmp);

type
  TBand = (btQ, btOctave, btSlope);

type
  TFilter = (ftLow, ftHigh, ftPeak, ftBand, ftNotch, ftAll, ftEqu, ftBass, ftTreble);

type
  TTransform = (ptLAT, ptSVF, ptZDF, ptTDI);

type
  TQMPBQF = record
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

procedure TQMPBQF.Init(const Transform: TTransform; const Filter: TFilter; const Band: TBand; const Gain: TGain);
begin
  self.fband := Band;
  self.fgain := Gain;
  self.ffilter := Filter;
  self.ftransform := Transform;
end;

procedure TQMPBQF.Done();
begin
end;

function TQMPBQF.calcOmega(): Double;
begin
  Result := (2.0 * Pi * self.ffreq / self.frate);
end;

function TQMPBQF.calcAmp(): Double;
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

function TQMPBQF.calcAlpha(): Double;
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

procedure TQMPBQF.calcConfig();
begin
  case (self.ftransform) of
    ptLAT: begin
      case (self.ffilter) of
        ftLow: begin
          self.fconfig[0, 2] :=  1.0 * ((1.0 - Cos(self.calcOmega())) / 2.0);
          self.fconfig[0, 1] := +2.0 * ((1.0 - Cos(self.calcOmega())) / 2.0);
          self.fconfig[0, 0] :=  1.0 * ((1.0 - Cos(self.calcOmega())) / 2.0);
          self.fconfig[1, 2] :=  1.0 - (Sin(self.calcOmega()) / 2.0) * self.calcAlpha();
          self.fconfig[1, 1] := -2.0 * (Cos(self.calcOmega()));
          self.fconfig[1, 0] :=  1.0 + (Sin(self.calcOmega()) / 2.0) * self.calcAlpha();
        end;
        ftHigh: begin
          self.fconfig[0, 2] :=  1.0 * ((1 + Cos(self.calcOmega())) / 2.0);
          self.fconfig[0, 1] := -2.0 * ((1 + Cos(self.calcOmega())) / 2.0);
          self.fconfig[0, 0] :=  1.0 * ((1 + Cos(self.calcOmega())) / 2.0);
          self.fconfig[1, 2] :=  1.0 - (Sin(self.calcOmega()) / 2.0) * self.calcAlpha();
          self.fconfig[1, 1] := -2.0 * (Cos(self.calcOmega()));
          self.fconfig[1, 0] :=  1.0 + (Sin(self.calcOmega()) / 2.0) * self.calcAlpha();
        end;
        ftPeak: begin
          self.fconfig[0, 2] :=  0.0 - (Sin(self.calcOmega()) / 2.0) *       1.0       ;
          self.fconfig[0, 1] :=  0.0;
          self.fconfig[0, 0] :=  0.0 + (Sin(self.calcOmega()) / 2.0) *       1.0       ;
          self.fconfig[1, 2] :=  1.0 - (Sin(self.calcOmega()) / 2.0) * self.calcAlpha();
          self.fconfig[1, 1] := -2.0 * (Cos(self.calcOmega()));
          self.fconfig[1, 0] :=  1.0 + (Sin(self.calcOmega()) / 2.0) * self.calcAlpha();
        end;
        ftBand: begin
          self.fconfig[0, 2] :=  0.0 - (Sin(self.calcOmega()) / 2.0) * self.calcAlpha();
          self.fconfig[0, 1] :=  0.0;
          self.fconfig[0, 0] :=  0.0 + (Sin(self.calcOmega()) / 2.0) * self.calcAlpha();
          self.fconfig[1, 2] :=  1.0 - (Sin(self.calcOmega()) / 2.0) * self.calcAlpha();
          self.fconfig[1, 1] := -2.0 * (Cos(self.calcOmega()));
          self.fconfig[1, 0] :=  1.0 + (Sin(self.calcOmega()) / 2.0) * self.calcAlpha();
        end;
        ftNotch: begin
          self.fconfig[0, 2] :=  1.0;
          self.fconfig[0, 1] := -2.0 * (Cos(self.calcOmega()));
          self.fconfig[0, 0] :=  1.0;
          self.fconfig[1, 2] :=  1.0 - (Sin(self.calcOmega()) / 2.0) * self.calcAlpha();
          self.fconfig[1, 1] := -2.0 * (Cos(self.calcOmega()));
          self.fconfig[1, 0] :=  1.0 + (Sin(self.calcOmega()) / 2.0) * self.calcAlpha();
        end;
        ftAll: begin
          self.fconfig[0, 2] :=  1.0 + (Sin(self.calcOmega()) / 2.0) * self.calcAlpha();
          self.fconfig[0, 1] := -2.0 * (Cos(self.calcOmega()));
          self.fconfig[0, 0] :=  1.0 - (Sin(self.calcOmega()) / 2.0) * self.calcAlpha();
          self.fconfig[1, 2] :=  1.0 - (Sin(self.calcOmega()) / 2.0) * self.calcAlpha();
          self.fconfig[1, 1] := -2.0 * (Cos(self.calcOmega()));
          self.fconfig[1, 0] :=  1.0 + (Sin(self.calcOmega()) / 2.0) * self.calcAlpha();
        end;
        ftEqu: begin
          self.fconfig[0, 2] :=  1.0 - (Sin(self.calcOmega()) / 2.0) * self.calcAlpha() * Sqrt(self.calcAmp());
          self.fconfig[0, 1] := -2.0 * (Cos(self.calcOmega()));
          self.fconfig[0, 0] :=  1.0 + (Sin(self.calcOmega()) / 2.0) * self.calcAlpha() * Sqrt(self.calcAmp());
          self.fconfig[1, 2] :=  1.0 - (Sin(self.calcOmega()) / 2.0) * self.calcAlpha() / Sqrt(self.calcAmp());
          self.fconfig[1, 1] := -2.0 * (Cos(self.calcOmega()));
          self.fconfig[1, 0] :=  1.0 + (Sin(self.calcOmega()) / 2.0) * self.calcAlpha() / Sqrt(self.calcAmp());
        end;
        ftBass: begin
          self.fconfig[0, 2] :=  1.0 * Sqrt(self.calcAmp()) * ((Sqrt(self.calcAmp()) + 1.0) - (Sqrt(self.calcAmp()) - 1.0) * Cos(self.calcOmega()) - 2.0 * Sqrt(Sqrt(self.calcAmp())) * (Sin(self.calcOmega()) / 2.0) * self.calcAlpha());
          self.fconfig[0, 1] := +2.0 * Sqrt(self.calcAmp()) * ((Sqrt(self.calcAmp()) - 1.0) - (Sqrt(self.calcAmp()) + 1.0) * Cos(self.calcOmega()));
          self.fconfig[0, 0] :=  1.0 * Sqrt(self.calcAmp()) * ((Sqrt(self.calcAmp()) + 1.0) - (Sqrt(self.calcAmp()) - 1.0) * Cos(self.calcOmega()) + 2.0 * Sqrt(Sqrt(self.calcAmp())) * (Sin(self.calcOmega()) / 2.0) * self.calcAlpha());
          self.fconfig[1, 2] :=  1.0 *         1.0          * ((Sqrt(self.calcAmp()) + 1.0) + (Sqrt(self.calcAmp()) - 1.0) * Cos(self.calcOmega()) - 2.0 * Sqrt(Sqrt(self.calcAmp())) * (Sin(self.calcOmega()) / 2.0) * self.calcAlpha());
          self.fconfig[1, 1] := -2.0 *         1.0          * ((Sqrt(self.calcAmp()) - 1.0) + (Sqrt(self.calcAmp()) + 1.0) * Cos(self.calcOmega()));
          self.fconfig[1, 0] :=  1.0 *         1.0          * ((Sqrt(self.calcAmp()) + 1.0) + (Sqrt(self.calcAmp()) - 1.0) * Cos(self.calcOmega()) + 2.0 * Sqrt(Sqrt(self.calcAmp())) * (Sin(self.calcOmega()) / 2.0) * self.calcAlpha());
        end;
        ftTreble: begin
          self.fconfig[0, 2] :=  1.0 * Sqrt(self.calcAmp()) * ((Sqrt(self.calcAmp()) + 1.0) + (Sqrt(self.calcAmp()) - 1.0) * Cos(self.calcOmega()) - 2.0 * Sqrt(Sqrt(self.calcAmp())) * (Sin(self.calcOmega()) / 2.0) * self.calcAlpha());
          self.fconfig[0, 1] := -2.0 * Sqrt(self.calcAmp()) * ((Sqrt(self.calcAmp()) - 1.0) + (Sqrt(self.calcAmp()) + 1.0) * Cos(self.calcOmega()));
          self.fconfig[0, 0] :=  1.0 * Sqrt(self.calcAmp()) * ((Sqrt(self.calcAmp()) + 1.0) + (Sqrt(self.calcAmp()) - 1.0) * Cos(self.calcOmega()) + 2.0 * Sqrt(Sqrt(self.calcAmp())) * (Sin(self.calcOmega()) / 2.0) * self.calcAlpha());
          self.fconfig[1, 2] :=  1.0 *         1.0          * ((Sqrt(self.calcAmp()) + 1.0) - (Sqrt(self.calcAmp()) - 1.0) * Cos(self.calcOmega()) - 2.0 * Sqrt(Sqrt(self.calcAmp())) * (Sin(self.calcOmega()) / 2.0) * self.calcAlpha());
          self.fconfig[1, 1] := +2.0 *         1.0          * ((Sqrt(self.calcAmp()) - 1.0) - (Sqrt(self.calcAmp()) + 1.0) * Cos(self.calcOmega()));
          self.fconfig[1, 0] :=  1.0 *         1.0          * ((Sqrt(self.calcAmp()) + 1.0) - (Sqrt(self.calcAmp()) - 1.0) * Cos(self.calcOmega()) + 2.0 * Sqrt(Sqrt(self.calcAmp())) * (Sin(self.calcOmega()) / 2.0) * self.calcAlpha());
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
    ptSVF: begin
      case (self.ffilter) of
        ftLow: begin
          self.fconfig[0, 2] :=  1.0 * Sqr(Tan(self.calcOmega() / 2.0));
          self.fconfig[0, 1] := +2.0 * Sqr(Tan(self.calcOmega() / 2.0));
          self.fconfig[0, 0] :=  1.0 * Sqr(Tan(self.calcOmega() / 2.0));
          self.fconfig[1, 2] :=  1.0 - Tan(self.calcOmega() / 2.0) * self.calcAlpha() + Sqr(Tan(self.calcOmega() / 2.0));
          self.fconfig[1, 1] := +2.0 * (Sqr(Tan(self.calcOmega() / 2.0)) - 1.0);
          self.fconfig[1, 0] :=  1.0 + Tan(self.calcOmega() / 2.0) * self.calcAlpha() + Sqr(Tan(self.calcOmega() / 2.0));
        end;
        ftHigh: begin
          self.fconfig[0, 2] :=  1.0;
          self.fconfig[0, 1] := -2.0;
          self.fconfig[0, 0] :=  1.0;
          self.fconfig[1, 2] :=  1.0 - Tan(self.calcOmega() / 2.0) * self.calcAlpha() + Sqr(Tan(self.calcOmega() / 2.0));
          self.fconfig[1, 1] := +2.0 * (Sqr(Tan(self.calcOmega() / 2.0)) - 1.0);
          self.fconfig[1, 0] :=  1.0 + Tan(self.calcOmega() / 2.0) * self.calcAlpha() + Sqr(Tan(self.calcOmega() / 2.0));
        end;
        ftPeak: begin
          self.fconfig[0, 2] :=  0.0 - Tan(self.calcOmega() / 2.0) *       1.0       ;
          self.fconfig[0, 1] :=  0.0;
          self.fconfig[0, 0] :=  0.0 + Tan(self.calcOmega() / 2.0) *       1.0       ;
          self.fconfig[1, 2] :=  1.0 - Tan(self.calcOmega() / 2.0) * self.calcAlpha() + Sqr(Tan(self.calcOmega() / 2.0));
          self.fconfig[1, 1] := +2.0 * (Sqr(Tan(self.calcOmega() / 2.0)) - 1.0);
          self.fconfig[1, 0] :=  1.0 + Tan(self.calcOmega() / 2.0) * self.calcAlpha() + Sqr(Tan(self.calcOmega() / 2.0));
        end;
        ftBand: begin
          self.fconfig[0, 2] :=  0.0 - Tan(self.calcOmega() / 2.0) * self.calcAlpha();
          self.fconfig[0, 1] :=  0.0;
          self.fconfig[0, 0] :=  0.0 + Tan(self.calcOmega() / 2.0) * self.calcAlpha();
          self.fconfig[1, 2] :=  1.0 - Tan(self.calcOmega() / 2.0) * self.calcAlpha() + Sqr(Tan(self.calcOmega() / 2.0));
          self.fconfig[1, 1] := +2.0 * (Sqr(Tan(self.calcOmega() / 2.0)) - 1.0);
          self.fconfig[1, 0] :=  1.0 + Tan(self.calcOmega() / 2.0) * self.calcAlpha() + Sqr(Tan(self.calcOmega() / 2.0));
        end;
        ftNotch: begin
          self.fconfig[0, 2] :=  1.0 + (Sqr(Tan(self.calcOmega() / 2.0)));
          self.fconfig[0, 1] := +2.0 * (Sqr(Tan(self.calcOmega() / 2.0)) - 1.0);
          self.fconfig[0, 0] :=  1.0 + (Sqr(Tan(self.calcOmega() / 2.0)));
          self.fconfig[1, 2] :=  1.0 - Tan(self.calcOmega() / 2.0) * self.calcAlpha() + Sqr(Tan(self.calcOmega() / 2.0));
          self.fconfig[1, 1] := +2.0 * (Sqr(Tan(self.calcOmega() / 2.0)) - 1.0);
          self.fconfig[1, 0] :=  1.0 + Tan(self.calcOmega() / 2.0) * self.calcAlpha() + Sqr(Tan(self.calcOmega() / 2.0));
        end;
        ftAll: begin
          self.fconfig[0, 2] :=  1.0 + Tan(self.calcOmega() / 2.0) * self.calcAlpha() + Sqr(Tan(self.calcOmega() / 2.0));
          self.fconfig[0, 1] := +2.0 * (Sqr(Tan(self.calcOmega() / 2.0)) - 1.0);
          self.fconfig[0, 0] :=  1.0 - Tan(self.calcOmega() / 2.0) * self.calcAlpha() + Sqr(Tan(self.calcOmega() / 2.0));
          self.fconfig[1, 2] :=  1.0 - Tan(self.calcOmega() / 2.0) * self.calcAlpha() + Sqr(Tan(self.calcOmega() / 2.0));
          self.fconfig[1, 1] := +2.0 * (Sqr(Tan(self.calcOmega() / 2.0)) - 1.0);
          self.fconfig[1, 0] :=  1.0 + Tan(self.calcOmega() / 2.0) * self.calcAlpha() + Sqr(Tan(self.calcOmega() / 2.0));
        end;
        ftEqu: begin
          self.fconfig[0, 2] :=  1.0 - Tan(self.calcOmega() / 2.0) * self.calcAlpha() * self.calcAmp() + Sqr(Tan(self.calcOmega() / 2.0));
          self.fconfig[0, 1] := +2.0 * (Sqr(Tan(self.calcOmega() / 2.0)) - 1.0);
          self.fconfig[0, 0] :=  1.0 + Tan(self.calcOmega() / 2.0) * self.calcAlpha() * self.calcAmp() + Sqr(Tan(self.calcOmega() / 2.0));
          self.fconfig[1, 2] :=  1.0 - Tan(self.calcOmega() / 2.0) * self.calcAlpha() *      1.0       + Sqr(Tan(self.calcOmega() / 2.0));
          self.fconfig[1, 1] := +2.0 * (Sqr(Tan(self.calcOmega() / 2.0)) - 1.0);
          self.fconfig[1, 0] :=  1.0 + Tan(self.calcOmega() / 2.0) * self.calcAlpha() *      1.0       + Sqr(Tan(self.calcOmega() / 2.0));
        end;
        ftBass: begin
          self.fconfig[0, 2] :=  (      1.0      - Tan(self.calcOmega() / 2.0) * self.calcAlpha() *         1.0          + Sqr(Tan(self.calcOmega() / 2.0))) /      1.0      ;
          self.fconfig[0, 1] := +2.0 * (Sqr(Tan(self.calcOmega() / 2.0)) -      1.0      ) /      1.0      ;
          self.fconfig[0, 0] :=  (      1.0      + Tan(self.calcOmega() / 2.0) * self.calcAlpha() *         1.0          + Sqr(Tan(self.calcOmega() / 2.0))) /      1.0      ;
          self.fconfig[1, 2] :=  (self.calcAmp() - Tan(self.calcOmega() / 2.0) * self.calcAlpha() * Sqrt(self.calcAmp()) + Sqr(Tan(self.calcOmega() / 2.0))) / self.calcAmp();
          self.fconfig[1, 1] := +2.0 * (Sqr(Tan(self.calcOmega() / 2.0)) - self.calcAmp()) / self.calcAmp();
          self.fconfig[1, 0] :=  (self.calcAmp() + Tan(self.calcOmega() / 2.0) * self.calcAlpha() * Sqrt(self.calcAmp()) + Sqr(Tan(self.calcOmega() / 2.0))) / self.calcAmp();
        end;
        ftTreble: begin
          self.fconfig[0, 2] :=  (self.calcAmp() - Tan(self.calcOmega() / 2.0) * self.calcAlpha() * Sqrt(self.calcAmp()) + Sqr(Tan(self.calcOmega() / 2.0)));
          self.fconfig[0, 1] := +2.0 * (Sqr(Tan(self.calcOmega() / 2.0)) - self.calcAmp());
          self.fconfig[0, 0] :=  (self.calcAmp() + Tan(self.calcOmega() / 2.0) * self.calcAlpha() * Sqrt(self.calcAmp()) + Sqr(Tan(self.calcOmega() / 2.0)));
          self.fconfig[1, 2] :=  (      1.0      - Tan(self.calcOmega() / 2.0) * self.calcAlpha() *         1.0          + Sqr(Tan(self.calcOmega() / 2.0)));
          self.fconfig[1, 1] := +2.0 * (Sqr(Tan(self.calcOmega() / 2.0)) -      1.0      );
          self.fconfig[1, 0] :=  (      1.0      + Tan(self.calcOmega() / 2.0) * self.calcAlpha() *         1.0          + Sqr(Tan(self.calcOmega() / 2.0)));
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
    ptZDF: begin
      case (self.ffilter) of
        ftLow: begin
          self.fconfig[0, 2] :=  1.0 * Sqr(Tan(self.calcOmega() / 2.0));
          self.fconfig[0, 1] := +2.0 * Sqr(Tan(self.calcOmega() / 2.0));
          self.fconfig[0, 0] :=  1.0 * Sqr(Tan(self.calcOmega() / 2.0));
          self.fconfig[1, 2] :=  1.0 - Tan(self.calcOmega() / 2.0) * self.calcAlpha() + Sqr(Tan(self.calcOmega() / 2.0));
          self.fconfig[1, 1] := +2.0 * (Sqr(Tan(self.calcOmega() / 2.0)) - 1.0);
          self.fconfig[1, 0] :=  1.0 + Tan(self.calcOmega() / 2.0) * self.calcAlpha() + Sqr(Tan(self.calcOmega() / 2.0));
        end;
        ftHigh: begin
          self.fconfig[0, 2] :=  1.0;
          self.fconfig[0, 1] := -2.0;
          self.fconfig[0, 0] :=  1.0;
          self.fconfig[1, 2] :=  1.0 - Tan(self.calcOmega() / 2.0) * self.calcAlpha() + Sqr(Tan(self.calcOmega() / 2.0));
          self.fconfig[1, 1] := +2.0 * (Sqr(Tan(self.calcOmega() / 2.0)) - 1.0);
          self.fconfig[1, 0] :=  1.0 + Tan(self.calcOmega() / 2.0) * self.calcAlpha() + Sqr(Tan(self.calcOmega() / 2.0));
        end;
        ftPeak: begin
          self.fconfig[0, 2] :=  0.0 - Tan(self.calcOmega() / 2.0) *       1.0       ;
          self.fconfig[0, 1] :=  0.0;
          self.fconfig[0, 0] :=  0.0 + Tan(self.calcOmega() / 2.0) *       1.0       ;
          self.fconfig[1, 2] :=  1.0 - Tan(self.calcOmega() / 2.0) * self.calcAlpha() + Sqr(Tan(self.calcOmega() / 2.0));
          self.fconfig[1, 1] := +2.0 * (Sqr(Tan(self.calcOmega() / 2.0)) - 1.0);
          self.fconfig[1, 0] :=  1.0 + Tan(self.calcOmega() / 2.0) * self.calcAlpha() + Sqr(Tan(self.calcOmega() / 2.0));
        end;
        ftBand: begin
          self.fconfig[0, 2] :=  0.0 - Tan(self.calcOmega() / 2.0) * self.calcAlpha();
          self.fconfig[0, 1] :=  0.0;
          self.fconfig[0, 0] :=  0.0 + Tan(self.calcOmega() / 2.0) * self.calcAlpha();
          self.fconfig[1, 2] :=  1.0 - Tan(self.calcOmega() / 2.0) * self.calcAlpha() + Sqr(Tan(self.calcOmega() / 2.0));
          self.fconfig[1, 1] := +2.0 * (Sqr(Tan(self.calcOmega() / 2.0)) - 1.0);
          self.fconfig[1, 0] :=  1.0 + Tan(self.calcOmega() / 2.0) * self.calcAlpha() + Sqr(Tan(self.calcOmega() / 2.0));
        end;
        ftNotch: begin
          self.fconfig[0, 2] :=  1.0 + (Sqr(Tan(self.calcOmega() / 2.0)));
          self.fconfig[0, 1] := +2.0 * (Sqr(Tan(self.calcOmega() / 2.0)) - 1.0);
          self.fconfig[0, 0] :=  1.0 + (Sqr(Tan(self.calcOmega() / 2.0)));
          self.fconfig[1, 2] :=  1.0 - Tan(self.calcOmega() / 2.0) * self.calcAlpha() + Sqr(Tan(self.calcOmega() / 2.0));
          self.fconfig[1, 1] := +2.0 * (Sqr(Tan(self.calcOmega() / 2.0)) - 1.0);
          self.fconfig[1, 0] :=  1.0 + Tan(self.calcOmega() / 2.0) * self.calcAlpha() + Sqr(Tan(self.calcOmega() / 2.0));
        end;
        ftAll: begin
          self.fconfig[0, 2] :=  1.0 + Tan(self.calcOmega() / 2.0) * self.calcAlpha() + Sqr(Tan(self.calcOmega() / 2.0));
          self.fconfig[0, 1] := +2.0 * (Sqr(Tan(self.calcOmega() / 2.0)) - 1.0);
          self.fconfig[0, 0] :=  1.0 - Tan(self.calcOmega() / 2.0) * self.calcAlpha() + Sqr(Tan(self.calcOmega() / 2.0));
          self.fconfig[1, 2] :=  1.0 - Tan(self.calcOmega() / 2.0) * self.calcAlpha() + Sqr(Tan(self.calcOmega() / 2.0));
          self.fconfig[1, 1] := +2.0 * (Sqr(Tan(self.calcOmega() / 2.0)) - 1.0);
          self.fconfig[1, 0] :=  1.0 + Tan(self.calcOmega() / 2.0) * self.calcAlpha() + Sqr(Tan(self.calcOmega() / 2.0));
        end;
        ftEqu: begin
          self.fconfig[0, 2] :=  1.0 - Tan(self.calcOmega() / 2.0) * self.calcAlpha() /      1.0       + Sqr(Tan(self.calcOmega() / 2.0));
          self.fconfig[0, 1] := +2.0 * (Sqr(Tan(self.calcOmega() / 2.0)) - 1.0);
          self.fconfig[0, 0] :=  1.0 + Tan(self.calcOmega() / 2.0) * self.calcAlpha() /      1.0       + Sqr(Tan(self.calcOmega() / 2.0));
          self.fconfig[1, 2] :=  1.0 - Tan(self.calcOmega() / 2.0) * self.calcAlpha() / self.calcAmp() + Sqr(Tan(self.calcOmega() / 2.0));
          self.fconfig[1, 1] := +2.0 * (Sqr(Tan(self.calcOmega() / 2.0)) - 1.0);
          self.fconfig[1, 0] :=  1.0 + Tan(self.calcOmega() / 2.0) * self.calcAlpha() / self.calcAmp() + Sqr(Tan(self.calcOmega() / 2.0));
        end;
        ftBass: begin
          self.fconfig[0, 2] :=  (1.0 - Tan(self.calcOmega() / 2.0) * self.calcAlpha() * Sqrt(self.calcAmp()) + Sqr(Tan(self.calcOmega() / 2.0)) * self.calcAmp());
          self.fconfig[0, 1] := +2.0 * (Sqr(Tan(self.calcOmega() / 2.0)) * self.calcAmp() - 1.0);
          self.fconfig[0, 0] :=  (1.0 + Tan(self.calcOmega() / 2.0) * self.calcAlpha() * Sqrt(self.calcAmp()) + Sqr(Tan(self.calcOmega() / 2.0)) * self.calcAmp());
          self.fconfig[1, 2] :=  (1.0 - Tan(self.calcOmega() / 2.0) * self.calcAlpha() *         1.0          + Sqr(Tan(self.calcOmega() / 2.0)) *      1.0      );
          self.fconfig[1, 1] := +2.0 * (Sqr(Tan(self.calcOmega() / 2.0)) *      1.0       - 1.0);
          self.fconfig[1, 0] :=  (1.0 + Tan(self.calcOmega() / 2.0) * self.calcAlpha() *         1.0          + Sqr(Tan(self.calcOmega() / 2.0)) *      1.0      );
        end;
        ftTreble: begin
          self.fconfig[0, 2] :=  (1.0 - Tan(self.calcOmega() / 2.0) * self.calcAlpha() *         1.0          + Sqr(Tan(self.calcOmega() / 2.0)) *      1.0      ) /      1.0      ;
          self.fconfig[0, 1] := +2.0 * (Sqr(Tan(self.calcOmega() / 2.0)) *       1.0      - 1.0) /      1.0      ;
          self.fconfig[0, 0] :=  (1.0 + Tan(self.calcOmega() / 2.0) * self.calcAlpha() *         1.0          + Sqr(Tan(self.calcOmega() / 2.0)) *      1.0      ) /      1.0      ;
          self.fconfig[1, 2] :=  (1.0 - Tan(self.calcOmega() / 2.0) * self.calcAlpha() * Sqrt(self.calcAmp()) + Sqr(Tan(self.calcOmega() / 2.0)) * self.calcAmp()) / self.calcAmp();
          self.fconfig[1, 1] := +2.0 * (Sqr(Tan(self.calcOmega() / 2.0)) * self.calcAmp() - 1.0) / self.calcAmp();
          self.fconfig[1, 0] :=  (1.0 + Tan(self.calcOmega() / 2.0) * self.calcAlpha() * Sqrt(self.calcAmp()) + Sqr(Tan(self.calcOmega() / 2.0)) * self.calcAmp()) / self.calcAmp();
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
    ptTDI: begin
      case (self.ffilter) of
        ftLow: begin
          self.fconfig[0, 0] :=  0.0;
          self.fconfig[0, 1] :=  0.0;
          self.fconfig[0, 2] :=  1.0;
          self.fconfig[1, 0] :=  1.0 / (1.0 + Tan(self.calcOmega() / 2.0) * (Tan(self.calcOmega() / 2.0) + self.calcAlpha()));
          self.fconfig[1, 1] :=  (Tan(self.calcOmega() / 2.0)) * self.fconfig[1, 0];
          self.fconfig[1, 2] :=  (Tan(self.calcOmega() / 2.0)) * self.fconfig[1, 1];
        end;
        ftHigh: begin
          self.fconfig[0, 0] :=  1.0;
          self.fconfig[0, 1] := -1.0 * self.calcAlpha();
          self.fconfig[0, 2] := -1.0;
          self.fconfig[1, 0] :=  1.0 / (1.0 + Tan(self.calcOmega() / 2.0) * (Tan(self.calcOmega() / 2.0) + self.calcAlpha()));
          self.fconfig[1, 1] :=  (Tan(self.calcOmega() / 2.0)) * self.fconfig[1, 0];
          self.fconfig[1, 2] :=  (Tan(self.calcOmega() / 2.0)) * self.fconfig[1, 1];
        end;
        ftPeak: begin
          self.fconfig[0, 0] :=  0.0;
          self.fconfig[0, 1] :=  1.0;
          self.fconfig[0, 2] :=  0.0;
          self.fconfig[1, 0] :=  1.0 / (1.0 + Tan(self.calcOmega() / 2.0) * (Tan(self.calcOmega() / 2.0) + self.calcAlpha()));
          self.fconfig[1, 1] :=  (Tan(self.calcOmega() / 2.0)) * self.fconfig[1, 0];
          self.fconfig[1, 2] :=  (Tan(self.calcOmega() / 2.0)) * self.fconfig[1, 1];
        end;
        ftBand: begin
          self.fconfig[0, 0] :=  0.0;
          self.fconfig[0, 1] :=  1.0 * self.calcAlpha();
          self.fconfig[0, 2] :=  0.0;
          self.fconfig[1, 0] :=  1.0 / (1.0 + Tan(self.calcOmega() / 2.0) * (Tan(self.calcOmega() / 2.0) + self.calcAlpha()));
          self.fconfig[1, 1] :=  (Tan(self.calcOmega() / 2.0)) * self.fconfig[1, 0];
          self.fconfig[1, 2] :=  (Tan(self.calcOmega() / 2.0)) * self.fconfig[1, 1];
        end;
        ftNotch: begin
          self.fconfig[0, 0] :=  1.0;
          self.fconfig[0, 1] := -1.0 * self.calcAlpha();
          self.fconfig[0, 2] :=  0.0;
          self.fconfig[1, 0] :=  1.0 / (1.0 + Tan(self.calcOmega() / 2.0) * (Tan(self.calcOmega() / 2.0) + self.calcAlpha()));
          self.fconfig[1, 1] :=  (Tan(self.calcOmega() / 2.0)) * self.fconfig[1, 0];
          self.fconfig[1, 2] :=  (Tan(self.calcOmega() / 2.0)) * self.fconfig[1, 1];
        end;
        ftAll: begin
          self.fconfig[0, 0] :=  1.0;
          self.fconfig[0, 1] := -2.0 * self.calcAlpha();
          self.fconfig[0, 2] :=  0.0;
          self.fconfig[1, 0] :=  1.0 / (1.0 + Tan(self.calcOmega() / 2.0) * (Tan(self.calcOmega() / 2.0) + self.calcAlpha()));
          self.fconfig[1, 1] :=  (Tan(self.calcOmega() / 2.0)) * self.fconfig[1, 0];
          self.fconfig[1, 2] :=  (Tan(self.calcOmega() / 2.0)) * self.fconfig[1, 1];
        end;
        ftEqu: begin
          self.fconfig[0, 0] :=  1.0;
          self.fconfig[0, 1] :=  (Sqrt(self.calcAmp()) - 1.0 / Sqrt(self.calcAmp())) * self.calcAlpha();
          self.fconfig[0, 2] :=  0.0;
          self.fconfig[1, 0] :=  1.0 / (1.0 + Tan(self.calcOmega() / 2.0) * (Tan(self.calcOmega() / 2.0) + self.calcAlpha() / Sqrt(self.calcAmp())));
          self.fconfig[1, 1] :=  (Tan(self.calcOmega() / 2.0)) * self.fconfig[1, 0];
          self.fconfig[1, 2] :=  (Tan(self.calcOmega() / 2.0)) * self.fconfig[1, 1];
        end;
        ftBass: begin
          self.fconfig[0, 0] :=  1.0;
          self.fconfig[0, 1] :=  (Sqrt(self.calcAmp()) - 1.0) * self.calcAlpha();
          self.fconfig[0, 2] :=  (self.calcAmp() - 1.0);
          self.fconfig[1, 0] :=  1.0 / (1.0 + Tan(self.calcOmega() / 2.0) / Sqrt(Sqrt(self.calcAmp())) * (Tan(self.calcOmega() / 2.0) / Sqrt(Sqrt(self.calcAmp())) + self.calcAlpha()));
          self.fconfig[1, 1] :=  (Tan(self.calcOmega() / 2.0) / Sqrt(Sqrt(self.calcAmp()))) * self.fconfig[1, 0];
          self.fconfig[1, 2] :=  (Tan(self.calcOmega() / 2.0) / Sqrt(Sqrt(self.calcAmp()))) * self.fconfig[1, 1];
        end;
        ftTreble: begin
          self.fconfig[0, 0] :=  self.calcAmp();
          self.fconfig[0, 1] :=  (Sqrt(self.calcAmp()) - self.calcAmp()) * self.calcAlpha();
          self.fconfig[0, 2] :=  (1.0 - self.calcAmp());
          self.fconfig[1, 0] :=  1.0 / (1.0 + Tan(self.calcOmega() / 2.0) / Sqrt(Sqrt(self.calcAmp())) * (Tan(self.calcOmega() / 2.0) / Sqrt(Sqrt(self.calcAmp())) + self.calcAlpha()));
          self.fconfig[1, 1] :=  (Tan(self.calcOmega() / 2.0) / Sqrt(Sqrt(self.calcAmp()))) * self.fconfig[1, 0];
          self.fconfig[1, 2] :=  (Tan(self.calcOmega() / 2.0) / Sqrt(Sqrt(self.calcAmp()))) * self.fconfig[1, 1];
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

function TQMPBQF.Process(const Value: Double): Double;
begin
  case (self.ftransform) of
    ptLAT: begin
      self.fsignal[0, 2] := self.fsignal[0, 1];
      self.fsignal[0, 1] := self.fsignal[0, 0];
      self.fsignal[0, 0] := Value;
      self.fsignal[1, 2] := self.fsignal[1, 1];
      self.fsignal[1, 1] := self.fsignal[1, 0];
      self.fsignal[1, 0] := ((self.fsignal[0, 0] * self.fconfig[0, 0] + self.fsignal[0, 1] * self.fconfig[0, 1] + self.fsignal[0, 2] * self.fconfig[0, 2]) - (self.fsignal[1, 1] * self.fconfig[1, 1] + self.fsignal[1, 2] * self.fconfig[1, 2])) / self.fconfig[1, 0];
    end;
    ptSVF: begin
      self.fsignal[0, 2] := self.fsignal[0, 1];
      self.fsignal[0, 1] := self.fsignal[0, 0];
      self.fsignal[0, 0] := Value;
      self.fsignal[1, 2] := self.fsignal[1, 1];
      self.fsignal[1, 1] := self.fsignal[1, 0];
      self.fsignal[1, 0] := ((self.fsignal[0, 0] * self.fconfig[0, 0] + self.fsignal[0, 1] * self.fconfig[0, 1] + self.fsignal[0, 2] * self.fconfig[0, 2]) - (self.fsignal[1, 1] * self.fconfig[1, 1] + self.fsignal[1, 2] * self.fconfig[1, 2])) / self.fconfig[1, 0];
    end;
    ptZDF: begin
      self.fsignal[0, 2] := self.fsignal[0, 1];
      self.fsignal[0, 1] := self.fsignal[0, 0];
      self.fsignal[0, 0] := Value;
      self.fsignal[1, 2] := self.fsignal[1, 1];
      self.fsignal[1, 1] := self.fsignal[1, 0];
      self.fsignal[1, 0] := ((self.fsignal[0, 0] * self.fconfig[0, 0] + self.fsignal[0, 1] * self.fconfig[0, 1] + self.fsignal[0, 2] * self.fconfig[0, 2]) - (self.fsignal[1, 1] * self.fconfig[1, 1] + self.fsignal[1, 2] * self.fconfig[1, 2])) / self.fconfig[1, 0];
    end;
    ptTDI: begin
      self.fsignal[0, 0] := Value;
      self.fsignal[0, 1] := self.fconfig[1, 0] * self.fsignal[1, 1] + self.fconfig[1, 1] * (self.fsignal[0, 0] - self.fsignal[1, 2]);
      self.fsignal[0, 2] := self.fconfig[1, 1] * self.fsignal[1, 1] + self.fconfig[1, 2] * (self.fsignal[0, 0] - self.fsignal[1, 2]) + self.fsignal[1, 2];
      self.fsignal[1, 0] := self.fconfig[0, 0] * self.fsignal[0, 0] + self.fconfig[0, 1] * self.fsignal[0, 1] + self.fconfig[0, 2] * self.fsignal[0, 2];
      self.fsignal[1, 1] := 2.0 * self.fsignal[0, 1] - self.fsignal[1, 1];
      self.fsignal[1, 2] := 2.0 * self.fsignal[0, 2] - self.fsignal[1, 2];
    end;
    else begin
      self.fsignal[0, 2] := 0.0;
      self.fsignal[0, 1] := 0.0;
      self.fsignal[0, 0] := 0.0;
      self.fsignal[1, 2] := 0.0;
      self.fsignal[1, 1] := 0.0;
      self.fsignal[1, 0] := 0.0;
    end;
  end;
  Result := self.fsignal[1, 0];
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

function TQMPBQF.getTransform(): TTransform;
begin
  Result := self.ftransform;
end;

function TQMPBQF.getAmp(): Double;
begin
  Result := self.famp;
end;

procedure TQMPBQF.setAmp(const Value: Double);
begin
  if (self.famp <> Value) then begin
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
  if (self.ffreq <> Value) then begin
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
  if (self.frate <> Value) then begin
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
  if (self.fwidth <> Value) then begin
    self.fwidth := Value;
    self.calcConfig();
  end;
end;

begin
end.
