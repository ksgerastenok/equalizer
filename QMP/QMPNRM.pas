unit
  QMPNRM;

interface

uses
  QMPDSP,
  QMPDCL;

type
  PQMPNRM = ^TQMPNRM;
  TQMPNRM = record
  private
    var fenabled: Boolean;
    var famp: array[0..4] of Double;
    var fdsp: TQMPDSP;
  public
    procedure Init();
    procedure Done();
    procedure Update(const Info: TInfo);
    procedure Process(const Data: TData);
  end;

implementation

uses
  Math;

procedure TQMPNRM.Init();
var
  k: Integer;
begin
  self.fdsp.Init();
  for k := 0 to Length(self.famp) - 1 do begin
    self.famp[k] := 1.0;
  end;
end;

procedure TQMPNRM.Done();
var
  k: Integer;
begin
  for k := 0 to Length(self.famp) - 1 do begin
    self.famp[k] := 1.0;
  end;
  self.fdsp.Done();
end;

procedure TQMPNRM.Update(const Info: TInfo);
begin
  self.fenabled := Info.Enabled;
end;

procedure TQMPNRM.Process(const Data: TData);
var
  k: LongWord;
  x: LongWord;
  f: Double;
  a: Double;
  b: Double;
  y: Double;
begin
  self.fdsp.Data := Data;
  if (self.fenabled) then begin
    for k := 0 to self.fdsp.Data.Channels - 1 do begin
      f := 0;
      for x := 0 to self.fdsp.Data.Samples - 1 do begin
        f := f + (Sqr(self.fdsp.Samples[x, k]) - f) / (x + 1);
      end;
      b := Min(Max(1.0, 1.0 / Sqrt(5.0 * f)), 10.0);
      a := self.famp[k];
      for x := 0 to self.fdsp.Data.Samples - 1 do begin
        if (b <= a) then begin
          y := Max(Min(a, 5.0 * (b - a) * x / self.fdsp.Data.Rates + a), b);
          //y := (2 * (a - b) / Pi) * ArcTan2(Tan((0.01 * b * Pi) / (2 * (a - b))) * 0.2 * self.fdsp.Data.Rates, x) + b;
          //y := b * (x * (a - b * (1.0 + 0.01)) + 0.01 * a * 0.35 * self.fdsp.Data.Rates) / (x * (a - b * (1.0 + 0.01)) + 0.01 * b * 0.35 * self.fdsp.Data.Rates);
        end         else begin
          y := Min(Max(a, 0.2 * (b - a) * x / self.fdsp.Data.Rates + a), b);
          //y := (2 * (b - a) / Pi) * ArcTan2(x, Tan((0.01 * b * Pi) / (2 * (b - a))) * 5.0 * self.fdsp.Data.Rates) + a;
          //y := b * (x * (a - b * (1.0 - 0.01)) - 0.01 * a * 35.0 * self.fdsp.Data.Rates) / (x * (a - b * (1.0 - 0.01)) - 0.01 * b * 35.0 * self.fdsp.Data.Rates);
        end;
        self.fdsp.Samples[x, k] := y * self.fdsp.Samples[x, k];
      end;
      self.famp[k] := y;
    end;
  end;
end;

begin
end.
