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
    class var fbss: array[0..4] of TWMPBQF;
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

uses
  Math;

class function TWMPENH.Plugin(): PPlugin; cdecl;
begin
  Result := New(PPlugin);
  Result.Description := 'Nullsoft Enhancer v3.51';
  Result.Instance := $0000;
  Result.Init := TWMPENH.Init;
  Result.Quit := TWMPENH.Quit;
  Result.Modify := TWMPENH.Modify;
  Result.Config := TWMPENH.Config;
end;

class function TWMPENH.Init(const Module: PPlugin): Integer; cdecl;
var
  k: Integer;
begin
  for k := 0 to Length(TWMPENH.fbss) - 1 do begin
    TWMPENH.fbss[k].Init(ftBass, btSlope, gtDb);
  end;
  for k := 0 to Length(TWMPENH.ftrb) - 1 do begin
    TWMPENH.ftrb[k].Init(ftTreble, btSlope, gtDb);
  end;
  for k := 0 to Length(TWMPENH.frng) - 1 do begin
    TWMPENH.frng[k].Init(ftBand, btSlope, gtDb);
  end;
  TWMPENH.ffrm := TWMPFRM.Create();
  Result := 0;
end;

class procedure TWMPENH.Quit(const Module: PPlugin); cdecl;
var
  k: Integer;
begin
  for k := 0 to Length(TWMPENH.fbss) - 1 do begin
    TWMPENH.fbss[k].Done();
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
begin
  if (TWMPENH.ffrm.Info.Enabled) then begin
    TWMPENH.fdsp.Init(Data, Bits, Rates, Samples, Channels);
    for k := 0 to Channels - 1 do begin
      TWMPENH.fbss[k].Amp := TWMPENH.ffrm.Bass.Amp;
      TWMPENH.fbss[k].Freq := TWMPENH.ffrm.Bass.Freq;
      TWMPENH.fbss[k].Width := TWMPENH.ffrm.Bass.Width;
      TWMPENH.fbss[k].Rate := Rates;
      TWMPENH.ftrb[k].Amp := TWMPENH.ffrm.Treble.Amp;
      TWMPENH.ftrb[k].Freq := TWMPENH.ffrm.Treble.Freq;
      TWMPENH.ftrb[k].Width := TWMPENH.ffrm.Treble.Width;
      TWMPENH.ftrb[k].Rate := Rates;
      TWMPENH.frng[k].Amp := TWMPENH.ffrm.Info.Preamp / 10;
      TWMPENH.frng[k].Freq := 640.0;
      TWMPENH.frng[k].Width := 0.1;
      TWMPENH.frng[k].Rate := Rates;
      for x := 0 to Samples - 1 do begin
        TWMPENH.fdsp.Buffer[k, x] := TWMPENH.fbss[k].Process(TWMPENH.fdsp.Buffer[k, x]);
        TWMPENH.fdsp.Buffer[k, x] := TWMPENH.ftrb[k].Process(TWMPENH.fdsp.Buffer[k, x]);
        TWMPENH.fdsp.Buffer[k, x] := TWMPENH.frng[k].Process(TWMPENH.fdsp.Buffer[k, x]);
      end;
    end;
    TWMPENH.fdsp.Done();
    x := 0;
    for k := 0 to Channels - 1 do begin
      x := Max(x, Round(10 * TWMPENH.frng[k].Gain));
    end;
    TWMPENH.ffrm.Refresh(x);
  end;
  Result := Samples;
end;

class procedure TWMPENH.Config(const Module: PPlugin); cdecl;
begin
  TWMPENH.ffrm.Show();
end;

begin
end.
