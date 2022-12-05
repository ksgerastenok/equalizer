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
  y: Double;
begin
  TQMPNRM.fdsp.Data.Data := Data.Data;
  TQMPNRM.fdsp.Data.Bits := Data.Bits;
  TQMPNRM.fdsp.Data.Rates := Data.Rates;
  TQMPNRM.fdsp.Data.Samples := Data.Samples;
  TQMPNRM.fdsp.Data.Channels := Data.Channels;
  if (TQMPNRM.fenabled) then begin
    for k := 0 to TQMPNRM.fdsp.Data.Channels - 1 do begin
      f := 0;
      for x := 0 to TQMPNRM.fdsp.Data.Samples - 1 do begin
        f := f + (Sqr(TQMPNRM.fdsp.Samples[x, k]) - f) / (x + 1);
      end;
      b := Min(Max(1.0, 1.0 / Sqrt(5.0 * f)), 10.0);
      a := TQMPNRM.famp[k];
      for x := 0 to TQMPNRM.fdsp.Data.Samples - 1 do begin
        if (b <= a) then begin
          y := (b - a) * Min(Max(0.0, x / (0.2 * TQMPNRM.fdsp.Data.Rates)), 1.0) + a;
          //y := (2 * (a - b) / Pi) * ArcTan2(Tan((0.01 * b * Pi) / (2 * (a - b))) * 0.2 * self.fdsp.Data.Rates, x) + b;
          //y := b * (x * (a - b * (1.0 + 0.01)) + 0.01 * a * 0.35 * self.fdsp.Data.Rates) / (x * (a - b * (1.0 + 0.01)) + 0.01 * b * 0.35 * self.fdsp.Data.Rates);
        end         else begin
          y := (b - a) * Min(Max(0.0, x / (5.0 * TQMPNRM.fdsp.Data.Rates)), 1.0) + a;
          //y := (2 * (b - a) / Pi) * ArcTan2(x, Tan((0.01 * b * Pi) / (2 * (b - a))) * 5.0 * self.fdsp.Data.Rates) + a;
          //y := b * (x * (a - b * (1.0 - 0.01)) - 0.01 * a * 35.0 * self.fdsp.Data.Rates) / (x * (a - b * (1.0 - 0.01)) - 0.01 * b * 35.0 * self.fdsp.Data.Rates);
        end;
        TQMPNRM.fdsp.Samples[x, k] := y * TQMPNRM.fdsp.Samples[x, k];
      end;
      TQMPNRM.famp[k] := y;
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
