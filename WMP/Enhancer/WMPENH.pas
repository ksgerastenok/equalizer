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
  PWMPENH = ^TWMPENH;
  TWMPENH = record
  private
    class var ffrm: TWMPFRM;
    class var fdsp: TWMPDSP;
    class var frng: array[0..4] of TWMPRNG;
    class var fbss: array[0..4] of TWMPBQF;
    class var ftrb: array[0..4] of TWMPBQF;
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
  TWMPENH.ffrm.Init();
  for k := 0 to Length(TWMPENH.frng) - 1 do begin
    TWMPENH.frng[k].Init();
  end;
  for k := 0 to Length(TWMPENH.fbss) - 1 do begin
    TWMPENH.fbss[k].Init(ftBass, btOctave, gtDb);
  end;
  for k := 0 to Length(TWMPENH.ftrb) - 1 do begin
    TWMPENH.ftrb[k].Init(ftTreble, btOctave, gtDb);
  end;
  Result := 0;
end;

class procedure TWMPENH.Quit(const Module: PPlugin); cdecl;
var
  k: Integer;
begin
  for k := 0 to Length(TWMPENH.frng) - 1 do begin
    TWMPENH.frng[k].Done();
  end;
  for k := 0 to Length(TWMPENH.fbss) - 1 do begin
    TWMPENH.fbss[k].Done();
  end;
  for k := 0 to Length(TWMPENH.ftrb) - 1 do begin
    TWMPENH.ftrb[k].Done();
  end;
  TWMPENH.ffrm.Done();
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
      for x := 0 to Samples - 1 do begin
        TWMPENH.fdsp.Buffer[x, k] := TWMPENH.fbss[k].Process(TWMPENH.fdsp.Buffer[x, k]);
      end;
    end;
    for k := 0 to Channels - 1 do begin
      TWMPENH.ftrb[k].Amp := TWMPENH.ffrm.Treble.Amp;
      TWMPENH.ftrb[k].Freq := TWMPENH.ffrm.Treble.Freq;
      TWMPENH.ftrb[k].Width := TWMPENH.ffrm.Treble.Width;
      TWMPENH.ftrb[k].Rate := Rates;
      for x := 0 to Samples - 1 do begin
        TWMPENH.fdsp.Buffer[x, k] := TWMPENH.ftrb[k].Process(TWMPENH.fdsp.Buffer[x, k]);
      end;
    end;
    TWMPENH.ffrm.Info.Size := 0;
    for k := 0 to Channels - 1 do begin
      TWMPENH.frng[k].Limit := Power(10, TWMPENH.ffrm.Info.Preamp / 200);
      for x := 0 to Samples - 1 do begin
        TWMPENH.fdsp.Buffer[x, k] := TWMPENH.frng[k].Process(TWMPENH.fdsp.Buffer[x, k]);
      end;
      TWMPENH.ffrm.Info.Size := Max(TWMPENH.ffrm.Info.Size, Round(200 * Log10(TWMPENH.frng[k].Value)));
    end;
    TWMPENH.ffrm.Update();
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
