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
    class var fdata: TData;
    class var finfo: TInfo;
    class var ffrm: TWMPFRM;
    class var fdsp: TWMPDSP;
    class var feqz: array[0..4, 0..20] of TWMPBQF;
    class function Init(const Module: PPlugin): Integer; cdecl; static;
    class function Modify(const Module: PPlugin; const Data: Pointer; const Samples: LongWord; const Bits: LongWord; const Channels: LongWord; const Rates: LongWord): Integer; cdecl; static;
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
var
  k: Integer;
  i: Integer;
begin
  for k := 0 to Length(TWMPEQU.feqz) - 1 do begin
    for i := 0 to Length(TWMPEQU.feqz[k]) - 1 do begin
      TWMPEQU.feqz[k, i].Init(ftEqu, btOctave, gtDb);
    end;
  end;
  TWMPEQU.fdsp.Init(Addr(TWMPEQU.fdata));
  TWMPEQU.ffrm.Init(Addr(TWMPEQU.finfo));
  Result := 0;
end;

class procedure TWMPEQU.Quit(const Module: PPlugin); cdecl;
var
  k: Integer;
  i: Integer;
begin
  TWMPEQU.ffrm.Done();
  TWMPEQU.fdsp.Done();
  for k := 0 to Length(TWMPEQU.feqz) - 1 do begin
    for i := 0 to Length(TWMPEQU.feqz[k]) - 1 do begin
      TWMPEQU.feqz[k, i].Done();
    end;
  end;
end;

class function TWMPEQU.Modify(const Module: PPlugin; const Data: Pointer; const Samples: LongWord; const Bits: LongWord; const Channels: LongWord; const Rates: LongWord): Integer; cdecl;
var
  k: Integer;
  i: Integer;
  x: Integer;
begin
  if((TWMPEQU.finfo.Enabled)) then begin
    TWMPEQU.fdata.Data := Data;
    TWMPEQU.fdata.Bits := Bits;
    TWMPEQU.fdata.Rates := Rates;
    TWMPEQU.fdata.Samples := Samples;
    TWMPEQU.fdata.Channels := Channels;
    for k := 0 to TWMPEQU.fdata.Channels - 1 do begin
      for i := 0 to Length(TWMPEQU.finfo.Bands) - 1 do begin
        TWMPEQU.feqz[k, i].Amp := (TWMPEQU.finfo.Preamp + TWMPEQU.finfo.Bands[i]) / 10;
        TWMPEQU.feqz[k, i].Freq := 20 * Power(2, 0.5 * i);
        TWMPEQU.feqz[k, i].Rate := TWMPEQU.fdata.Rates;
        TWMPEQU.feqz[k, i].Width := 0.5;
        for x := 0 to TWMPEQU.fdata.Samples - 1 do begin
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
