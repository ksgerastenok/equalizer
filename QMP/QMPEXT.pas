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
    var fdsp: TQMPDSP;
  public
    procedure Init(const Width: Double);
    procedure Done();
    procedure Update(const Info: TInfo);
    procedure Process(const Data: TData);
  end;

implementation

uses
  Math;

procedure TQMPEXT.Init(const Width: Double);
begin
  self.fdsp.Init();
  self.fwidth := Power(10, Width / 20);
end;

procedure TQMPEXT.Done();
begin
  self.fwidth := 0.0;
  self.fdsp.Done();
end;

procedure TQMPEXT.Update(const Info: TInfo);
begin
  self.fenabled := Info.Enabled;
end;

procedure TQMPEXT.Process(const Data: TData);
var
  k: LongWord;
  x: LongWord;
  f: Double;
begin
  self.fdsp.Data := Data;
  if (self.fenabled) then begin
    for x := 0 to self.fdsp.Data.Samples - 1 do begin
      f := 0;
      for k := 0 to self.fdsp.Data.Channels - 1 do begin
        f := f + (self.fdsp.Samples[x, k] - f) / (k + 1);
      end;
      for k := 0 to self.fdsp.Data.Channels - 1 do begin
        self.fdsp.Samples[x, k] := f + self.fwidth * (self.fdsp.Samples[x, k] - f);
      end;
    end;
  end;
end;

begin
end.
