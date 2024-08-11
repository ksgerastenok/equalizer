unit
  WMPEQU;

interface

uses
  WMPDCL,
  WMPBQF,
  WMPDSP,
  WMPFRM;

type
  PWMPEQU = ^TWMPEQU;
  TWMPEQU = record
  private
    class var fenabled: Boolean;
    class var feqz: array[0..4, 0..20] of TWMPBQF;
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

class function TWMPEQU.Plugin(): PPlugin; cdecl;
begin
  Result := New(PPlugin);
  Result.Description := 'Nullsoft Equalizer v3.51';
  Result.Instance := $0000;
  Result.Init := TWMPEQU.Init;
  Result.Quit := TWMPEQU.Quit;
  Result.Modify := TWMPEQU.Modify;
  Result.Config := TWMPEQU.Config;
end;

class function TWMPEQU.Init(const Module: PPlugin): Integer; cdecl;
var
  k: LongWord;
  i: LongWord;
begin
  TWMPEQU.ffrm.Init();
  TWMPEQU.fdsp.Init();
  for k := 0 to Length(TWMPEQU.feqz) - 1 do begin
    for i := 0 to Length(TWMPEQU.feqz[k]) - 1 do begin
      TWMPEQU.feqz[k, i].Init(ftEqu, btOctave, gtDb);
      TWMPEQU.feqz[k, i].Freq := 20 * Power(2, 0.5 * i);
      TWMPEQU.feqz[k, i].Width := 0.5;
    end;
  end;
  Result := 0;
end;

class procedure TWMPEQU.Quit(const Module: PPlugin); cdecl;
var
  k: LongWord;
  i: LongWord;
begin
  for k := 0 to Length(TWMPEQU.feqz) - 1 do begin
    for i := 0 to Length(TWMPEQU.feqz[k]) - 1 do begin
      TWMPEQU.feqz[k, i].Freq := 0.0;
      TWMPEQU.feqz[k, i].Width := 0.0;
      TWMPEQU.feqz[k, i].Done();
    end;
  end;
  TWMPEQU.fdsp.Done();
  TWMPEQU.ffrm.Done();
end;

class function TWMPEQU.Modify(const Module: PPlugin; const Data: Pointer; const Samples: LongWord; const Bits: LongWord; const Channels: LongWord; const Rates: LongWord): Integer; cdecl;
var
  k: LongWord;
  i: LongWord;
  x: LongWord;
begin
  TWMPEQU.fenabled := TWMPEQU.ffrm.Info.Enabled;
  if (TWMPEQU.fenabled) then begin
    for k := 0 to Length(TWMPEQU.feqz) - 1 do begin
      for i := 0 to Length(TWMPEQU.feqz[k]) - 1 do begin
        TWMPEQU.feqz[k, i].Amp := (TWMPEQU.ffrm.Info.Preamp + TWMPEQU.ffrm.Info.Bands[i]) / 10;
      end;
    end;
    TWMPEQU.fdsp.Data.Data := Data;
    TWMPEQU.fdsp.Data.Bits := Bits;
    TWMPEQU.fdsp.Data.Rates := Rates;
    TWMPEQU.fdsp.Data.Samples := Samples;
    TWMPEQU.fdsp.Data.Channels := Channels;
    for k := 0 to Length(TWMPEQU.feqz) - 1 do begin
      for i := 0 to Length(TWMPEQU.feqz[k]) - 1 do begin
        TWMPEQU.feqz[k, i].Rate := TWMPEQU.fdsp.Data.Rates;
        for x := 0 to TWMPEQU.fdsp.Data.Samples - 1 do begin
          if (k < TWMPEQU.fdsp.Data.Channels) then begin
            TWMPEQU.fdsp.Buffer[x, k] := TWMPEQU.feqz[k, i].Process(TWMPEQU.fdsp.Buffer[x, k]);
          end;
        end;
      end;
    end;
  end;
  Result := Samples;
end;

class procedure TWMPEQU.Config(const Module: PPlugin); cdecl;
begin
  TWMPEQU.ffrm.Show();
end;

begin
end.
