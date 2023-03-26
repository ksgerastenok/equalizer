unit
  QMPNRM;

interface

uses
  QMPDSP,
  QMPDCL;

type
  PQMPNRM = ^TQMPNRM;
  TQMPNRM = record
  private
    class var fenabled: Boolean;
    class var famp: array[0..4] of Double;
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
var
  k: Integer;
begin
  TQMPNRM.fdsp.Init();
  for k := 0 to Length(TQMPNRM.famp) - 1 do begin
    TQMPNRM.famp[k] := 1.0;
  end;
  Result := 1;
end;

class procedure TQMPNRM.Quit(const Flags: Integer); cdecl;
var
  k: Integer;
begin
  for k := 0 to Length(TQMPNRM.famp) - 1 do begin
    TQMPNRM.famp[k] := 1.0;
  end;
  TQMPNRM.fdsp.Done();
end;

class function TQMPNRM.Modify(const Data: PData; const Latency: PInteger; const Flags: Integer): Integer; cdecl;
var
  k: LongWord;
  x: LongWord;
  f: Double;
  a: Double;
  b: Double;
begin
  TQMPNRM.fdsp.Data := Data.Data;
  TQMPNRM.fdsp.Bits := Data.Bits;
  TQMPNRM.fdsp.Rates := Data.Rates;
  TQMPNRM.fdsp.Samples := Data.Samples;
  TQMPNRM.fdsp.Channels := Data.Channels;
  if (TQMPNRM.fenabled) then begin
    for k := 0 to TQMPNRM.fdsp.Channels - 1 do begin
      f := 1.0;
      for x := 0 to TQMPNRM.fdsp.Samples - 1 do begin
        f := f / Sqrt(1.0 + ((4.5 * Sqr(f * TQMPNRM.fdsp.Buffer[x, k]) - 1.0) / (x + 1)));
      end;
      b := Min(Max(1.0, f), 10.0);
      a := Min(Max(1.0, TQMPNRM.famp[k]), 10.0);
      for x := 0 to TQMPNRM.fdsp.Samples - 1 do begin
        TQMPNRM.famp[k] := (b - a) * Min(Max(0.0, x / (IfThen(b <= a, 0.50, 25.0) * TQMPNRM.fdsp.Rates)), 1.0) + a;
        TQMPNRM.fdsp.Buffer[x, k] := TQMPNRM.famp[k] * TQMPNRM.fdsp.Buffer[x, k];
      end;
    end;
  end;
  Result := 1;
end;

class function TQMPNRM.Update(const Info: PInfo; const Flags: Integer): Integer; cdecl;
begin
  TQMPNRM.fenabled := Info.Enabled;
  Result := 1;
end;

begin
end.
