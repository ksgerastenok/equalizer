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
    class var frng: TQMPRNG;
    class var fdsp: TQMPDSP;
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

class function TQMPNRM.Plugin(): PPlugin; cdecl;
begin
  Result := New(PPlugin);
  Result.Description := 'Quinnware Normalizer v3.51';
  Result.Version := $0000;
  Result.Init := TQMPNRM.Init;
  Result.Quit := TQMPNRM.Quit;
  Result.Modify := TQMPNRM.Modify;
  Result.Update := TQMPNRM.Update;
end;

class function TQMPNRM.Init(const Flags: Integer): Integer; cdecl;
begin
  TQMPNRM.frng.Init(500);
  Result := 1;
end;

class procedure TQMPNRM.Quit(const Flags: Integer); cdecl;
begin
  TQMPNRM.frng.Done();
end;

class function TQMPNRM.Modify(const Data: PData; const Latency: PInteger; const Flags: Integer): Integer; cdecl;
var
  k: LongWord;
  x: LongWord;
  f: Double;
  s: Double;
begin
  if (TQMPNRM.finfo.Enabled) then begin
    TQMPNRM.fdsp.Init(Data);
    f := 10.0;
    for k := 0 to Data.Channels - 1 do begin
      s := 1.0;
      for x := 0 to Data.Samples - 1 do begin
        s := s / Sqrt(Max(1.0 + (Sqr(1.75 * s * TQMPNRM.fdsp.Buffer[x, k]) - 1.0) / (x + 1), 0.01));
      end;
      f := Min(f, s);
    end;
    f := TQMPNRM.frng.getSample(f);
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
