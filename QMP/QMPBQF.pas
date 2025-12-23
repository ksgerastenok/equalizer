unit
  QMPBQF;

interface

type
  TGain = (gtDb, gtAmp);

type
  TBand = (btQ, btHz, btKHz, btOctave, btSemitone, btSlope);

type
  TFilter = (ftLow, ftHigh, ftPeak, ftBand, ftReject, ftAll, ftEqu, ftBass, ftTreble);

type
  TTransform = (ptSVF, ptZDF);

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
      Result := self.fwidth;
    end;
    btHz: begin
      Result := self.ffreq / (self.fwidth *    1.0);
    end;
    btKHz: begin
      Result := self.ffreq / (self.fwidth * 1000.0);
    end;
    btOctave: begin
      Result := 0.5 / Sinh((Ln(2.0) / 2.0) * (self.fwidth /  1.0) / (Sin(self.calcOmega()) / self.calcOmega()));
    end;
    btSemitone: begin
      Result := 0.5 / Sinh((Ln(2.0) / 2.0) * (self.fwidth / 12.0) / (Sin(self.calcOmega()) / self.calcOmega()));
    end;
    btSlope: begin
      Result := 1.0 / Sqrt((Sqrt(self.calcAmp()) + 1.0 / Sqrt(self.calcAmp())) * (1.0 / self.fwidth - 1.0) + 2.0);
    end;
    else begin
      Result := 0.0;
    end;
  end;
  Result := 1.0 / Result;
end;

procedure TQMPBQF.calcConfig();
begin
  case (self.ffilter) of
    ftLow: begin
      case (self.ftransform) of
        ptSVF: begin
          self.fconfig[0, 2] :=  1.0 * ((1.0 - Cos(self.calcOmega())) / 2.0);
          self.fconfig[0, 1] := +2.0 * ((1.0 - Cos(self.calcOmega())) / 2.0);
          self.fconfig[0, 0] :=  1.0 * ((1.0 - Cos(self.calcOmega())) / 2.0);
          self.fconfig[1, 2] :=  1.0 - (Sin(self.calcOmega()) / 2.0) * self.calcAlpha();
          self.fconfig[1, 1] := -2.0 * (Cos(self.calcOmega()));
          self.fconfig[1, 0] :=  1.0 + (Sin(self.calcOmega()) / 2.0) * self.calcAlpha();
        end;
        ptZDF: begin
          self.fconfig[0, 0] :=  0.0;
          self.fconfig[0, 1] :=  0.0;
          self.fconfig[0, 2] := +1.0;
          self.fconfig[1, 0] :=  1.0 / (1.0 + Tan(self.calcOmega() / 2.0) * (Tan(self.calcOmega() / 2.0) + self.calcAlpha()));
          self.fconfig[1, 1] := (Tan(self.calcOmega() / 2.0)) * self.fconfig[1, 0];
          self.fconfig[1, 2] := (Tan(self.calcOmega() / 2.0)) * self.fconfig[1, 1];
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
    ftHigh: begin
      case (self.ftransform) of
        ptSVF: begin
          self.fconfig[0, 2] :=  1.0 * ((1 + Cos(self.calcOmega())) / 2.0);
          self.fconfig[0, 1] := -2.0 * ((1 + Cos(self.calcOmega())) / 2.0);
          self.fconfig[0, 0] :=  1.0 * ((1 + Cos(self.calcOmega())) / 2.0);
          self.fconfig[1, 2] :=  1.0 - (Sin(self.calcOmega()) / 2.0) * self.calcAlpha();
          self.fconfig[1, 1] := -2.0 * (Cos(self.calcOmega()));
          self.fconfig[1, 0] :=  1.0 + (Sin(self.calcOmega()) / 2.0) * self.calcAlpha();
        end;
        ptZDF: begin
          self.fconfig[0, 0] :=  1.0;
          self.fconfig[0, 1] := -1.0 * self.calcAlpha();
          self.fconfig[0, 2] := -1.0;
          self.fconfig[1, 0] :=  1.0 / (1.0 + Tan(self.calcOmega() / 2.0) * (Tan(self.calcOmega() / 2.0) + self.calcAlpha()));
          self.fconfig[1, 1] := (Tan(self.calcOmega() / 2.0)) * self.fconfig[1, 0];
          self.fconfig[1, 2] := (Tan(self.calcOmega() / 2.0)) * self.fconfig[1, 1];
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
    ftPeak: begin
      case (self.ftransform) of
        ptSVF: begin
          self.fconfig[0, 2] :=  0.0 - (Sin(self.calcOmega()) / 2.0) *       1.0       ;
          self.fconfig[0, 1] :=  0.0;
          self.fconfig[0, 0] :=  0.0 + (Sin(self.calcOmega()) / 2.0) *       1.0       ;
          self.fconfig[1, 2] :=  1.0 - (Sin(self.calcOmega()) / 2.0) * self.calcAlpha();
          self.fconfig[1, 1] := -2.0 * (Cos(self.calcOmega()));
          self.fconfig[1, 0] :=  1.0 + (Sin(self.calcOmega()) / 2.0) * self.calcAlpha();
        end;
        ptZDF: begin
          self.fconfig[0, 0] :=  0.0;
          self.fconfig[0, 1] :=  1.0;
          self.fconfig[0, 2] :=  0.0;
          self.fconfig[1, 0] :=  1.0 / (1.0 + Tan(self.calcOmega() / 2.0) * (Tan(self.calcOmega() / 2.0) + self.calcAlpha()));
          self.fconfig[1, 1] := (Tan(self.calcOmega() / 2.0)) * self.fconfig[1, 0];
          self.fconfig[1, 2] := (Tan(self.calcOmega() / 2.0)) * self.fconfig[1, 1];
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
    ftBand: begin
      case (self.ftransform) of
        ptSVF: begin
          self.fconfig[0, 2] :=  0.0 - (Sin(self.calcOmega()) / 2.0) * self.calcAlpha();
          self.fconfig[0, 1] :=  0.0;
          self.fconfig[0, 0] :=  0.0 + (Sin(self.calcOmega()) / 2.0) * self.calcAlpha();
          self.fconfig[1, 2] :=  1.0 - (Sin(self.calcOmega()) / 2.0) * self.calcAlpha();
          self.fconfig[1, 1] := -2.0 * (Cos(self.calcOmega()));
          self.fconfig[1, 0] :=  1.0 + (Sin(self.calcOmega()) / 2.0) * self.calcAlpha();
        end;
        ptZDF: begin
          self.fconfig[0, 0] :=  0.0;
          self.fconfig[0, 1] :=  1.0 * self.calcAlpha();
          self.fconfig[0, 2] :=  0.0;
          self.fconfig[1, 0] :=  1.0 / (1.0 + Tan(self.calcOmega() / 2.0) * (Tan(self.calcOmega() / 2.0) + self.calcAlpha()));
          self.fconfig[1, 1] := (Tan(self.calcOmega() / 2.0)) * self.fconfig[1, 0];
          self.fconfig[1, 2] := (Tan(self.calcOmega() / 2.0)) * self.fconfig[1, 1];
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
    ftReject: begin
      case (self.ftransform) of
        ptSVF: begin
          self.fconfig[0, 2] :=  1.0;
          self.fconfig[0, 1] := -2.0 * (Cos(self.calcOmega()));
          self.fconfig[0, 0] :=  1.0;
          self.fconfig[1, 2] :=  1.0 - (Sin(self.calcOmega()) / 2.0) * self.calcAlpha();
          self.fconfig[1, 1] := -2.0 * (Cos(self.calcOmega()));
          self.fconfig[1, 0] :=  1.0 + (Sin(self.calcOmega()) / 2.0) * self.calcAlpha();
        end;
        ptZDF: begin
          self.fconfig[0, 0] :=  1.0;
          self.fconfig[0, 1] := -1.0 * self.calcAlpha();
          self.fconfig[0, 2] :=  0.0;
          self.fconfig[1, 0] :=  1.0 / (1.0 + Tan(self.calcOmega() / 2.0) * (Tan(self.calcOmega() / 2.0) + self.calcAlpha()));
          self.fconfig[1, 1] := (Tan(self.calcOmega() / 2.0)) * self.fconfig[1, 0];
          self.fconfig[1, 2] := (Tan(self.calcOmega() / 2.0)) * self.fconfig[1, 1];
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
    ftAll: begin
      case (self.ftransform) of
        ptSVF: begin
          self.fconfig[0, 2] :=  1.0 + (Sin(self.calcOmega()) / 2.0) * self.calcAlpha();
          self.fconfig[0, 1] := -2.0 * (Cos(self.calcOmega()));
          self.fconfig[0, 0] :=  1.0 - (Sin(self.calcOmega()) / 2.0) * self.calcAlpha();
          self.fconfig[1, 2] :=  1.0 - (Sin(self.calcOmega()) / 2.0) * self.calcAlpha();
          self.fconfig[1, 1] := -2.0 * (Cos(self.calcOmega()));
          self.fconfig[1, 0] :=  1.0 + (Sin(self.calcOmega()) / 2.0) * self.calcAlpha();
        end;
        ptZDF: begin
          self.fconfig[0, 0] :=  1.0;
          self.fconfig[0, 1] := -2.0 * self.calcAlpha();
          self.fconfig[0, 2] :=  0.0;
          self.fconfig[1, 0] :=  1.0 / (1.0 + Tan(self.calcOmega() / 2.0) * (Tan(self.calcOmega() / 2.0) + self.calcAlpha()));
          self.fconfig[1, 1] := (Tan(self.calcOmega() / 2.0)) * self.fconfig[1, 0];
          self.fconfig[1, 2] := (Tan(self.calcOmega() / 2.0)) * self.fconfig[1, 1];
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
    ftEqu: begin
      case (self.ftransform) of
        ptSVF: begin
          self.fconfig[0, 2] :=  1.0 - (Sin(self.calcOmega()) / 2.0) * self.calcAlpha() * Sqrt(self.calcAmp());
          self.fconfig[0, 1] := -2.0 * (Cos(self.calcOmega()));
          self.fconfig[0, 0] :=  1.0 + (Sin(self.calcOmega()) / 2.0) * self.calcAlpha() * Sqrt(self.calcAmp());
          self.fconfig[1, 2] :=  1.0 - (Sin(self.calcOmega()) / 2.0) * self.calcAlpha() / Sqrt(self.calcAmp());
          self.fconfig[1, 1] := -2.0 * (Cos(self.calcOmega()));
          self.fconfig[1, 0] :=  1.0 + (Sin(self.calcOmega()) / 2.0) * self.calcAlpha() / Sqrt(self.calcAmp());
        end;
        ptZDF: begin
          self.fconfig[0, 0] :=  1.0;
          self.fconfig[0, 1] := (Sqrt(self.calcAmp()) - 1.0 / Sqrt(self.calcAmp())) * self.calcAlpha();
          self.fconfig[0, 2] :=  0.0;
          self.fconfig[1, 0] :=  1.0 / (1.0 + Tan(self.calcOmega() / 2.0) * (Tan(self.calcOmega() / 2.0) + self.calcAlpha() / Sqrt(self.calcAmp())));
          self.fconfig[1, 1] := (Tan(self.calcOmega() / 2.0)) * self.fconfig[1, 0];
          self.fconfig[1, 2] := (Tan(self.calcOmega() / 2.0)) * self.fconfig[1, 1];
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
    ftBass: begin
      case (self.ftransform) of
        ptSVF: begin
          self.fconfig[0, 2] :=  1.0 * Sqrt(self.calcAmp()) * ((Sqrt(self.calcAmp()) + 1.0) - (Sqrt(self.calcAmp()) - 1.0) * Cos(self.calcOmega()) - 2.0 * Sqrt(Sqrt(self.calcAmp())) * (Sin(self.calcOmega()) / 2.0) * self.calcAlpha());
          self.fconfig[0, 1] := +2.0 * Sqrt(self.calcAmp()) * ((Sqrt(self.calcAmp()) - 1.0) - (Sqrt(self.calcAmp()) + 1.0) * Cos(self.calcOmega()));
          self.fconfig[0, 0] :=  1.0 * Sqrt(self.calcAmp()) * ((Sqrt(self.calcAmp()) + 1.0) - (Sqrt(self.calcAmp()) - 1.0) * Cos(self.calcOmega()) + 2.0 * Sqrt(Sqrt(self.calcAmp())) * (Sin(self.calcOmega()) / 2.0) * self.calcAlpha());
          self.fconfig[1, 2] :=  1.0 *         1.0          * ((Sqrt(self.calcAmp()) + 1.0) + (Sqrt(self.calcAmp()) - 1.0) * Cos(self.calcOmega()) - 2.0 * Sqrt(Sqrt(self.calcAmp())) * (Sin(self.calcOmega()) / 2.0) * self.calcAlpha());
          self.fconfig[1, 1] := -2.0 *         1.0          * ((Sqrt(self.calcAmp()) - 1.0) + (Sqrt(self.calcAmp()) + 1.0) * Cos(self.calcOmega()));
          self.fconfig[1, 0] :=  1.0 *         1.0          * ((Sqrt(self.calcAmp()) + 1.0) + (Sqrt(self.calcAmp()) - 1.0) * Cos(self.calcOmega()) + 2.0 * Sqrt(Sqrt(self.calcAmp())) * (Sin(self.calcOmega()) / 2.0) * self.calcAlpha());
        end;
        ptZDF: begin
          self.fconfig[0, 0] :=  1.0;
          self.fconfig[0, 1] := (Sqrt(self.calcAmp()) - 1.0) * self.calcAlpha();
          self.fconfig[0, 2] := (self.calcAmp() - 1.0);
          self.fconfig[1, 0] :=  1.0 / (1.0 + Tan(self.calcOmega() / 2.0) / Sqrt(Sqrt(self.calcAmp())) * (Tan(self.calcOmega() / 2.0) / Sqrt(Sqrt(self.calcAmp())) + self.calcAlpha()));
          self.fconfig[1, 1] := (Tan(self.calcOmega() / 2.0) / Sqrt(Sqrt(self.calcAmp()))) * self.fconfig[1, 0];
          self.fconfig[1, 2] := (Tan(self.calcOmega() / 2.0) / Sqrt(Sqrt(self.calcAmp()))) * self.fconfig[1, 1];
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
    ftTreble: begin
      case (self.ftransform) of
        ptSVF: begin
          self.fconfig[0, 2] :=  1.0 * Sqrt(self.calcAmp()) * ((Sqrt(self.calcAmp()) + 1.0) + (Sqrt(self.calcAmp()) - 1.0) * Cos(self.calcOmega()) - 2.0 * Sqrt(Sqrt(self.calcAmp())) * (Sin(self.calcOmega()) / 2.0) * self.calcAlpha());
          self.fconfig[0, 1] := -2.0 * Sqrt(self.calcAmp()) * ((Sqrt(self.calcAmp()) - 1.0) + (Sqrt(self.calcAmp()) + 1.0) * Cos(self.calcOmega()));
          self.fconfig[0, 0] :=  1.0 * Sqrt(self.calcAmp()) * ((Sqrt(self.calcAmp()) + 1.0) + (Sqrt(self.calcAmp()) - 1.0) * Cos(self.calcOmega()) + 2.0 * Sqrt(Sqrt(self.calcAmp())) * (Sin(self.calcOmega()) / 2.0) * self.calcAlpha());
          self.fconfig[1, 2] :=  1.0 *         1.0          * ((Sqrt(self.calcAmp()) + 1.0) - (Sqrt(self.calcAmp()) - 1.0) * Cos(self.calcOmega()) - 2.0 * Sqrt(Sqrt(self.calcAmp())) * (Sin(self.calcOmega()) / 2.0) * self.calcAlpha());
          self.fconfig[1, 1] := +2.0 *         1.0          * ((Sqrt(self.calcAmp()) - 1.0) - (Sqrt(self.calcAmp()) + 1.0) * Cos(self.calcOmega()));
          self.fconfig[1, 0] :=  1.0 *         1.0          * ((Sqrt(self.calcAmp()) + 1.0) - (Sqrt(self.calcAmp()) - 1.0) * Cos(self.calcOmega()) + 2.0 * Sqrt(Sqrt(self.calcAmp())) * (Sin(self.calcOmega()) / 2.0) * self.calcAlpha());
        end;
        ptZDF: begin
          self.fconfig[0, 0] :=  self.calcAmp();
          self.fconfig[0, 1] := (Sqrt(self.calcAmp()) - self.calcAmp()) * self.calcAlpha();
          self.fconfig[0, 2] := (1.0 - self.calcAmp());
          self.fconfig[1, 0] :=  1.0 / (1.0 + Tan(self.calcOmega() / 2.0) / Sqrt(Sqrt(self.calcAmp())) * (Tan(self.calcOmega() / 2.0) / Sqrt(Sqrt(self.calcAmp())) + self.calcAlpha()));
          self.fconfig[1, 1] := (Tan(self.calcOmega() / 2.0) / Sqrt(Sqrt(self.calcAmp()))) * self.fconfig[1, 0];
          self.fconfig[1, 2] := (Tan(self.calcOmega() / 2.0) / Sqrt(Sqrt(self.calcAmp()))) * self.fconfig[1, 1];
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
    ptSVF: begin
      self.fsignal[0, 2] := self.fsignal[0, 1];
      self.fsignal[0, 1] := self.fsignal[0, 0];
      self.fsignal[0, 0] := Value;
      self.fsignal[1, 2] := self.fsignal[1, 1];
      self.fsignal[1, 1] := self.fsignal[1, 0];
      self.fsignal[1, 0] := ((self.fsignal[0, 0] * self.fconfig[0, 0] + self.fsignal[0, 1] * self.fconfig[0, 1] + self.fsignal[0, 2] * self.fconfig[0, 2]) - (self.fsignal[1, 1] * self.fconfig[1, 1] + self.fsignal[1, 2] * self.fconfig[1, 2])) / self.fconfig[1, 0];
    end;
    ptZDF: begin
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
  self.famp := Value;
  self.calcConfig();
end;

function TQMPBQF.getFreq(): Double;
begin
  Result := self.ffreq;
end;

procedure TQMPBQF.setFreq(const Value: Double);
begin
  self.ffreq := Value;
  self.calcConfig();
end;

function TQMPBQF.getRate(): Double;
begin
  Result := self.frate;
end;

procedure TQMPBQF.setRate(const Value: Double);
begin
  self.frate := Value;
  self.calcConfig();
end;

function TQMPBQF.getWidth(): Double;
begin
  Result := self.fwidth;
end;

procedure TQMPBQF.setWidth(const Value: Double);
begin
  self.fwidth := Value;
  self.calcConfig();
end;

begin
end.
