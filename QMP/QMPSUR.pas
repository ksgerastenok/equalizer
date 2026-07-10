unit
  QMPSUR;

interface

uses
  QMPBQF,
  QMPRNG,
  QMPDSP,
  QMPDCL;

type
  TQMPSUR = record
  private
    class var finfo: TInfo;
    class var fdsp: TQMPDSP;
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

class function TQMPSUR.Plugin(): PPlugin; cdecl;
begin
  Result := New(PPlugin);
  Result.Description := 'Quinnware Surround v3.51';
  Result.Init := TQMPSUR.Init;
  Result.Quit := TQMPSUR.Quit;
  Result.Modify := TQMPSUR.Modify;
  Result.Update := TQMPSUR.Update;
end;

class function TQMPSUR.Init(const Flags: Integer): Integer; cdecl;
var
  k: LongWord;
begin
  for k := 0 to Length(TQMPSUR.frng) - 1 do begin
    TQMPSUR.frng[k].Init(ttSVF, ftBand, btOctave, gtDb);
  end;
  Result := 1;
end;

class procedure TQMPSUR.Quit(const Flags: Integer); cdecl;
var
  k: LongWord;
begin
  for k := 0 to Length(TQMPSUR.frng) - 1 do begin
    TQMPSUR.frng[k].Done();
  end;
end;

class function TQMPSUR.Modify(const Data: PData; const Latency: PInteger; const Flags: Integer): Integer; cdecl;
var
  k: LongWord;
  x: LongWord;
  v: Double;
  s: Double;
begin
  if (TQMPSUR.finfo.Enabled) then begin
    for k := 0 to Length(TQMPSUR.frng) - 1 do begin
      TQMPSUR.frng[k].Amp := 20.0;
      TQMPSUR.frng[k].Freq := 320.0;
      TQMPSUR.frng[k].Width := 8.0;
      TQMPSUR.frng[k].Rate := Data.Rates;
    end;
    TQMPSUR.fdsp.Init(Data);
    for x := 0 to Data.Samples - 1 do begin
      s := 0.0;
      for k := 0 to Data.Channels - 1 do begin
        s := s - (s - TQMPSUR.fdsp.Data[k, x]) / (k + 1);
      end;
      for k := 0 to Data.Channels - 1 do begin
        v := TQMPSUR.fdsp.Data[k, x];
        v := v + 0.75 * (v - s);
        v := TQMPSUR.frng[k].Process(v);
        TQMPSUR.fdsp.Data[k, x] := v;
      end;
    end;
    TQMPSUR.fdsp.Done();
  end;
  Result := 1;
end;

class function TQMPSUR.Update(const Info: PInfo; const Flags: Integer): Integer; cdecl;
begin
  TQMPSUR.finfo := Info^;
  Result := 1;
end;

begin
end.
