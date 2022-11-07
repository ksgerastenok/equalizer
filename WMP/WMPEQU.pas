unit
  WMPEQU;

interface

uses
  WMPBQF,
  WMPDSP,
  WMPDCL;

type
  PWMPEQU = ^TWMPEQU;
  TWMPEQU = record
  private
    var fdata: TData;
    var finfo: TInfo;
    var fdsp: TWMPDSP;
    var feqz: array[0..4, 0..20] of TWMPBQF;
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

procedure TWMPEQU.Init();
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

procedure TWMPEQU.Done();
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

function TWMPEQU.getInfo(): PInfo;
begin
  Result := Addr(self.finfo);
end;

function TWMPEQU.getData(): PData;
begin
  Result := Addr(self.fdata);
end;

procedure TWMPEQU.Process();
var
  k: Integer;
  i: Integer;
  x: Integer;
begin
  if (self.finfo.Enabled) then begin
    for k := 0 to self.fdata.Channels - 1 do begin
      for i := 0 to Length(self.finfo.Bands) - 1 do begin
        self.feqz[k, i].Amp := (self.finfo.Preamp + self.finfo.Bands[i]) / 10;
        self.feqz[k, i].Freq := 20 * Power(2, 0.5 * i);
        self.feqz[k, i].Rate := self.fdata.Rates;
        self.feqz[k, i].Width := 0.5;
        for x := 0 to self.fdata.Samples - 1 do begin
          self.fdsp.Samples[x, k] := self.feqz[k, i].Process(self.fdsp.Samples[x, k]);
        end;
      end;
    end;
  end;
end;

begin
end.
