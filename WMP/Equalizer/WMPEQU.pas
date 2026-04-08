unit
  WMPEQU;

interface

uses
  WMPDCL,
  WMPBQF,
  WMPRNG,
  WMPDSP,
  WMPFRM;

type
  TWMPEQU = record
  private
    class var ffrm: TWMPFRM;
    class var fdsp: TWMPDSP;
    class var fequ: array[0..4] of array[0..19] of TWMPBQF;
    class var frng: array[0..4] of TWMPRNG;
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
  TWMPEQU.ffrm := TWMPFRM.Create();
  for k := 0 to Length(TWMPEQU.fequ) - 1 do begin
    for i := 0 to Length(TWMPEQU.fequ[k]) - 1 do begin
      TWMPEQU.fequ[k, i].Init(ptLAT, ftEqu, btOctave, gtDb);
    end;
  end;
  for k := 0 to Length(TWMPEQU.frng) - 1 do begin
    TWMPEQU.frng[k].Init(ptLAT, ftBand, btOctave, gtDb);
  end;
  Result := 0;
end;

class procedure TWMPEQU.Quit(const Module: PPlugin); cdecl;
var
  k: LongWord;
  i: LongWord;
begin
  for k := 0 to Length(TWMPEQU.fequ) - 1 do begin
    for i := 0 to Length(TWMPEQU.fequ[k]) - 1 do begin
      TWMPEQU.fequ[k, i].Done();
    end;
  end;
  for k := 0 to Length(TWMPEQU.frng) - 1 do begin
    TWMPEQU.frng[k].Done();
  end;
  TWMPEQU.ffrm.Destroy();
end;

class function TWMPEQU.Modify(const Module: PPlugin; const Data: Pointer; const Samples: LongWord; const Bits: LongWord; const Channels: LongWord; const Rates: LongWord): Integer; cdecl;
var
  k: LongWord;
  i: LongWord;
  x: LongWord;
  v: Double;
begin
  if (TWMPEQU.ffrm.Info.Enabled) then begin
    TWMPEQU.fdsp.Init(Data, Bits, Rates, Samples, Channels);
    TWMPEQU.ffrm.Info.Size := 0;
    for k := 0 to Channels - 1 do begin
      for i := 0 to Length(TWMPEQU.ffrm.Info.Bands) - 1 do begin
        TWMPEQU.fequ[k, i].Amp := (TWMPEQU.ffrm.Info.Preamp + TWMPEQU.ffrm.Info.Bands[i]) / 10.0;
        TWMPEQU.fequ[k, i].Freq := 20.0 * Power(2.0, 0.5 * (i + 0.5));
        TWMPEQU.fequ[k, i].Width := 0.5;
        TWMPEQU.fequ[k, i].Rate := Rates;
      end;
      TWMPEQU.frng[k].Amp := 20.0;
      TWMPEQU.frng[k].Freq := 160.0;
      TWMPEQU.frng[k].Width := 6.0;
      TWMPEQU.frng[k].Rate := Rates;
      for x := 0 to Samples - 1 do begin
        v := TWMPEQU.fdsp.Data[k, x];
        for i := 0 to Length(TWMPEQU.ffrm.Info.Bands) - 1 do begin
          v := TWMPEQU.fequ[k, i].Process(v);
        end;
        v := TWMPEQU.frng[k].Process(v);
        TWMPEQU.fdsp.Data[k, x] := v;
      end;
      TWMPEQU.ffrm.Info.Size := Round(TWMPEQU.ffrm.Info.Size - (TWMPEQU.ffrm.Info.Size - 10 * TWMPEQU.frng[k].Amp) / (k + 1));
    end;
    TWMPEQU.ffrm.Refresh();
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
