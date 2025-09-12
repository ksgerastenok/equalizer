unit
  WMPNRM;

interface

uses
  WMPDCL,
  WMPDSP,
  WMPRNG,
  WMPFRM;

type
  PWMPNRM = ^TWMPNRM;
  TWMPNRM = record
  private
    class var fenabled: Boolean;
    class var frng: TWMPRNG;
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
begin
  TWMPNRM.ffrm.Init();
  TWMPNRM.frng.Init(500);
  TWMPNRM.fenabled := True;
  Result := 0;
end;

class procedure TWMPNRM.Quit(const Module: PPlugin); cdecl;
begin
  TWMPNRM.fenabled := False;
  TWMPNRM.frng.Done();
  TWMPNRM.ffrm.Done();
end;

class function TWMPNRM.Modify(const Module: PPlugin; const Data: Pointer; const Samples: LongWord; const Bits: LongWord; const Channels: LongWord; const Rates: LongWord): Integer; cdecl;
var
  k: LongWord;
  x: LongWord;
  s: Double;
  f: Double;
begin
  if (TWMPNRM.fenabled) then begin
    TWMPNRM.fdsp.Init(Data, Bits, Rates, Samples, Channels);
    f := 10.0;
    for k := 0 to Channels - 1 do begin
      s := 1.0;
      for x := 0 to Samples - 1 do begin
        s := s / Sqrt(Max(1.0 + (Sqr(1.75 * s * TWMPNRM.fdsp.Buffer[x, k]) - 1.0) / (x + 1), 0.01));
      end;
      f := Min(f, s);
    end;
    f := TWMPNRM.frng.getSample(f);
    for k := 0 to Channels - 1 do begin
      for x := 0 to Samples - 1 do begin
        TWMPNRM.fdsp.Buffer[x, k] := TWMPNRM.fdsp.Buffer[x, k] * f;
      end;
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
