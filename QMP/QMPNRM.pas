unit
  QMPNRM;

interface

uses
  QMPRNG,
  QMPDSP,
  QMPDCL;

type
  PQMPNRM = ^TQMPNRM;
  TQMPNRM = record
  private
    class var finfo: TInfo;
    class var fdsp: TQMPDSP;
    class var frng: array[0..4] of TQMPRNG;
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

class function TQMPNRM.Plugin(): PPlugin; cdecl;
begin
  Result := New(PPlugin);
  Result.Description := 'Quinnware Normalizer v3.51';
  Result.Version := $0000;
  Result.Init := TQMPNRM.Init;
  Result.Quit := TQMPNRM.Quit;
  Result.Open := TQMPNRM.Open;
  Result.Stop := TQMPNRM.Stop;
  Result.Modify := TQMPNRM.Modify;
  Result.Update := TQMPNRM.Update;
end;

class function TQMPNRM.Init(const Flags: Integer): Integer; cdecl;
var
  k: Integer;
begin
  for k := 0 to Length(TQMPNRM.frng) - 1 do begin
    TQMPNRM.frng[k].Init();
  end;
  Result := 1;
end;

class procedure TQMPNRM.Quit(const Flags: Integer); cdecl;
var
  k: Integer;
begin
  for k := 0 to Length(TQMPNRM.frng) - 1 do begin
    TQMPNRM.frng[k].Done();
  end;
end;

class function TQMPNRM.Open(const Media: PChar; const Format: Pointer; const Flags: Integer): Integer; cdecl;
var
  k: Integer;
begin
  for k := 0 to Length(TQMPNRM.frng) - 1 do begin
    TQMPNRM.frng[k].Init();
  end;
  Result := 1;
end;

class procedure TQMPNRM.Stop(const Flags: Integer); cdecl;
var
  k: Integer;
begin
  for k := 0 to Length(TQMPNRM.frng) - 1 do begin
    TQMPNRM.frng[k].Done();
  end;
end;

class function TQMPNRM.Modify(const Data: PData; const Latency: PInteger; const Flags: Integer): Integer; cdecl;
var
  k: LongWord;
  x: LongWord;
  f: Double;
begin
  if (TQMPNRM.finfo.Enabled) then begin
    TQMPNRM.fdsp.Init(Data);
    f := 0.0;
    for k := 0 to Min(Length(TQMPNRM.frng), Data.Channels) - 1 do begin
      for x := 0 to Data.Samples - 1 do begin
        TQMPNRM.frng[k].addSample(TQMPNRM.fdsp.Buffer[x, k]);
      end;
      f := Max(f, TQMPNRM.frng[k].getAvg());
    end;
    f := Min(Max(1.0 / f, 1.0), 10.0);
    for k := 0 to Data.Channels - 1 do begin
      for x := 0 to Data.Samples - 1 do begin
        TQMPNRM.fdsp.Buffer[x, k] := TQMPNRM.fdsp.Buffer[x, k] * f;
      end;
    end;
    TQMPNRM.fdsp.Done();
  end;
  Result := 1;
end;

class function TQMPNRM.Update(const Info: PInfo; const Flags: Integer): Integer; cdecl;
begin
  TQMPNRM.finfo.Enabled := Info.Enabled;
  TQMPNRM.finfo.Preamp := Info.Preamp;
  TQMPNRM.finfo.Bands := Info.Bands;
  Result := 1;
end;

begin
end.
