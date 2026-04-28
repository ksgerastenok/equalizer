unit
  QMPENH;

interface

uses
  QMPBQF,
  QMPRNG,
  QMPDSP,
  QMPDCL;

type
  TQMPENH = record
  private
    class var finfo: TInfo;
    class var fdsp: TQMPDSP;
    class var fenh: array[0..4] of array[0..2] of TQMPBQF;
    class var frng: array[0..4] of TQMPRNG;
    class function Init(const Flags: Integer): Integer; cdecl; static;
    class procedure Quit(const Flags: Integer); cdecl; static;
    class function Modify(const Data: PData; const Latency: PInteger; const Flags: Integer): Integer; cdecl; static;
    class function Update(const Info: PInfo; const Flags: Integer): Integer; cdecl; static;
  public
    class function Plugin(): PPlugin; cdecl; static;
  end;

implementation

uses
  Math;

class function TQMPENH.Plugin(): PPlugin; cdecl;
begin
  Result := New(PPlugin);
  Result.Description := 'Quinnware Enhancer v3.51';
  Result.Init := TQMPENH.Init;
  Result.Quit := TQMPENH.Quit;
  Result.Modify := TQMPENH.Modify;
  Result.Update := TQMPENH.Update;
end;

class function TQMPENH.Init(const Flags: Integer): Integer; cdecl;
var
  k: LongWord;
begin
  for k := 0 to Length(TQMPENH.fenh) - 1 do begin
    TQMPENH.fenh[k][0].Init(ttSVF, ftBass, btSlope, gtDb);
    TQMPENH.fenh[k][1].Init(ttSVF, ftBass, btSlope, gtDb);
    TQMPENH.fenh[k][2].Init(ttSVF, ftTreble, btSlope, gtDb);
  end;
  for k := 0 to Length(TQMPENH.frng) - 1 do begin
    TQMPENH.frng[k].Init(ttSVF, ftBand, btOctave, gtDb);
  end;
  Result := 1;
end;

class procedure TQMPENH.Quit(const Flags: Integer); cdecl;
var
  k: LongWord;
begin
  for k := 0 to Length(TQMPENH.fenh) - 1 do begin
    TQMPENH.fenh[k][0].Done();
    TQMPENH.fenh[k][1].Done();
    TQMPENH.fenh[k][2].Done();
  end;
  for k := 0 to Length(TQMPENH.frng) - 1 do begin
    TQMPENH.frng[k].Done();
  end;
end;

class function TQMPENH.Modify(const Data: PData; const Latency: PInteger; const Flags: Integer): Integer; cdecl;
var
  k: LongWord;
  i: LongWord;
  x: LongWord;
  v: Double;
begin
  if (TQMPENH.finfo.Enabled) then begin
    TQMPENH.fdsp.Init(Data);
    for k := 0 to Data.Channels - 1 do begin
      TQMPENH.fenh[k][0].Amp := 3.5;
      TQMPENH.fenh[k][0].Freq := 100.0;
      TQMPENH.fenh[k][0].Width := 2.5;
      TQMPENH.fenh[k][0].Rate := Data.Rates;
      TQMPENH.fenh[k][1].Amp := 3.5;
      TQMPENH.fenh[k][1].Freq := 250.0;
      TQMPENH.fenh[k][1].Width := 2.5;
      TQMPENH.fenh[k][1].Rate := Data.Rates;
      TQMPENH.fenh[k][2].Amp := 9.0;
      TQMPENH.fenh[k][2].Freq := 3000.0;
      TQMPENH.fenh[k][2].Width := 2.5;
      TQMPENH.fenh[k][2].Rate := Data.Rates;
      TQMPENH.frng[k].Amp := 20.0;
      TQMPENH.frng[k].Freq := 320.0;
      TQMPENH.frng[k].Width := 8.0;
      TQMPENH.frng[k].Rate := Data.Rates;
      for x := 0 to Data.Samples - 1 do begin
        v := TQMPENH.fdsp.Data[k, x];
        for i := 0 to Length(TQMPENH.fenh[k]) - 1 do begin
          v := TQMPENH.fenh[k, i].Process(v);
        end;
        v := TQMPENH.frng[k].Process(v);
        TQMPENH.fdsp.Data[k, x] := v;
      end;
    end;
    TQMPENH.fdsp.Done();
  end;
  Result := 1;
end;

class function TQMPENH.Update(const Info: PInfo; const Flags: Integer): Integer; cdecl;
begin
  TQMPENH.finfo := Info^;
  Result := 1;
end;

begin
end.
