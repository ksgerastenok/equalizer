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
    class var fhrm: array[0..4] of TWMPBQF;
    class var fdrm: array[0..4] of TWMPBQF;
    class var ftrb: array[0..4] of TWMPBQF;
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
  for k := 0 to Length(TWMPENH.fhrm) - 1 do begin
    TWMPENH.fhrm[k].Init(ptLAT, ftBass, btSlope, gtDb);
  end;
  for k := 0 to Length(TWMPENH.fdrm) - 1 do begin
    TWMPENH.fdrm[k].Init(ptLAT, ftBass, btSlope, gtDb);
  end;
  for k := 0 to Length(TWMPENH.ftrb) - 1 do begin
    TWMPENH.ftrb[k].Init(ptLAT, ftTreble, btSlope, gtDb);
  end;
  for k := 0 to Length(TWMPENH.frng) - 1 do begin
    TWMPENH.frng[k].Init(ptLAT, ftBand, btSlope, gtDb);
  end;
  Result := 0;
end;

class procedure TWMPENH.Quit(const Module: PPlugin); cdecl;
var
  k: LongWord;
begin
  for k := 0 to Length(TWMPENH.fhrm) - 1 do begin
    TWMPENH.fhrm[k].Done();
  end;
  for k := 0 to Length(TWMPENH.fdrm) - 1 do begin
    TWMPENH.fdrm[k].Done();
  end;
  for k := 0 to Length(TWMPENH.ftrb) - 1 do begin
    TWMPENH.ftrb[k].Done();
  end;
  for k := 0 to Length(TWMPENH.frng) - 1 do begin
    TWMPENH.frng[k].Done();
  end;
  TWMPENH.ffrm.Destroy();
end;

class function TWMPENH.Modify(const Module: PPlugin; const Data: Pointer; const Samples: LongWord; const Bits: LongWord; const Channels: LongWord; const Rates: LongWord): Integer; cdecl;
var
  k: LongWord;
  x: LongWord;
  v: Double;
begin
  if (TWMPENH.ffrm.Info.Enabled) then begin
    TWMPENH.fdsp.Init(Data, Bits, Rates, Samples, Channels);
    TWMPENH.ffrm.Info.Size := 0;
    for k := 0 to Channels - 1 do begin
      TWMPENH.fhrm[k].Amp := TWMPENH.ffrm.Bass.Amp;
      TWMPENH.fhrm[k].Freq := TWMPENH.ffrm.Bass.Freq;
      TWMPENH.fhrm[k].Width := TWMPENH.ffrm.Bass.Width;
      TWMPENH.fhrm[k].Rate := Rates;
      TWMPENH.fdrm[k].Amp := TWMPENH.ffrm.Drum.Amp;
      TWMPENH.fdrm[k].Freq := TWMPENH.ffrm.Drum.Freq;
      TWMPENH.fdrm[k].Width := TWMPENH.ffrm.Drum.Width;
      TWMPENH.fdrm[k].Rate := Rates;
      TWMPENH.ftrb[k].Amp := TWMPENH.ffrm.Treble.Amp;
      TWMPENH.ftrb[k].Freq := TWMPENH.ffrm.Treble.Freq;
      TWMPENH.ftrb[k].Width := TWMPENH.ffrm.Treble.Width;
      TWMPENH.ftrb[k].Rate := Rates;
      TWMPENH.frng[k].Amp := TWMPENH.ffrm.Info.Preamp / 10;
      TWMPENH.frng[k].Freq := 640.0;
      TWMPENH.frng[k].Width := 0.002;
      TWMPENH.frng[k].Rate := Rates;
      for x := 0 to Samples - 1 do begin
        v := TWMPENH.fdsp.Data[k, x];
        v := TWMPENH.fhrm[k].Process(v);
        v := TWMPENH.fdrm[k].Process(v);
        v := TWMPENH.ftrb[k].Process(v);
        v := TWMPENH.frng[k].Process(v);
        TWMPENH.fdsp.Data[k, x] := v;
      end;
      TWMPENH.ffrm.Info.Size := Round(TWMPENH.ffrm.Info.Size - (TWMPENH.ffrm.Info.Size - 10 * TWMPENH.frng[k].Gain) / (k + 1));
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
