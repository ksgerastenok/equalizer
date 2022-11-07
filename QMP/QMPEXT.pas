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
    var fdata: TData;
    var finfo: TInfo;
    var fdsp: TQMPDSP;
    var fwidth: Double;
    function getInfo(): PInfo;
    function getData(): PData;
  public
    procedure Init(const Width: Double);
    procedure Done();
    procedure Process();
    property Info: PInfo read getInfo;
    property Data: PData read getData;
  end;

implementation

uses
  Math;

procedure TQMPEXT.Init(const Width: Double);
begin
  self.fwidth := Power(10, Width / 20);
  self.fdsp.Init(self.Data);
end;

procedure TQMPEXT.Done();
begin
  self.fwidth := 0;
  self.fdsp.Done();
end;

function TQMPEXT.getInfo(): PInfo;
begin
  Result := Addr(self.finfo);
end;

function TQMPEXT.getData(): PData;
begin
  Result := Addr(self.fdata);
end;

procedure TQMPEXT.Process();
var
  k: Integer;
  x: Integer;
  f: Double;
begin
  if (self.finfo.Enabled) then begin
    for x := 0 to self.fdata.Samples - 1 do begin
      f := 0;
      for k := 0 to self.fdata.Channels - 1 do begin
        f := f + (self.fdsp.Samples[x, k] - f) / (k + 1);
      end;
      for k := 0 to self.fdata.Channels - 1 do begin
        self.fdsp.Samples[x, k] := f + self.fwidth * (self.fdsp.Samples[x, k] - f);
      end;
    end;
  end;
end;

begin
end.
