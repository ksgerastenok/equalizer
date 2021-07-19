unit
  QMPMOD;

interface

uses
  QMPBQF,
  QMPDSP,
  QMPDCL;

type
  TQMPMOD = class(TQMPDSP)
  private
    class var fmod: TQMPMOD;
    var feqz: array[0..4, 0..9] of TQMPBQF;
    var finfo: PInfo;
    function getInfo(): PInfo;
    constructor Create();
  public
    class function Instance(): TQMPMOD;
    class procedure Quit();
    destructor Destroy(); override;
    procedure Process(); override;
    property Info: PInfo read getInfo;
  end;

implementation

uses
  Math;

class function TQMPMOD.Instance(): TQMPMOD;
begin
  if((not(Assigned(self.fmod)))) then begin
    self.fmod := self.Create();
  end;
  Result := self.fmod;
end;

class procedure TQMPMOD.Quit();
begin
  if((Assigned(self.fmod))) then begin
    self.fmod.Destroy();
  end;
  self.fmod := nil;
end;

constructor TQMPMOD.Create();
var
  k: LongWord;
  i: LongWord;
begin
  inherited Create();
  self.finfo := New(PInfo);
  for k := 0 to Length(self.feqz) - 1 do begin
    for i := 0 to Length(self.feqz[k]) - 1 do begin
      self.feqz[k, i] := TQMPBQF.Create(ftEqu, btOctave, gtDb);
    end;
  end;
end;

destructor TQMPMOD.Destroy();
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

function TQMPMOD.getInfo(): PInfo;
begin
  Result := self.finfo;
end;

procedure TQMPMOD.Process();
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

