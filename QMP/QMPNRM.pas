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
      b := 1.0 / Sqrt(5.0 * f);
      if (b <= self.famp[k]) then begin
        for x := 0 to self.fdsp.Data.Samples - 1 do begin
          y := Min(Max(1.0, b * ((x / self.fdsp.Data.Rates) * (self.famp[k] - (1.0 + 0.01) * b) + 0.01 * self.famp[k] * 0.3) / ((x / self.fdsp.Data.Rates) * (self.famp[k] - (1.0 + 0.01) * b) + 0.01 * b * 0.3)), 10.0);
          self.fdsp.Samples[x, k] := y * self.fdsp.Samples[x, k];
        end;
      end                    else begin
        for x := 0 to self.fdsp.Data.Samples - 1 do begin
          y := Min(Max(1.0, b * ((x / self.fdsp.Data.Rates) * (self.famp[k] - (1.0 - 0.01) * b) - 0.01 * self.famp[k] * 9.0) / ((x / self.fdsp.Data.Rates) * (self.famp[k] - (1.0 - 0.01) * b) - 0.01 * b * 9.0)), 10.0);
          self.fdsp.Samples[x, k] := y * self.fdsp.Samples[x, k];
        end;
      end;
      self.famp[k] := y;
    end;
  end;
end;

begin
end.
