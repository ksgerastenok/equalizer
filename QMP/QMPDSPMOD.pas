unit
  QMPDSPMOD;

interface

uses
  QMPDSPBQF,
  QMPDSPPLG,
  QMPDSPDCL;

type
  TQMPDSPMOD = class(TQMPDSPPLG)
  private
    class var fmod: TQMPDSPMOD;
    var feqz: array[0..4, 0..9] of TQMPDSPBQF;
    var finfo: PInfo;
    function getInfo(): PInfo;
    constructor Create();
  public
    class function Instance(): TQMPDSPMOD;
    class procedure Quit();
    destructor Destroy(); override;
    procedure Process(); override;
    property Info: PInfo read getInfo;
  end;

implementation

uses
  Math;

class function TQMPDSPMOD.Instance(): TQMPDSPMOD;
begin
  if((not(Assigned(self.fmod)))) then begin
    self.fmod := self.Create();
  end;
  Result := self.fmod;
end;

class procedure TQMPDSPMOD.Quit();
begin
  if((Assigned(self.fmod))) then begin
    self.fmod.Destroy();
  end;
  self.fmod := nil;
end;

constructor TQMPDSPMOD.Create();
var
  k: LongWord;
  i: LongWord;
begin
  inherited Create();
  self.finfo := New(PInfo);
  for k := 0 to Length(self.feqz) - 1 do begin
    for i := 0 to Length(self.feqz[k]) - 1 do begin
      self.feqz[k, i] := TQMPDSPBQF.Create(ftEqu, btOctave, gtDb);
    end;
  end;
end;

destructor TQMPDSPMOD.Destroy();
var
  k: LongWord;
  i: LongWord;
begin
  for k := 0 to Length(self.feqz) - 1 do begin
    for i := 0 to Length(self.feqz[k]) - 1 do begin
      self.feqz[k, i].Destroy();
    end;
  end;
  Dispose(self.finfo);
  inherited Destroy();
end;

function TQMPDSPMOD.getInfo(): PInfo;
begin
  Result := self.finfo;
end;

procedure TQMPDSPMOD.Process();
var
  k: LongWord;
  i: LongWord;
  x: LongWord;
begin
  if((self.Info.Enabled)) then begin
    for k := 0 to self.Data.Channels - 1 do begin
      for i := 0 to Length(self.Info.Bands) - 1 do begin
        self.feqz[k, i].Amp := (self.Info.Preamp + self.Info.Bands[i]) / 10;
        self.feqz[k, i].Freq := 35 * Power(2, 1.0 * i);
        self.feqz[k, i].Rate := self.Data.Rates;
        self.feqz[k, i].Width := 1.0;
        for x := 0 to self.Data.Samples - 1 do begin
          self.Samples[x, k] := self.feqz[k, i].Process(self.Samples[x, k]);
        end;
      end;
    end;
  end;
end;

begin
end.

