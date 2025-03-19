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
    class var finfo: TInfo;
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

end;

class function TQMPNRM.Modify(const Data: PData; const Latency: PInteger; const Flags: Integer): Integer; cdecl;
var
  k: LongWord;
  x: LongWord;
  f: Double;
  a: Double;
  b: Double;
begin
  if (TQMPNRM.finfo.Enabled) then begin
    TQMPNRM.fdsp.Init(Data);
    for k := 0 to Data.Channels - 1 do begin
      f := 1.0;
      for x := 0 to Data.Samples - 1 do begin
        f := f / Sqrt(1.0 + ((4.5 * Sqr(f * TQMPNRM.fdsp.Buffer[x, k]) - 1.0) / (x + 1)));
      end;
      b := Min(Max(1.0, f), 10.0);
      a := Min(Max(1.0, TQMPNRM.famp[k]), 10.0);
      for x := 0 to Data.Samples - 1 do begin
        TQMPNRM.famp[k] := (b - a) * Min(Max(0.0, x / (IfThen(b <= a, 0.50, 25.0) * Data.Rates)), 1.0) + a;
        TQMPNRM.fdsp.Buffer[x, k] := TQMPNRM.famp[k] * TQMPNRM.fdsp.Buffer[x, k];
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
