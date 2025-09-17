unit
  QMPTRB;

interface

uses
  QMPBQF,
  QMPDSP,
  QMPDCL;

type
  PQMPTRB = ^TQMPTRB;
  TQMPTRB = record
  private
    class var finfo: TInfo;
    class var fdsp: TQMPDSP;
    class var fbqf: array[0..4] of TQMPBQF;
    class function Init(const Flags: Integer): Integer; cdecl; static;
    class procedure Quit(const Flags: Integer); cdecl; static;
    class function Open(const Media: PChar; const Format: Pointer; const Flags: Integer): Integer; cdecl; static;
    class procedure Stop(const Flags: Integer); cdecl; static;
    class function Modify(const Data: PData; const Latency: PInteger; const Flags: Integer): Integer; cdecl; static;
    class function Update(const Info: PInfo; const Flags: Integer): Integer; cdecl; static;
  public
    class function Plugin(): PPlugin; cdecl; static;
  end;

implementation

uses
  Math;

class function TQMPTRB.Plugin(): PPlugin; cdecl;
begin
  Result := New(PPlugin);
  Result.Description := 'Quinnware Full Treble v3.51';
  Result.Version := $0000;
  Result.Init := TQMPTRB.Init;
  Result.Quit := TQMPTRB.Quit;
  Result.Open := TQMPTRB.Open;
  Result.Stop := TQMPTRB.Stop;
  Result.Modify := TQMPTRB.Modify;
  Result.Update := TQMPTRB.Update;
end;

class function TQMPTRB.Init(const Flags: Integer): Integer; cdecl;
var
  k: LongWord;
begin
  for k := 0 to Length(TQMPTRB.fbqf) - 1 do begin
    TQMPTRB.fbqf[k].Init(ftTreble, btOctave, gtDb);
    TQMPTRB.fbqf[k].Amp := 16.0;
    TQMPTRB.fbqf[k].Freq := 2500.0;
    TQMPTRB.fbqf[k].Width := 3.0;
  end;
  Result := 1;
end;

class procedure TQMPTRB.Quit(const Flags: Integer); cdecl;
var
  k: LongWord;
begin
  for k := 0 to Length(TQMPTRB.fbqf) - 1 do begin
    TQMPTRB.fbqf[k].Amp := 0.0;
    TQMPTRB.fbqf[k].Freq := 0.0;
    TQMPTRB.fbqf[k].Width := 0.0;
    TQMPTRB.fbqf[k].Done();
  end;
end;

class function TQMPTRB.Open(const Media: PChar; const Format: Pointer; const Flags: Integer): Integer; cdecl;
var
  k: LongWord;
begin
  for k := 0 to Length(TQMPTRB.fbqf) - 1 do begin
    TQMPTRB.fbqf[k].Init(ftTreble, btOctave, gtDb);
    TQMPTRB.fbqf[k].Amp := 16.0;
    TQMPTRB.fbqf[k].Freq := 2500.0;
    TQMPTRB.fbqf[k].Width := 3.0;
  end;
  Result := 1;
end;

class procedure TQMPTRB.Stop(const Flags: Integer); cdecl;
var
  k: LongWord;
begin
  for k := 0 to Length(TQMPTRB.fbqf) - 1 do begin
    TQMPTRB.fbqf[k].Amp := 0.0;
    TQMPTRB.fbqf[k].Freq := 0.0;
    TQMPTRB.fbqf[k].Width := 0.0;
    TQMPTRB.fbqf[k].Done();
  end;
end;

class function TQMPTRB.Modify(const Data: PData; const Latency: PInteger; const Flags: Integer): Integer; cdecl;
var
  k: LongWord;
  x: LongWord;
begin
  if (TQMPTRB.finfo.Enabled) then begin
    TQMPTRB.fdsp.Init(Data);
    for k := 0 to Min(Length(TQMPTRB.fbqf), Data.Channels) - 1 do begin
      TQMPTRB.fbqf[k].Rate := Data.Rates;
      for x := 0 to Data.Samples - 1 do begin
        TQMPTRB.fdsp.Buffer[x, k] := TQMPTRB.fbqf[k].Process(TQMPTRB.fdsp.Buffer[x, k]);
      end;
    end;
    TQMPTRB.fdsp.Done();
  end;
  Result := 1;
end;

class function TQMPTRB.Update(const Info: PInfo; const Flags: Integer): Integer; cdecl;
begin
  TQMPTRB.finfo.Enabled := Info.Enabled;
  TQMPTRB.finfo.Preamp := Info.Preamp;
  TQMPTRB.finfo.Bands := Info.Bands;
  Result := 1;
end;

begin
end.
