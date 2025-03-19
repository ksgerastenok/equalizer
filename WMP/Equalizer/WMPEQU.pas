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
    class var ffrm: TWMPFRM;
    class var fdsp: TWMPDSP;
    class var feqz: array[0..4, 0..20] of TWMPBQF;
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
  for k := 0 to Length(TWMPEQU.feqz) - 1 do begin
    for i := 0 to Length(TWMPEQU.feqz[k]) - 1 do begin
      TWMPEQU.feqz[k, i].Init(ftEqu, btOctave, gtDb);
      TWMPEQU.feqz[k, i].Amp := 0.0;
      TWMPEQU.feqz[k, i].Freq := 20 * Power(2, 0.5 * i);
      TWMPEQU.feqz[k, i].Width := 0.5;
    end;
  end;
  TWMPEQU.ffrm.Init();
  Result := 0;
end;

class procedure TWMPEQU.Quit(const Module: PPlugin); cdecl;
var
  k: LongWord;
  i: LongWord;
begin
  for k := 0 to Length(TWMPEQU.feqz) - 1 do begin
    for i := 0 to Length(TWMPEQU.feqz[k]) - 1 do begin
      TWMPEQU.feqz[k, i].Amp := 0.0;
      TWMPEQU.feqz[k, i].Freq := 0.0;
      TWMPEQU.feqz[k, i].Width := 0.0;
      TWMPEQU.feqz[k, i].Done();
    end;
  end;
  TWMPEQU.ffrm.Done();
end;

class function TWMPEQU.Modify(const Module: PPlugin; const Data: Pointer; const Samples: LongWord; const Bits: LongWord; const Channels: LongWord; const Rates: LongWord): Integer; cdecl;
var
  k: LongWord;
  i: LongWord;
  x: LongWord;
begin
  if (TWMPEQU.ffrm.Info.Enabled) then begin
    TWMPEQU.fdsp.Init(Data, Bits, Rates, Samples, Channels);
    for x := 0 to Samples - 1 do begin
      for k := 0 to Length(TWMPEQU.feqz) - 1 do begin
        for i := 0 to Length(TWMPEQU.feqz[k]) - 1 do begin
          if (k < Channels) then begin
            TWMPEQU.feqz[k, i].Amp := (TWMPEQU.ffrm.Info.Preamp + TWMPEQU.ffrm.Info.Bands[i]) / 10;
            TWMPEQU.feqz[k, i].Rate := Rates;
            TWMPEQU.fdsp.Buffer[x, k] := TWMPEQU.feqz[k, i].Process(TWMPEQU.fdsp.Buffer[x, k]);
          end;
        end;
      end;
    end;
    TWMPEQU.fdsp.Done();
  end;
  Result := Samples;
end;

class procedure TWMPEQU.Config(const Module: PPlugin); cdecl;
begin
  TWMPEQU.ffrm.Show();
end;

begin
end.
