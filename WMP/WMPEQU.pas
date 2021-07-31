unit
  WMPEQU;

interface

uses
  WMPBQF,
  WMPDSP,
  WMPDCL,
  WMPFRM;

type
  PWMPEQU = ^TWMPEQU;
  TWMPEQU = record
  private
    class var ffrm: TWMPFRM;
    class var fdsp: TWMPDSP;
    class var feqz: array[0..4, 0..20] of TWMPBQF;
    class function Init(const Module: PPlugin): Integer; cdecl; static;
    class function Modify(const Module: PPlugin; const Data: Pointer; const Samples: Integer; const Bits: Integer; const Channels: Integer; const Rates: Integer): Integer; cdecl; static;
    class procedure Config(const Module: PPlugin); cdecl; static;
    class procedure Quit(const Module: PPlugin); cdecl; static;
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
begin
  for var k := 0 to Length(TWMPEQU.feqz) - 1 do begin
    for var i := 0 to Length(TWMPEQU.feqz[k]) - 1 do begin
      TWMPEQU.feqz[k, i].Init(ftEqu, btOctave, gtDb);
    end;
  end;
  TWMPEQU.ffrm.Init(TWMPEQU.fdsp.Info);
  Result := 0;
end;

class procedure TWMPEQU.Quit(const Module: PPlugin); cdecl;
begin
  TWMPEQU.ffrm.Quit();
end;

class function TWMPEQU.Modify(const Module: PPlugin; const Data: Pointer; const Samples: Integer; const Bits: Integer; const Channels: Integer; const Rates: Integer): Integer; cdecl;
begin
  if((TWMPEQU.fdsp.Info.Enabled)) then begin
    TWMPEQU.fdsp.Data.Data := Data;
    TWMPEQU.fdsp.Data.Bits := Bits;
    TWMPEQU.fdsp.Data.Rates := Rates;
    TWMPEQU.fdsp.Data.Samples := Samples;
    TWMPEQU.fdsp.Data.Channels := Channels;
    for var k := 0 to TWMPEQU.fdsp.Data.Channels - 1 do begin
      for var i := 0 to Length(TWMPEQU.fdsp.Info.Bands) - 1 do begin
        TWMPEQU.feqz[k, i].Amp := (TWMPEQU.fdsp.Info.Preamp + TWMPEQU.fdsp.Info.Bands[i]) / 10;
        TWMPEQU.feqz[k, i].Freq := 20 * Power(2, 0.5 * i);
        TWMPEQU.feqz[k, i].Rate := TWMPEQU.fdsp.Data.Rates;
        TWMPEQU.feqz[k, i].Width := 0.5;
        for var x := 0 to TWMPEQU.fdsp.Data.Samples - 1 do begin
          TWMPEQU.fdsp.Samples[x, k] := TWMPEQU.feqz[k, i].Process(TWMPEQU.fdsp.Samples[x, k]);
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
