unit
  WMPENH;

interface

uses
  WMPDCL,
  WMPDSP,
  WMPBQF,
  WMPFRM;

type
  PWMPENH = ^TWMPENH;
  TWMPENH = record
  private
    class var ffrm: TWMPFRM;
    class var fdsp: TWMPDSP;
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
      TWMPENH.fbss[k].Amp := TWMPENH.ffrm.Info.Bass.Amp;
      TWMPENH.ftrb[k].Amp := TWMPENH.ffrm.Info.Treble.Amp;
      TWMPENH.fbss[k].Freq := TWMPENH.ffrm.Info.Bass.Freq;
      TWMPENH.ftrb[k].Freq := TWMPENH.ffrm.Info.Treble.Freq;
      TWMPENH.fbss[k].Width := TWMPENH.ffrm.Info.Bass.Width;
      TWMPENH.ftrb[k].Width := TWMPENH.ffrm.Info.Treble.Width;
      TWMPENH.fbss[k].Rate := Rates;
      TWMPENH.ftrb[k].Rate := Rates;
      for x := 0 to Samples - 1 do begin
        TWMPENH.fdsp.Buffer[x, k] := TWMPENH.fbss[k].Process(TWMPENH.fdsp.Buffer[x, k]);
        TWMPENH.fdsp.Buffer[x, k] := TWMPENH.ftrb[k].Process(TWMPENH.fdsp.Buffer[x, k]);
      end;
    end;
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
