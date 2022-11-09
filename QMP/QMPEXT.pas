unit
  QMPEXT;

interface

uses
  QMPDSP,
  QMPDCL;

type
  PQMPEXT = ^TQMPEXT;
  TQMPEXT = record
  private
    var fenabled: Boolean;
    var fwidth: Double;
  public
    procedure Init(const Width: Double);
    procedure Done();
    procedure Update(const Info: PInfo);
    procedure Process(const Data: PData);
  end;

implementation

uses
  Math;

procedure TQMPEXT.Init(const Width: Double);
begin
  self.fwidth := Power(10, Width / 20);
end;

procedure TQMPEXT.Done();
begin
  self.fwidth := 0;
end;

procedure TQMPEXT.Update(const Info: PInfo);
begin
  self.fenabled := Info.Enabled;
end;

procedure TQMPEXT.Process(const Data: PData);
var
  k: Integer;
  x: Integer;
  f: Double;
  dsp: TQMPDSP;
begin
  dsp.Init(Data);
  if (self.fenabled) then begin
    for x := 0 to Data.Samples - 1 do begin
      f := 0;
      for k := 0 to Data.Channels - 1 do begin
        f := f + (dsp.Samples[x, k] - f) / (k + 1);
      end;
      for k := 0 to Data.Channels - 1 do begin
        dsp.Samples[x, k] := f + self.fwidth * (dsp.Samples[x, k] - f);
      end;
    end;
  end;
  dsp.Done();
end;

begin
end.
