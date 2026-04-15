unit
  WMPENH;

interface

uses
  WMPDCL,
  WMPDSP,
  WMPBQF,
  WMPRNG,
  WMPFRM;

type
  TWMPENH = record
  private
    class var ffrm: TWMPFRM;
    class var fdsp: TWMPDSP;
    class var fenh: array[0..4] of array[0..2] of TWMPBQF;
    class var frng: array[0..4] of TWMPRNG;
    class function Init(const Module: PPlugin): Integer; cdecl; static;
    class procedure Quit(const Module: PPlugin); cdecl; static;
    class function Modify(const Module: PPlugin; const Data: Pointer; const Samples: LongWord; const Bits: LongWord; const Channels: LongWord; const Rates: LongWord): Integer; cdecl; static;
    class procedure Config(const Module: PPlugin); cdecl; static;
  public
    class function Plugin(): PPlugin; cdecl; static;
  end;

implementation

class function TWMPENH.Plugin(): PPlugin; cdecl;
begin
  Result := New(PPlugin);
  Result.Description := 'Nullsoft Enhancer v3.51';
  Result.Init := TWMPENH.Init;
  Result.Quit := TWMPENH.Quit;
  Result.Modify := TWMPENH.Modify;
  Result.Config := TWMPENH.Config;
end;

class function TWMPENH.Init(const Module: PPlugin): Integer; cdecl;
var
  k: LongWord;
begin
  TWMPENH.ffrm := TWMPFRM.Create();
  for k := 0 to Length(TWMPENH.fenh) - 1 do begin
    TWMPENH.fenh[k][0].Init(ptLAT, ftBass, btSlope, gtDb);
    TWMPENH.fenh[k][1].Init(ptLAT, ftBass, btSlope, gtDb);
    TWMPENH.fenh[k][2].Init(ptLAT, ftTreble, btSlope, gtDb);
  end;
  for k := 0 to Length(TWMPENH.frng) - 1 do begin
    TWMPENH.frng[k].Init(ptLAT, ftBand, btOctave, gtDb);
  end;
  Result := 0;
end;

class procedure TWMPENH.Quit(const Module: PPlugin); cdecl;
var
  k: LongWord;
begin
  for k := 0 to Length(TWMPENH.fenh) - 1 do begin
    TWMPENH.fenh[k][0].Done();
    TWMPENH.fenh[k][1].Done();
    TWMPENH.fenh[k][2].Done();
  end;
  for k := 0 to Length(TWMPENH.frng) - 1 do begin
    TWMPENH.frng[k].Done();
  end;
  TWMPENH.ffrm.Destroy();
end;

class function TWMPENH.Modify(const Module: PPlugin; const Data: Pointer; const Samples: LongWord; const Bits: LongWord; const Channels: LongWord; const Rates: LongWord): Integer; cdecl;
var
  k: LongWord;
  i: LongWord;
  x: LongWord;
  v: Double;
begin
  if (TWMPENH.ffrm.Info.Enabled) then begin
    TWMPENH.fdsp.Init(Data, Bits, Rates, Samples, Channels);
    TWMPENH.ffrm.Info.Size := 0;
    for k := 0 to Channels - 1 do begin
      for i := 0 to Length(TWMPENH.fenh[k]) - 1 do begin
        TWMPENH.fenh[k][i].Amp := TWMPENH.ffrm.Config[i].Amp;
        TWMPENH.fenh[k][i].Freq := TWMPENH.ffrm.Config[i].Freq;
        TWMPENH.fenh[k][i].Width := TWMPENH.ffrm.Config[i].Width;
        TWMPENH.fenh[k][i].Rate := Rates;
      end;
      TWMPENH.frng[k].Amp := TWMPENH.ffrm.Info.Preamp / 10;
      TWMPENH.frng[k].Freq := 320.0;
      TWMPENH.frng[k].Width := 8.0;
      TWMPENH.frng[k].Rate := Rates;
      for x := 0 to Samples - 1 do begin
        v := TWMPENH.fdsp.Data[k, x];
        for i := 0 to Length(TWMPENH.fenh[k]) - 1 do begin
          v := TWMPENH.fenh[k][i].Process(v);
        end;
        v := TWMPENH.frng[k].Process(v);
        TWMPENH.fdsp.Data[k, x] := v;
      end;
      TWMPENH.ffrm.Info.Size := Round(TWMPENH.ffrm.Info.Size - (TWMPENH.ffrm.Info.Size - 10 * TWMPENH.frng[k].Amp) / (k + 1));
    end;
    TWMPENH.ffrm.Refresh();
    TWMPENH.fdsp.Done();
  end;
  Result := Samples;
end;

class procedure TWMPENH.Config(const Module: PPlugin); cdecl;
begin
  TWMPENH.ffrm.Show();
end;

begin
end.
