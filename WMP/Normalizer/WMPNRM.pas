unit
  WMPNRM;

interface

uses
  WMPDCL,
  WMPDSP,
  WMPFRM;

type
  PWMPNRM = ^TWMPNRM;
  TWMPNRM = record
  private
    class var fenabled: Boolean;
    class var famp: array[0..4] of Double;
    class var fdsp: TWMPDSP;
    class var ffrm: TWMPFRM;
    class function Init(const Module: PPlugin): Integer; cdecl; static;
    class procedure Quit(const Module: PPlugin); cdecl; static;
    class function Modify(const Module: PPlugin; const Data: Pointer; const Samples: LongWord; const Bits: LongWord; const Channels: LongWord; const Rates: LongWord): Integer; cdecl; static;
    class procedure Config(const Module: PPlugin); cdecl; static;
  public
    class function Plugin(): PPlugin; cdecl; static;
  end;

implementation

uses
  Math;

class function TWMPNRM.Plugin(): PPlugin; cdecl;
begin
  Result := New(PPlugin);
  Result.Description := 'Nullsoft Normalizer v3.51';
  Result.Instance := $0000;
  Result.Init := TWMPNRM.Init;
  Result.Quit := TWMPNRM.Quit;
  Result.Modify := TWMPNRM.Modify;
  Result.Config := TWMPNRM.Config;
end;

class function TWMPNRM.Init(const Module: PPlugin): Integer; cdecl;
var
  k: Integer;
begin
  TWMPNRM.ffrm.Init();
  TWMPNRM.fenabled := True;
  for k := 0 to Length(TWMPNRM.famp) - 1 do begin
    TWMPNRM.famp[k] := 1.0;
  end;
  Result := 0;
end;

class procedure TWMPNRM.Quit(const Module: PPlugin); cdecl;
var
  k: Integer;
begin
  for k := 0 to Length(TWMPNRM.famp) - 1 do begin
    TWMPNRM.famp[k] := 1.0;
  end;
  TWMPNRM.fenabled := False;
  TWMPNRM.ffrm.Done();
end;

class function TWMPNRM.Modify(const Module: PPlugin; const Data: Pointer; const Samples: LongWord; const Bits: LongWord; const Channels: LongWord; const Rates: LongWord): Integer; cdecl;
var
  k: LongWord;
  x: LongWord;
  f: Double;
  a: Double;
  b: Double;
begin
  if (TWMPNRM.fenabled) then begin
    TWMPNRM.fdsp.Init(Data, Bits, Rates, Samples, Channels);
    for k := 0 to Channels - 1 do begin
      f := 1.0;
      for x := 0 to Samples - 1 do begin
        f := f / Sqrt(1.0 + ((4.5 * Sqr(f * TWMPNRM.fdsp.Buffer[x, k]) - 1.0) / (x + 1)));
      end;
      b := Min(Max(1.0, f), 10.0);
      a := Min(Max(1.0, TWMPNRM.famp[k]), 10.0);
      for x := 0 to Samples - 1 do begin
        TWMPNRM.famp[k] := (b - a) * Min(Max(0.0, x / (IfThen(b <= a, 0.50, 25.0) * Rates)), 1.0) + a;
        TWMPNRM.fdsp.Buffer[x, k] := TWMPNRM.famp[k] * TWMPNRM.fdsp.Buffer[x, k];
      end;
    end;
    f := 0;
    for k := 0 to Channels - 1 do begin
      f := f + (TWMPNRM.famp[k] - f) / (k + 1);
    end;
    TWMPNRM.ffrm.Amp := f;
    TWMPNRM.fdsp.Done();
  end;
  Result := Samples;
end;

class procedure TWMPNRM.Config(const Module: PPlugin); cdecl;
begin
  TWMPNRM.ffrm.Show();
end;

begin
end.
