unit
  QMPBSS;

interface

uses
  QMPBQF,
  QMPDSP,
  QMPDCL;

type
  TQMPBSS = record
  private
    class var finfo: TInfo;
    class var fdsp: TQMPDSP;
    class var fbqf: array[0..4] of TQMPBQF;
    class function Init(const Flags: Integer): Integer; cdecl; static;
    class procedure Quit(const Flags: Integer); cdecl; static;
    class function Modify(const Data: PData; const Latency: PInteger; const Flags: Integer): Integer; cdecl; static;
    class function Update(const Info: PInfo; const Flags: Integer): Integer; cdecl; static;
  public
    class function Plugin(): PPlugin; cdecl; static;
  end;

implementation

class function TQMPBSS.Plugin(): PPlugin; cdecl;
begin
  Result := New(PPlugin);
  Result.Description := 'Quinnware True Bass v3.51';
  Result.Version := $0000;
  Result.Init := TQMPBSS.Init;
  Result.Quit := TQMPBSS.Quit;
  Result.Modify := TQMPBSS.Modify;
  Result.Update := TQMPBSS.Update;
end;

class function TQMPBSS.Init(const Flags: Integer): Integer; cdecl;
var
  k: LongWord;
begin
  for k := 0 to Length(TQMPBSS.fbqf) - 1 do begin
    TQMPBSS.fbqf[k].Init(ptZDF, ftBass, btSlope, gtDb);
    TQMPBSS.fbqf[k].Amp := 3.5;
    TQMPBSS.fbqf[k].Freq := 350.0;
    TQMPBSS.fbqf[k].Width := 0.5;
  end;
  Result := 1;
end;

class procedure TQMPBSS.Quit(const Flags: Integer); cdecl;
var
  k: LongWord;
begin
  for k := 0 to Length(TQMPBSS.fbqf) - 1 do begin
    TQMPBSS.fbqf[k].Amp := 0.0;
    TQMPBSS.fbqf[k].Freq := 0.0;
    TQMPBSS.fbqf[k].Width := 0.0;
    TQMPBSS.fbqf[k].Done();
  end;
end;

class function TQMPBSS.Modify(const Data: PData; const Latency: PInteger; const Flags: Integer): Integer; cdecl;
var
  k: LongWord;
  x: LongWord;
begin
  if (TQMPBSS.finfo.Enabled) then begin
    TQMPBSS.fdsp.Init(Data);
    for k := 0 to Data.Channels - 1 do begin
      TQMPBSS.fbqf[k].Rate := Data.Rates;
      for x := 0 to Data.Samples - 1 do begin
        TQMPBSS.fdsp.Data[k, x] := TQMPBSS.fbqf[k].Process(TQMPBSS.fdsp.Data[k, x]);
      end;
    end;
    TQMPBSS.fdsp.Done();
  end;
  Result := 1;
end;

class function TQMPBSS.Update(const Info: PInfo; const Flags: Integer): Integer; cdecl;
begin
  TQMPBSS.finfo.Enabled := Info.Enabled;
  TQMPBSS.finfo.Preamp := Info.Preamp;
  TQMPBSS.finfo.Bands := Info.Bands;
  Result := 1;
end;

begin
end.
