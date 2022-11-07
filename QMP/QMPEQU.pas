unit
  QMPEQU;

interface

uses
  QMPBQF,
  QMPDSP,
  QMPDCL;

type
  PQMPEQU = ^TQMPEQU;
  TQMPEQU = record
  private
    var fdata: TData;
    var finfo: TInfo;
    var fdsp: TQMPDSP;
    var feqz: array[0..4, 0..9] of TQMPBQF;
    function getInfo(): PInfo;
    function getData(): PData;
  public
    procedure Init();
    procedure Process();
    procedure Done();
    property Info: PInfo read getInfo;
    property Data: PData read getData;
  end;

implementation

uses
  Math;

procedure TQMPEQU.Init();
var
  k: Integer;
  i: Integer;
begin
  for k := 0 to Length(self.feqz) - 1 do begin
    for i := 0 to Length(self.feqz[k]) - 1 do begin
      self.feqz[k, i].Init(ftEqu, btOctave, gtDb);
    end;
  end;
  self.fdsp.Init(self.Data);
end;

procedure TQMPEQU.Done();
var
  k: Integer;
  i: Integer;
begin
  for k := 0 to Length(self.feqz) - 1 do begin
    for i := 0 to Length(self.feqz[k]) - 1 do begin
      self.feqz[k, i].Done();
    end;
  end;
  self.fdsp.Done();
end;

function TQMPEQU.getInfo(): PInfo;
begin
  Result := Addr(self.finfo);
end;

function TQMPEQU.getData(): PData;
begin
  Result := Addr(self.fdata);
end;

procedure TQMPEQU.Process();
var
  k: Integer;
  i: Integer;
  x: Integer;
begin
  if (self.finfo.Enabled) then begin
    for k := 0 to self.fdata.Channels - 1 do begin
      for i := 0 to Length(self.finfo.Bands) - 1 do begin
        self.feqz[k, i].Amp := (self.finfo.Preamp + self.finfo.Bands[i]) / 10;
        self.feqz[k, i].Freq := 35 * Power(2, 1.0 * i);
        self.feqz[k, i].Rate := self.fdata.Rates;
        self.feqz[k, i].Width := 1.0;
        for x := 0 to self.fdata.Samples - 1 do begin
          self.fdsp.Samples[x, k] := self.feqz[k, i].Process(self.fdsp.Samples[x, k]);
        end;
      end;
    end;
  end;
end;

begin
end.
