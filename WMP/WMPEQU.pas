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
    class function getDSP(): PWMPDSP; cdecl; static;
    class function Init(const Module: PPlugin): Integer; cdecl; static;
    class function Modify(const Module: PPlugin; const Data: Pointer; const Samples: Integer; const Bits: Integer; const Channels: Integer; const Rates: Integer): Integer; cdecl; static;
    class procedure Config(const Module: PPlugin); cdecl; static;
    class procedure Quit(const Module: PPlugin); cdecl; static;
  public
    class function Plugin(): PPlugin; cdecl; static;
    class property DSP: PWMPDSP read getDSP;
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

class function TWMPEQU.getDSP(): PWMPDSP; cdecl;
begin
  Result := Addr(TWMPEQU.fdsp);
end;

class function TWMPEQU.Init(const Module: PPlugin): Integer; cdecl;
begin
  for var k := 0 to Length(TWMPEQU.feqz) - 1 do begin
    for var i := 0 to Length(TWMPEQU.feqz[k]) - 1 do begin
      TWMPEQU.feqz[k, i].Init(ftEqu, btOctave, gtDb);
    end;
  end;
  TWMPEQU.ffrm.Init(TWMPEQU.DSP.Info);
  Result := 0;
end;

class procedure TWMPEQU.Quit(const Module: PPlugin); cdecl;
begin
  TWMPEQU.ffrm.Quit();
end;

class function TWMPEQU.Modify(const Module: PPlugin; const Data: Pointer; const Samples: Integer; const Bits: Integer; const Channels: Integer; const Rates: Integer): Integer; cdecl;
begin
  if((TWMPEQU.DSP.Info.Enabled)) then begin
    TWMPEQU.DSP.Data.Data := Data;
    TWMPEQU.DSP.Data.Bits := Bits;
    TWMPEQU.DSP.Data.Rates := Rates;
    TWMPEQU.DSP.Data.Samples := Samples;
    TWMPEQU.DSP.Data.Channels := Channels;
    for var k := 0 to TWMPEQU.DSP.Data.Channels - 1 do begin
      for var i := 0 to Length(TWMPEQU.DSP.Info.Bands) - 1 do begin
        TWMPEQU.feqz[k, i].Amp := (TWMPEQU.DSP.Info.Preamp + TWMPEQU.DSP.Info.Bands[i]) / 10;
        TWMPEQU.feqz[k, i].Freq := 20 * Power(2, 0.5 * i);
        TWMPEQU.feqz[k, i].Rate := TWMPEQU.DSP.Data.Rates;
        TWMPEQU.feqz[k, i].Width := 0.5;
        for var x := 0 to TWMPEQU.DSP.Data.Samples - 1 do begin
          TWMPEQU.DSP.Samples[x, k] := TWMPEQU.feqz[k, i].Process(TWMPEQU.DSP.Samples[x, k]);
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
