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
    class function Init(const Plugin: PPlugin): Integer; cdecl; static;
    class procedure Quit(const Plugin: PPlugin); cdecl; static;
    class function Modify(const Plugin: PPlugin; const Data: Pointer; const Samples: LongWord; const Bits: LongWord; const Channels: LongWord; const Rates: LongWord): Integer; cdecl; static;
    class procedure Config(const Plugin: PPlugin); cdecl; static;
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

class function TWMPENH.Init(const Plugin: PPlugin): Integer; cdecl;
var
  k: LongWord;
begin
  TWMPENH.ffrm := TWMPFRM.Create();
  for k := 0 to Length(TWMPENH.fenh) - 1 do begin
    TWMPENH.fenh[k][0].Init(ttSVF, ftBass, btSlope, gtDb);
    TWMPENH.fenh[k][1].Init(ttSVF, ftBass, btSlope, gtDb);
    TWMPENH.fenh[k][2].Init(ttSVF, ftTreble, btSlope, gtDb);
  end;
  for k := 0 to Length(TWMPENH.frng) - 1 do begin
    TWMPENH.frng[k].Init(ttSVF, ftBand, btOctave, gtDb);
  end;
  Result := 0;
end;

class procedure TWMPENH.Quit(const Plugin: PPlugin); cdecl;
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

class function TWMPENH.Modify(const Plugin: PPlugin; const Data: Pointer; const Samples: LongWord; const Bits: LongWord; const Channels: LongWord; const Rates: LongWord): Integer; cdecl;
var
  k: LongWord;
  i: LongWord;
  x: LongWord;
  v: Double;
  s: Double;
begin
  if (TWMPENH.ffrm.Info.Enabled) then begin
    for k := 0 to Length(TWMPENH.fenh) - 1 do begin
      for i := 0 to Length(TWMPENH.fenh[k]) - 1 do begin
        TWMPENH.fenh[k][i].Amp := TWMPENH.ffrm.Config[i].Amp;
        TWMPENH.fenh[k][i].Freq := TWMPENH.ffrm.Config[i].Freq;
        TWMPENH.fenh[k][i].Width := TWMPENH.ffrm.Config[i].Width;
        TWMPENH.fenh[k][i].Rate := Rates;
      end;
      TWMPENH.frng[k].Amp := TWMPENH.ffrm.Info.Preamp / 10.0;
      TWMPENH.frng[k].Freq := 320.0;
      TWMPENH.frng[k].Width := 8.0;
      TWMPENH.frng[k].Rate := Rates;
    end;
    TWMPENH.fdsp.Init(Data, Bits, Rates, Samples, Channels);
    for x := 0 to Samples - 1 do begin
      s := 0.0;
      for k := 0 to Channels - 1 do begin
        s := s - (s - TWMPENH.fdsp.Data[k, x]) / (k + 1);
      end;
      for k := 0 to Channels - 1 do begin
        v := TWMPENH.fdsp.Data[k, x];
        v := v * 1.5 + s * (1.0 - 1.5);
        for i := 0 to Length(TWMPENH.fenh[k]) - 1 do begin
          v := TWMPENH.fenh[k][i].Process(v);
        end;
        v := TWMPENH.frng[k].Process(v);
        TWMPENH.fdsp.Data[k, x] := v;
      end;
    end;
    TWMPENH.fdsp.Done();
    s := 0.0;
    for k := 0 to Channels - 1 do begin
      s := s - (s - TWMPENH.frng[k].Amp) / (k + 1);
    end;
    TWMPENH.ffrm.Info.Size := Round(s * 10.0);
    TWMPENH.ffrm.Refresh();
  end;
  Result := Samples;
end;

class procedure TWMPENH.Config(const Plugin: PPlugin); cdecl;
begin
  TWMPENH.ffrm.Show();
end;

begin
end.
