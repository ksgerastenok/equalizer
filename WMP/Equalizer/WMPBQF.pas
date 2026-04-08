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
  TTransform = (ptLAT, ptSVF, ptZDF, ptTDI);

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
    function getValue(): Double;
    function getAmp(): Double;
    procedure setAmp(const Data: Double);
    function getFreq(): Double;
    procedure setFreq(const Data: Double);
    function getRate(): Double;
    procedure setRate(const Data: Double);
    function getWidth(): Double;
    procedure setWidth(const Data: Double);
    function calcAlpha(): Double;
    function calcOmega(): Double;
    procedure calcConfig();
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

function TWMPBQF.getValue(): Double;
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
      Result := Sqrt(Sqrt(self.getValue()) * (1.0 / self.getValue() + 1.0) * (1.0 / self.fwidth - 1.0) + 2.0);
    end;
    else begin
      Result := 0.0;
    end;
  end;
end;

procedure TWMPBQF.calcConfig();
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
          self.fconfig[0, 2] :=  1.0 - (Sin(self.calcOmega()) / 2.0) * self.calcAlpha() * Sqrt(self.getValue());
          self.fconfig[0, 1] := -2.0 * (Cos(self.calcOmega()));
          self.fconfig[0, 0] :=  1.0 + (Sin(self.calcOmega()) / 2.0) * self.calcAlpha() * Sqrt(self.getValue());
          self.fconfig[1, 2] :=  1.0 - (Sin(self.calcOmega()) / 2.0) * self.calcAlpha() / Sqrt(self.getValue());
          self.fconfig[1, 1] := -2.0 * (Cos(self.calcOmega()));
          self.fconfig[1, 0] :=  1.0 + (Sin(self.calcOmega()) / 2.0) * self.calcAlpha() / Sqrt(self.getValue());
        end;
        ftBass: begin
          self.fconfig[0, 2] :=  1.0 * Sqrt(self.getValue()) * ((Sqrt(self.getValue()) + 1.0) - (Sqrt(self.getValue()) - 1.0) * Cos(self.calcOmega()) - 2.0 * Sqrt(Sqrt(self.getValue())) * (Sin(self.calcOmega()) / 2.0) * self.calcAlpha());
          self.fconfig[0, 1] := +2.0 * Sqrt(self.getValue()) * ((Sqrt(self.getValue()) - 1.0) - (Sqrt(self.getValue()) + 1.0) * Cos(self.calcOmega()));
          self.fconfig[0, 0] :=  1.0 * Sqrt(self.getValue()) * ((Sqrt(self.getValue()) + 1.0) - (Sqrt(self.getValue()) - 1.0) * Cos(self.calcOmega()) + 2.0 * Sqrt(Sqrt(self.getValue())) * (Sin(self.calcOmega()) / 2.0) * self.calcAlpha());
          self.fconfig[1, 2] :=  1.0 *          1.0          * ((Sqrt(self.getValue()) + 1.0) + (Sqrt(self.getValue()) - 1.0) * Cos(self.calcOmega()) - 2.0 * Sqrt(Sqrt(self.getValue())) * (Sin(self.calcOmega()) / 2.0) * self.calcAlpha());
          self.fconfig[1, 1] := -2.0 *          1.0          * ((Sqrt(self.getValue()) - 1.0) + (Sqrt(self.getValue()) + 1.0) * Cos(self.calcOmega()));
          self.fconfig[1, 0] :=  1.0 *          1.0          * ((Sqrt(self.getValue()) + 1.0) + (Sqrt(self.getValue()) - 1.0) * Cos(self.calcOmega()) + 2.0 * Sqrt(Sqrt(self.getValue())) * (Sin(self.calcOmega()) / 2.0) * self.calcAlpha());
        end;
        ftTreble: begin
          self.fconfig[0, 2] :=  1.0 * Sqrt(self.getValue()) * ((Sqrt(self.getValue()) + 1.0) + (Sqrt(self.getValue()) - 1.0) * Cos(self.calcOmega()) - 2.0 * Sqrt(Sqrt(self.getValue())) * (Sin(self.calcOmega()) / 2.0) * self.calcAlpha());
          self.fconfig[0, 1] := -2.0 * Sqrt(self.getValue()) * ((Sqrt(self.getValue()) - 1.0) + (Sqrt(self.getValue()) + 1.0) * Cos(self.calcOmega()));
          self.fconfig[0, 0] :=  1.0 * Sqrt(self.getValue()) * ((Sqrt(self.getValue()) + 1.0) + (Sqrt(self.getValue()) - 1.0) * Cos(self.calcOmega()) + 2.0 * Sqrt(Sqrt(self.getValue())) * (Sin(self.calcOmega()) / 2.0) * self.calcAlpha());
          self.fconfig[1, 2] :=  1.0 *          1.0          * ((Sqrt(self.getValue()) + 1.0) - (Sqrt(self.getValue()) - 1.0) * Cos(self.calcOmega()) - 2.0 * Sqrt(Sqrt(self.getValue())) * (Sin(self.calcOmega()) / 2.0) * self.calcAlpha());
          self.fconfig[1, 1] := +2.0 *          1.0          * ((Sqrt(self.getValue()) - 1.0) - (Sqrt(self.getValue()) + 1.0) * Cos(self.calcOmega()));
          self.fconfig[1, 0] :=  1.0 *          1.0          * ((Sqrt(self.getValue()) + 1.0) - (Sqrt(self.getValue()) - 1.0) * Cos(self.calcOmega()) + 2.0 * Sqrt(Sqrt(self.getValue())) * (Sin(self.calcOmega()) / 2.0) * self.calcAlpha());
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
          self.fconfig[0, 2] :=  1.0 - Tan(self.calcOmega() / 2.0) * self.calcAlpha() * self.getValue() + Sqr(Tan(self.calcOmega() / 2.0));
          self.fconfig[0, 1] := +2.0 * (Sqr(Tan(self.calcOmega() / 2.0)) - 1.0);
          self.fconfig[0, 0] :=  1.0 + Tan(self.calcOmega() / 2.0) * self.calcAlpha() * self.getValue() + Sqr(Tan(self.calcOmega() / 2.0));
          self.fconfig[1, 2] :=  1.0 - Tan(self.calcOmega() / 2.0) * self.calcAlpha() *      1.0       + Sqr(Tan(self.calcOmega() / 2.0));
          self.fconfig[1, 1] := +2.0 * (Sqr(Tan(self.calcOmega() / 2.0)) - 1.0);
          self.fconfig[1, 0] :=  1.0 + Tan(self.calcOmega() / 2.0) * self.calcAlpha() *      1.0       + Sqr(Tan(self.calcOmega() / 2.0));
        end;
        ftBass: begin
          self.fconfig[0, 2] :=  (      1.0      - Tan(self.calcOmega() / 2.0) * self.calcAlpha() *         1.0          + Sqr(Tan(self.calcOmega() / 2.0))) /      1.0      ;
          self.fconfig[0, 1] := +2.0 * (Sqr(Tan(self.calcOmega() / 2.0)) -      1.0      ) /      1.0      ;
          self.fconfig[0, 0] :=  (      1.0      + Tan(self.calcOmega() / 2.0) * self.calcAlpha() *         1.0          + Sqr(Tan(self.calcOmega() / 2.0))) /      1.0      ;
          self.fconfig[1, 2] :=  (self.getValue() - Tan(self.calcOmega() / 2.0) * self.calcAlpha() * Sqrt(self.getValue()) + Sqr(Tan(self.calcOmega() / 2.0))) / self.getValue();
          self.fconfig[1, 1] := +2.0 * (Sqr(Tan(self.calcOmega() / 2.0)) - self.getValue()) / self.getValue();
          self.fconfig[1, 0] :=  (self.getValue() + Tan(self.calcOmega() / 2.0) * self.calcAlpha() * Sqrt(self.getValue()) + Sqr(Tan(self.calcOmega() / 2.0))) / self.getValue();
        end;
        ftTreble: begin
          self.fconfig[0, 2] :=  (self.getValue() - Tan(self.calcOmega() / 2.0) * self.calcAlpha() * Sqrt(self.getValue()) + Sqr(Tan(self.calcOmega() / 2.0)));
          self.fconfig[0, 1] := +2.0 * (Sqr(Tan(self.calcOmega() / 2.0)) - self.getValue());
          self.fconfig[0, 0] :=  (self.getValue() + Tan(self.calcOmega() / 2.0) * self.calcAlpha() * Sqrt(self.getValue()) + Sqr(Tan(self.calcOmega() / 2.0)));
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
          self.fconfig[1, 2] :=  1.0 - Tan(self.calcOmega() / 2.0) * self.calcAlpha() / self.getValue() + Sqr(Tan(self.calcOmega() / 2.0));
          self.fconfig[1, 1] := +2.0 * (Sqr(Tan(self.calcOmega() / 2.0)) - 1.0);
          self.fconfig[1, 0] :=  1.0 + Tan(self.calcOmega() / 2.0) * self.calcAlpha() / self.getValue() + Sqr(Tan(self.calcOmega() / 2.0));
        end;
        ftBass: begin
          self.fconfig[0, 2] :=  (1.0 - Tan(self.calcOmega() / 2.0) * self.calcAlpha() * Sqrt(self.getValue()) + Sqr(Tan(self.calcOmega() / 2.0)) * self.getValue());
          self.fconfig[0, 1] := +2.0 * (Sqr(Tan(self.calcOmega() / 2.0)) * self.getValue() - 1.0);
          self.fconfig[0, 0] :=  (1.0 + Tan(self.calcOmega() / 2.0) * self.calcAlpha() * Sqrt(self.getValue()) + Sqr(Tan(self.calcOmega() / 2.0)) * self.getValue());
          self.fconfig[1, 2] :=  (1.0 - Tan(self.calcOmega() / 2.0) * self.calcAlpha() *          1.0          + Sqr(Tan(self.calcOmega() / 2.0)) *      1.0      );
          self.fconfig[1, 1] := +2.0 * (Sqr(Tan(self.calcOmega() / 2.0)) *       1.0       - 1.0);
          self.fconfig[1, 0] :=  (1.0 + Tan(self.calcOmega() / 2.0) * self.calcAlpha() *          1.0          + Sqr(Tan(self.calcOmega() / 2.0)) *      1.0      );
        end;
        ftTreble: begin
          self.fconfig[0, 2] :=  (1.0 - Tan(self.calcOmega() / 2.0) * self.calcAlpha() *          1.0          + Sqr(Tan(self.calcOmega() / 2.0)) *      1.0       ) /       1.0      ;
          self.fconfig[0, 1] := +2.0 * (Sqr(Tan(self.calcOmega() / 2.0)) *       1.0       - 1.0) /      1.0       ;
          self.fconfig[0, 0] :=  (1.0 + Tan(self.calcOmega() / 2.0) * self.calcAlpha() *          1.0          + Sqr(Tan(self.calcOmega() / 2.0)) *      1.0       ) /       1.0      ;
          self.fconfig[1, 2] :=  (1.0 - Tan(self.calcOmega() / 2.0) * self.calcAlpha() * Sqrt(self.getValue()) + Sqr(Tan(self.calcOmega() / 2.0)) * self.getValue()) / self.getValue();
          self.fconfig[1, 1] := +2.0 * (Sqr(Tan(self.calcOmega() / 2.0)) * self.getValue() - 1.0) / self.getValue();
          self.fconfig[1, 0] :=  (1.0 + Tan(self.calcOmega() / 2.0) * self.calcAlpha() * Sqrt(self.getValue()) + Sqr(Tan(self.calcOmega() / 2.0)) * self.getValue()) / self.getValue();
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
          self.fconfig[0, 1] :=  (Sqrt(self.getValue()) - 1.0 / Sqrt(self.getValue())) * self.calcAlpha();
          self.fconfig[0, 2] :=  0.0;
          self.fconfig[1, 0] :=  1.0 / (1.0 + Tan(self.calcOmega() / 2.0) * (Tan(self.calcOmega() / 2.0) + self.calcAlpha() / Sqrt(self.getValue())));
          self.fconfig[1, 1] :=  (Tan(self.calcOmega() / 2.0)) * self.fconfig[1, 0];
          self.fconfig[1, 2] :=  (Tan(self.calcOmega() / 2.0)) * self.fconfig[1, 1];
        end;
        ftBass: begin
          self.fconfig[0, 0] :=  1.0;
          self.fconfig[0, 1] :=  (Sqrt(self.getValue()) - 1.0) * self.calcAlpha();
          self.fconfig[0, 2] :=  (self.getValue() - 1.0);
          self.fconfig[1, 0] :=  1.0 / (1.0 + Tan(self.calcOmega() / 2.0) / Sqrt(Sqrt(self.getValue())) * (Tan(self.calcOmega() / 2.0) / Sqrt(Sqrt(self.getValue())) + self.calcAlpha()));
          self.fconfig[1, 1] :=  (Tan(self.calcOmega() / 2.0) / Sqrt(Sqrt(self.getValue()))) * self.fconfig[1, 0];
          self.fconfig[1, 2] :=  (Tan(self.calcOmega() / 2.0) / Sqrt(Sqrt(self.getValue()))) * self.fconfig[1, 1];
        end;
        ftTreble: begin
          self.fconfig[0, 0] :=  self.getValue();
          self.fconfig[0, 1] :=  (Sqrt(self.getValue()) - self.getValue()) * self.calcAlpha();
          self.fconfig[0, 2] :=  (1.0 - self.getValue());
          self.fconfig[1, 0] :=  1.0 / (1.0 + Tan(self.calcOmega() / 2.0) / Sqrt(Sqrt(self.getValue())) * (Tan(self.calcOmega() / 2.0) / Sqrt(Sqrt(self.getValue())) + self.calcAlpha()));
          self.fconfig[1, 1] :=  (Tan(self.calcOmega() / 2.0) / Sqrt(Sqrt(self.getValue()))) * self.fconfig[1, 0];
          self.fconfig[1, 2] :=  (Tan(self.calcOmega() / 2.0) / Sqrt(Sqrt(self.getValue()))) * self.fconfig[1, 1];
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

function TWMPBQF.Process(const Data: Double): Double;
begin
  case (self.ftransform) of
    ptLAT: begin
      self.fsignal[0, 2] := self.fsignal[0, 1];
      self.fsignal[0, 1] := self.fsignal[0, 0];
      self.fsignal[0, 0] := Data;
      self.fsignal[1, 2] := self.fsignal[1, 1];
      self.fsignal[1, 1] := self.fsignal[1, 0];
      self.fsignal[1, 0] := ((self.fsignal[0, 0] * self.fconfig[0, 0] + self.fsignal[0, 1] * self.fconfig[0, 1] + self.fsignal[0, 2] * self.fconfig[0, 2]) - (self.fsignal[1, 1] * self.fconfig[1, 1] + self.fsignal[1, 2] * self.fconfig[1, 2])) / self.fconfig[1, 0];
    end;
    ptSVF: begin
      self.fsignal[0, 2] := self.fsignal[0, 1];
      self.fsignal[0, 1] := self.fsignal[0, 0];
      self.fsignal[0, 0] := Data;
      self.fsignal[1, 2] := self.fsignal[1, 1];
      self.fsignal[1, 1] := self.fsignal[1, 0];
      self.fsignal[1, 0] := ((self.fsignal[0, 0] * self.fconfig[0, 0] + self.fsignal[0, 1] * self.fconfig[0, 1] + self.fsignal[0, 2] * self.fconfig[0, 2]) - (self.fsignal[1, 1] * self.fconfig[1, 1] + self.fsignal[1, 2] * self.fconfig[1, 2])) / self.fconfig[1, 0];
    end;
    ptZDF: begin
      self.fsignal[0, 2] := self.fsignal[0, 1];
      self.fsignal[0, 1] := self.fsignal[0, 0];
      self.fsignal[0, 0] := Data;
      self.fsignal[1, 2] := self.fsignal[1, 1];
      self.fsignal[1, 1] := self.fsignal[1, 0];
      self.fsignal[1, 0] := ((self.fsignal[0, 0] * self.fconfig[0, 0] + self.fsignal[0, 1] * self.fconfig[0, 1] + self.fsignal[0, 2] * self.fconfig[0, 2]) - (self.fsignal[1, 1] * self.fconfig[1, 1] + self.fsignal[1, 2] * self.fconfig[1, 2])) / self.fconfig[1, 0];
    end;
    ptTDI: begin
      self.fsignal[0, 0] := Data;
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

procedure TWMPBQF.setAmp(const Data: Double);
begin
  if (self.famp <> Data) then begin
    self.famp := Data;
    self.calcConfig();
  end;
end;

function TWMPBQF.getFreq(): Double;
begin
  Result := self.ffreq;
end;

procedure TWMPBQF.setFreq(const Data: Double);
begin
  if (self.ffreq <> Data) then begin
    self.ffreq := Data;
    self.calcConfig();
  end;
end;

function TWMPBQF.getRate(): Double;
begin
  Result := self.frate;
end;

procedure TWMPBQF.setRate(const Data: Double);
begin
  if (self.frate <> Data) then begin
    self.frate := Data;
    self.calcConfig();
  end;
end;

function TWMPBQF.getWidth(): Double;
begin
  Result := self.fwidth;
end;

procedure TWMPBQF.setWidth(const Data: Double);
begin
  if (self.fwidth <> Data) then begin
    self.fwidth := Data;
    self.calcConfig();
  end;
end;

begin
end.
