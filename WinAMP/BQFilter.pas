unit
  BQFilter;

interface

type
  TBand = (btQ, btHz, btSlope, btOctave, btSemitone);

type
  TFilter = (ftEqu, ftInv, ftLow, ftBand, ftBass, ftHigh, ftPeak, ftNotch, ftTreble);

type
  TBQFilter = class(TObject)
  private
    fband: TBand;
    ffilter: TFilter;
    fenabled: Boolean;
    fcfg: array[0..2, 0..1, 0..2] of Double;
    function getBand(): TBand;
    procedure setBand(const Value: TBand);
    function getFilter(): TFilter;
    procedure setFilter(const Value: TFilter);
    function getEnabled(): Boolean;
    procedure setEnabled(const Value: Boolean);
    function getGain(): Double;
    procedure setGain(const Value: Double);
    function getWidth(): Double;
    procedure setWidth(const Value: Double);
    function getFreq(): Double;
    procedure setFreq(const Value: Double);
    function getRate(): Double;
    procedure setRate(const Value: Double);
    procedure Configure();
    procedure Calculate();
  public
    constructor Create();
    destructor Destroy(); override;
    function Process(const input: Double): Double;
    property Band: TBand read getBand write setBand;
    property Filter: TFilter read getFilter write setFilter;
    property Enabled: Boolean read getEnabled write setEnabled;
    property Gain: Double read getGain write setGain;
    property Width: Double read getWidth write setWidth;
    property Freq: Double read getFreq write setFreq;
    property Rate: Double read getRate write setRate;
  end;

implementation

uses
  Math;

constructor TBQFilter.Create();
begin
  inherited Create();
  self.fenabled := false;
end;

destructor TBQFilter.Destroy();
begin
  self.fenabled := false;
  inherited Destroy();
end;

procedure TBQFilter.Configure();
begin
  try
    case(self.fband) of
      btQ: begin
        self.fcfg[0, 0, 0] := self.fcfg[0, 0, 0];
        self.fcfg[0, 0, 1] := self.fcfg[0, 0, 1];
        self.fcfg[0, 0, 2] := self.fcfg[0, 0, 2];
        self.fcfg[0, 1, 0] := self.fcfg[0, 1, 0];
        self.fcfg[0, 1, 1] := 2 * PI * self.fcfg[0, 0, 1] / self.fcfg[0, 0, 2];
        self.fcfg[0, 1, 2] := 1 / self.fcfg[0, 0, 0];
      end;
      btHz: begin
        self.fcfg[0, 0, 0] := self.fcfg[0, 0, 0];
        self.fcfg[0, 0, 1] := self.fcfg[0, 0, 1];
        self.fcfg[0, 0, 2] := self.fcfg[0, 0, 2];
        self.fcfg[0, 1, 0] := self.fcfg[0, 1, 0];
        self.fcfg[0, 1, 1] := 2 * PI * self.fcfg[0, 0, 1] / self.fcfg[0, 0, 2];
        self.fcfg[0, 1, 2] := 2 * Sinh((Ln(2) / 2) * self.fcfg[0, 0, 0]);
      end;
      btSlope: begin
        self.fcfg[0, 0, 0] := self.fcfg[0, 0, 0];
        self.fcfg[0, 0, 1] := self.fcfg[0, 0, 1];
        self.fcfg[0, 0, 2] := self.fcfg[0, 0, 2];
        self.fcfg[0, 1, 0] := self.fcfg[0, 1, 0];
        self.fcfg[0, 1, 1] := 2 * PI * self.fcfg[0, 0, 1] / self.fcfg[0, 0, 2];
        self.fcfg[0, 1, 2] := Sqrt((Sqrt(self.fcfg[0, 1, 0]) + (1 / Sqrt(self.fcfg[0, 1, 0]))) * (1 / self.fcfg[0, 0, 0] - 1) + 2);
      end;
      btOctave: begin
        self.fcfg[0, 0, 0] := self.fcfg[0, 0, 0];
        self.fcfg[0, 0, 1] := self.fcfg[0, 0, 1];
        self.fcfg[0, 0, 2] := self.fcfg[0, 0, 2];
        self.fcfg[0, 1, 0] := self.fcfg[0, 1, 0];
        self.fcfg[0, 1, 1] := 2 * PI * self.fcfg[0, 0, 1] / self.fcfg[0, 0, 2];
        self.fcfg[0, 1, 2] := 2 * Sinh((Ln(2) / 2) * (self.fcfg[0, 0, 0] / 1.0) / (Sin(self.fcfg[0, 1, 1]) / self.fcfg[0, 1, 1]));
      end;
      btSemitone: begin
        self.fcfg[0, 0, 0] := self.fcfg[0, 0, 0];
        self.fcfg[0, 0, 1] := self.fcfg[0, 0, 1];
        self.fcfg[0, 0, 2] := self.fcfg[0, 0, 2];
        self.fcfg[0, 1, 0] := self.fcfg[0, 1, 0];
        self.fcfg[0, 1, 1] := 2 * PI * self.fcfg[0, 0, 1] / self.fcfg[0, 0, 2];
        self.fcfg[0, 1, 2] := 2 * Sinh((Ln(2) / 2) * (self.fcfg[0, 0, 0] / 12) / (Sin(self.fcfg[0, 1, 1]) / self.fcfg[0, 1, 1]));
      end;
      else begin
        self.fcfg[0, 0, 0] := self.fcfg[0, 0, 0];
        self.fcfg[0, 0, 1] := self.fcfg[0, 0, 1];
        self.fcfg[0, 0, 2] := self.fcfg[0, 0, 2];
        self.fcfg[0, 1, 0] := self.fcfg[0, 1, 0];
        self.fcfg[0, 1, 1] := 0;
        self.fcfg[0, 1, 2] := 0;
      end;
    end;
  except
    self.fcfg[0, 0, 0] := self.fcfg[0, 0, 0];
    self.fcfg[0, 0, 1] := self.fcfg[0, 0, 1];
    self.fcfg[0, 0, 2] := self.fcfg[0, 0, 2];
    self.fcfg[0, 1, 0] := self.fcfg[0, 1, 0];
    self.fcfg[0, 1, 1] := 0;
    self.fcfg[0, 1, 2] := 0;
  end;
end;

procedure TBQFilter.Calculate();
begin
  try
    case(self.ffilter) of
      ftEqu: begin
        self.fcfg[1, 0, 0] := 1 + (self.fcfg[0, 1, 2] * Sin(self.fcfg[0, 1, 1]) / 2) * Sqrt(self.fcfg[0, 1, 0]);
        self.fcfg[1, 0, 1] := -2 * Cos(self.fcfg[0, 1, 1]);
        self.fcfg[1, 0, 2] := 1 - (self.fcfg[0, 1, 2] * Sin(self.fcfg[0, 1, 1]) / 2) * Sqrt(self.fcfg[0, 1, 0]);
        self.fcfg[1, 1, 0] := 1 + (self.fcfg[0, 1, 2] * Sin(self.fcfg[0, 1, 1]) / 2) / Sqrt(self.fcfg[0, 1, 0]);
        self.fcfg[1, 1, 1] := -2 * Cos(self.fcfg[0, 1, 1]);
        self.fcfg[1, 1, 2] := 1 - (self.fcfg[0, 1, 2] * Sin(self.fcfg[0, 1, 1]) / 2) / Sqrt(self.fcfg[0, 1, 0]);
      end;
      ftInv: begin
        self.fcfg[1, 0, 0] := 1 - (self.fcfg[0, 1, 2] * Sin(self.fcfg[0, 1, 1]) / 2) * 1.0;
        self.fcfg[1, 0, 1] := -2 * Cos(self.fcfg[0, 1, 1]);
        self.fcfg[1, 0, 2] := 1 + (self.fcfg[0, 1, 2] * Sin(self.fcfg[0, 1, 1]) / 2) * 1.0;
        self.fcfg[1, 1, 0] := 1 + (self.fcfg[0, 1, 2] * Sin(self.fcfg[0, 1, 1]) / 2) / 1.0;
        self.fcfg[1, 1, 1] := -2 * Cos(self.fcfg[0, 1, 1]);
        self.fcfg[1, 1, 2] := 1 - (self.fcfg[0, 1, 2] * Sin(self.fcfg[0, 1, 1]) / 2) / 1.0;
      end;
      ftLow: begin
        self.fcfg[1, 0, 0] := (1 - Cos(self.fcfg[0, 1, 1])) / +2.0;
        self.fcfg[1, 0, 1] := (1 - Cos(self.fcfg[0, 1, 1])) / +1.0;
        self.fcfg[1, 0, 2] := (1 - Cos(self.fcfg[0, 1, 1])) / +2.0;
        self.fcfg[1, 1, 0] := 1 + (self.fcfg[0, 1, 2] * Sin(self.fcfg[0, 1, 1]) / 2);
        self.fcfg[1, 1, 1] := -2 * Cos(self.fcfg[0, 1, 1]);
        self.fcfg[1, 1, 2] := 1 - (self.fcfg[0, 1, 2] * Sin(self.fcfg[0, 1, 1]) / 2);
      end;
      ftHigh: begin
        self.fcfg[1, 0, 0] := (1 + Cos(self.fcfg[0, 1, 1])) / +2.0;
        self.fcfg[1, 0, 1] := (1 + Cos(self.fcfg[0, 1, 1])) / -1.0;
        self.fcfg[1, 0, 2] := (1 + Cos(self.fcfg[0, 1, 1])) / +2.0;
        self.fcfg[1, 1, 0] := 1 + (self.fcfg[0, 1, 2] * Sin(self.fcfg[0, 1, 1]) / 2);
        self.fcfg[1, 1, 1] := -2 * Cos(self.fcfg[0, 1, 1]);
        self.fcfg[1, 1, 2] := 1 - (self.fcfg[0, 1, 2] * Sin(self.fcfg[0, 1, 1]) / 2);
      end;
      ftPeak: begin
        self.fcfg[1, 0, 0] := 0 + Sin(self.fcfg[0, 1, 1]) / 2;
        self.fcfg[1, 0, 1] := -0 * Cos(self.fcfg[0, 1, 1]);
        self.fcfg[1, 0, 2] := 0 - Sin(self.fcfg[0, 1, 1]) / 2;
        self.fcfg[1, 1, 0] := 1 + (self.fcfg[0, 1, 2] * Sin(self.fcfg[0, 1, 1]) / 2);
        self.fcfg[1, 1, 1] := -2 * Cos(self.fcfg[0, 1, 1]);
        self.fcfg[1, 1, 2] := 1 - (self.fcfg[0, 1, 2] * Sin(self.fcfg[0, 1, 1]) / 2);
      end;
      ftBand: begin
        self.fcfg[1, 0, 0] := 0 + (self.fcfg[0, 1, 2] * Sin(self.fcfg[0, 1, 1]) / 2);
        self.fcfg[1, 0, 1] := -0 * Cos(self.fcfg[0, 1, 1]);
        self.fcfg[1, 0, 2] := 0 - (self.fcfg[0, 1, 2] * Sin(self.fcfg[0, 1, 1]) / 2);
        self.fcfg[1, 1, 0] := 1 + (self.fcfg[0, 1, 2] * Sin(self.fcfg[0, 1, 1]) / 2);
        self.fcfg[1, 1, 1] := -2 * Cos(self.fcfg[0, 1, 1]);
        self.fcfg[1, 1, 2] := 1 - (self.fcfg[0, 1, 2] * Sin(self.fcfg[0, 1, 1]) / 2);
      end;
      ftNotch: begin
        self.fcfg[1, 0, 0] := 1 - (0.0 * Sin(self.fcfg[0, 1, 1]) / 2);
        self.fcfg[1, 0, 1] := -2 * Cos(self.fcfg[0, 1, 1]);
        self.fcfg[1, 0, 2] := 1 + (0.0 * Sin(self.fcfg[0, 1, 1]) / 2);
        self.fcfg[1, 1, 0] := 1 + (self.fcfg[0, 1, 2] * Sin(self.fcfg[0, 1, 1]) / 2);
        self.fcfg[1, 1, 0] := -2 * Cos(self.fcfg[0, 1, 1]);
        self.fcfg[1, 1, 0] := 1 - (self.fcfg[0, 1, 2] * Sin(self.fcfg[0, 1, 1]) / 2);
      end;
      ftBass: begin
        self.fcfg[1, 0, 0] := +1 * Sqrt(self.fcfg[0, 1, 0]) * ((Sqrt(self.fcfg[0, 1, 0]) + 1) - (Sqrt(self.fcfg[0, 1, 0]) - 1) * Cos(self.fcfg[0, 1, 1]) + 2 * Sqrt(Sqrt(self.fcfg[0, 1, 0])) * (self.fcfg[0, 1, 2] * Sin(self.fcfg[0, 1, 1]) / 2));
        self.fcfg[1, 0, 1] := +2 * Sqrt(self.fcfg[0, 1, 0]) * ((Sqrt(self.fcfg[0, 1, 0]) - 1) - (Sqrt(self.fcfg[0, 1, 0]) + 1) * Cos(self.fcfg[0, 1, 1]));
        self.fcfg[1, 0, 2] := +1 * Sqrt(self.fcfg[0, 1, 0]) * ((Sqrt(self.fcfg[0, 1, 0]) + 1) - (Sqrt(self.fcfg[0, 1, 0]) - 1) * Cos(self.fcfg[0, 1, 1]) - 2 * Sqrt(Sqrt(self.fcfg[0, 1, 0])) * (self.fcfg[0, 1, 2] * Sin(self.fcfg[0, 1, 1]) / 2));
        self.fcfg[1, 1, 0] := +1 * ((Sqrt(self.fcfg[0, 1, 0]) + 1) + (Sqrt(self.fcfg[0, 1, 0]) - 1) * Cos(self.fcfg[0, 1, 1]) + 2 * Sqrt(Sqrt(self.fcfg[0, 1, 0])) * (self.fcfg[0, 1, 2] * Sin(self.fcfg[0, 1, 1]) / 2));
        self.fcfg[1, 1, 1] := -2 * ((Sqrt(self.fcfg[0, 1, 0]) - 1) + (Sqrt(self.fcfg[0, 1, 0]) + 1) * Cos(self.fcfg[0, 1, 1]));
        self.fcfg[1, 1, 2] := +1 * ((Sqrt(self.fcfg[0, 1, 0]) + 1) + (Sqrt(self.fcfg[0, 1, 0]) - 1) * Cos(self.fcfg[0, 1, 1]) - 2 * Sqrt(Sqrt(self.fcfg[0, 1, 0])) * (self.fcfg[0, 1, 2] * Sin(self.fcfg[0, 1, 1]) / 2));
      end;
      ftTreble: begin
        self.fcfg[1, 0, 0] := +1 * Sqrt(self.fcfg[0, 1, 0]) * ((Sqrt(self.fcfg[0, 1, 0]) + 1) + (Sqrt(self.fcfg[0, 1, 0]) - 1) * Cos(self.fcfg[0, 1, 1]) + 2 * Sqrt(Sqrt(self.fcfg[0, 1, 0])) * (self.fcfg[0, 1, 2] * Sin(self.fcfg[0, 1, 1]) / 2));
        self.fcfg[1, 0, 1] := -2 * Sqrt(self.fcfg[0, 1, 0]) * ((Sqrt(self.fcfg[0, 1, 0]) - 1) + (Sqrt(self.fcfg[0, 1, 0]) + 1) * Cos(self.fcfg[0, 1, 1]));
        self.fcfg[1, 0, 2] := +1 * Sqrt(self.fcfg[0, 1, 0]) * ((Sqrt(self.fcfg[0, 1, 0]) + 1) + (Sqrt(self.fcfg[0, 1, 0]) - 1) * Cos(self.fcfg[0, 1, 1]) - 2 * Sqrt(Sqrt(self.fcfg[0, 1, 0])) * (self.fcfg[0, 1, 2] * Sin(self.fcfg[0, 1, 1]) / 2));
        self.fcfg[1, 1, 0] := +1 * ((Sqrt(self.fcfg[0, 1, 0]) + 1) - (Sqrt(self.fcfg[0, 1, 0]) - 1) * Cos(self.fcfg[0, 1, 1]) + 2 * Sqrt(Sqrt(self.fcfg[0, 1, 0])) * (self.fcfg[0, 1, 2] * Sin(self.fcfg[0, 1, 1]) / 2));
        self.fcfg[1, 1, 1] := +2 * ((Sqrt(self.fcfg[0, 1, 0]) - 1) - (Sqrt(self.fcfg[0, 1, 0]) + 1) * Cos(self.fcfg[0, 1, 1]));
        self.fcfg[1, 1, 2] := +1 * ((Sqrt(self.fcfg[0, 1, 0]) + 1) - (Sqrt(self.fcfg[0, 1, 0]) - 1) * Cos(self.fcfg[0, 1, 1]) - 2 * Sqrt(Sqrt(self.fcfg[0, 1, 0])) * (self.fcfg[0, 1, 2] * Sin(self.fcfg[0, 1, 1]) / 2));
      end;
      else begin
        self.fcfg[1, 0, 0] := 0;
        self.fcfg[1, 0, 1] := 0;
        self.fcfg[1, 0, 2] := 0;
        self.fcfg[1, 1, 0] := 0;
        self.fcfg[1, 1, 1] := 0;
        self.fcfg[1, 1, 2] := 0;
      end;
    end;
  except
    self.fcfg[1, 0, 0] := 0;
    self.fcfg[1, 0, 1] := 0;
    self.fcfg[1, 0, 2] := 0;
    self.fcfg[1, 1, 0] := 0;
    self.fcfg[1, 1, 1] := 0;
    self.fcfg[1, 1, 2] := 0;
  end;
end;

function TBQFilter.Process(const input: Double): Double;
begin
  try
    case(self.fenabled) of
      True: begin
        self.fcfg[2, 0, 2] := self.fcfg[2, 0, 1];
        self.fcfg[2, 0, 1] := self.fcfg[2, 0, 0];
        self.fcfg[2, 0, 0] := input;
        self.fcfg[2, 1, 2] := self.fcfg[2, 1, 1];
        self.fcfg[2, 1, 1] := self.fcfg[2, 1, 0];
        self.fcfg[2, 1, 0] := (((self.fcfg[1, 0, 0] * self.fcfg[2, 0, 0] + self.fcfg[1, 0, 1] * self.fcfg[2, 0, 1] + self.fcfg[1, 0, 2] * self.fcfg[2, 0, 2]) - (self.fcfg[1, 1, 1] * self.fcfg[2, 1, 1] + self.fcfg[1, 1, 2] * self.fcfg[2, 1, 2])) / self.fcfg[1, 1, 0]);
      end;
      False: begin
        self.fcfg[2, 0, 2] := self.fcfg[2, 0, 1];
        self.fcfg[2, 0, 1] := self.fcfg[2, 0, 0];
        self.fcfg[2, 0, 0] := input;
        self.fcfg[2, 1, 2] := self.fcfg[2, 1, 1];
        self.fcfg[2, 1, 1] := self.fcfg[2, 1, 0];
        self.fcfg[2, 1, 0] := input;
      end;
      else begin
        self.fcfg[2, 0, 2] := self.fcfg[2, 0, 1];
        self.fcfg[2, 0, 1] := self.fcfg[2, 0, 0];
        self.fcfg[2, 0, 0] := input;
        self.fcfg[2, 1, 2] := self.fcfg[2, 1, 1];
        self.fcfg[2, 1, 1] := self.fcfg[2, 1, 0];
        self.fcfg[2, 1, 0] := 0;
      end;
    end;
  except
    self.fcfg[2, 0, 2] := self.fcfg[2, 0, 1];
    self.fcfg[2, 0, 1] := self.fcfg[2, 0, 0];
    self.fcfg[2, 0, 0] := input;
    self.fcfg[2, 1, 2] := self.fcfg[2, 1, 1];
    self.fcfg[2, 1, 1] := self.fcfg[2, 1, 0];
    self.fcfg[2, 1, 0] := 0;
  end;

  Result := self.fcfg[2, 1, 0];
end;

function TBQFilter.getBand(): TBand;
begin
  Result := self.fband;
end;

procedure TBQFilter.setBand(const Value: TBand);
begin
  if((not(self.fband = Value))) then begin
    self.fband := Value;
    self.Configure();
    self.Calculate();
  end;
end;

function TBQFilter.getFilter(): TFilter;
begin
  Result := self.ffilter;
end;

procedure TBQFilter.setFilter(const Value: TFilter);
begin
  if((not(self.ffilter = Value))) then begin
    self.ffilter := Value;
    self.Configure();
    self.Calculate();
  end;
end;

function TBQFilter.getEnabled(): Boolean;
begin
  Result := self.fenabled;
end;

procedure TBQFilter.setEnabled(const Value: Boolean);
begin
  if((not(self.fenabled = Value))) then begin
    self.fenabled := Value;
    self.Configure();
    self.Calculate();
  end;
end;

function TBQFilter.getGain(): Double;
begin
  Result := self.fcfg[0, 1, 0];
end;

procedure TBQFilter.setGain(const Value: Double);
begin
  if((not(self.fcfg[0, 1, 0] = Value))) then begin
    self.fcfg[0, 1, 0] := Value;
    self.Configure();
    self.Calculate();
  end;
end;

function TBQFilter.getWidth(): Double;
begin
  Result := self.fcfg[0, 0, 0];
end;

procedure TBQFilter.setWidth(const Value: Double);
begin
  if((not(self.fcfg[0, 0, 0] = Value))) then begin
    self.fcfg[0, 0, 0] := Value;
    self.Configure();
    self.Calculate();
  end;
end;

function TBQFilter.getFreq(): Double;
begin
  Result := self.fcfg[0, 0, 1];
end;

procedure TBQFilter.setFreq(const Value: Double);
begin
  if((not(self.fcfg[0, 0, 1] = Value))) then begin
    self.fcfg[0, 0, 1] := Value;
    self.Configure();
    self.Calculate();
  end;
end;

function TBQFilter.getRate(): Double;
begin
  Result := self.fcfg[0, 0, 2];
end;

procedure TBQFilter.setRate(const Value: Double);
begin
  if((not(self.fcfg[0, 0, 2] = Value))) then begin
    self.fcfg[0, 0, 2] := Value;
    self.Configure();
    self.Calculate();
  end;
end;

begin
end.
