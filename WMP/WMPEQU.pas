unit
  WMPEQU;

interface

uses
  WMPFRM,
  WMPBQF,
  WMPDSP,
  WMPDCL;

type
  TWMPEQU = record
  private
    class var fdsp: TWMPDSP;
    class var feqz: array[0..4, 0..18] of TWMPBQF;
    class function getDSP(): TWMPDSP; cdecl; static;
    class procedure Initialize(); cdecl; static;
    class procedure Finalize(); cdecl; static;
    class function Init(const Module: PPlugin): Integer; cdecl; static;
    class function Modify(const Module: PPlugin; const Data: Pointer; const Samples: Integer; const Bits: Integer; const Channels: Integer; const Rates: Integer): Integer; cdecl; static;
    class procedure Config(const Module: PPlugin); cdecl; static;
    class procedure Quit(const Module: PPlugin); cdecl; static;
  public
    class function Plugin(): PPlugin; cdecl; static;
    class property DSP: TWMPDSP read getDSP;
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

class function TWMPEQU.getDSP(): TWMPDSP; cdecl;
begin
  Result := TWMPEQU.fdsp;
end;

class procedure TWMPEQU.Initialize(); cdecl;
var
  k: Integer;
  i: Integer;
begin
  TWMPEQU.fdsp := TWMPDSP.Create();
  for k := 0 to Length(TWMPEQU.feqz) - 1 do begin
    for i := 0 to Length(TWMPEQU.feqz[k]) - 1 do begin
      TWMPEQU.feqz[k, i] := TWMPBQF.Create(ftEqu, btOctave, gtDb);
    end;
  end;
end;

class procedure TWMPEQU.Finalize(); cdecl;
var
  k: Integer;
  i: Integer;
begin
  for k := 0 to Length(TWMPEQU.feqz) - 1 do begin
    for i := 0 to Length(TWMPEQU.feqz[k]) - 1 do begin
      TWMPEQU.feqz[k, i].Destroy();
    end;
  end;
  TWMPEQU.fdsp.Destroy();
end;

class function TWMPEQU.Init(const Module: PPlugin): Integer; cdecl;
var
  f: file;
  i: Integer;
begin
  TWMPEQU.Initialize();
  try
    System.Assign(f, 'equalizer.cfg');
    System.ReSet(f, 1);
    System.BlockRead(f, TWMPEQU.DSP.Info^, SizeOf(TInfo) * 1);
    System.Close(f);
  except
    TWMPEQU.DSP.Info.Preamp := 0;
    TWMPEQU.DSP.Info.Enabled := False;
    for i := 0 to Length(TWMPEQU.DSP.Info.Bands) - 1 do begin
      TWMPEQU.DSP.Info.Bands[i] := 0;
    end;
  end;
  TWMPFRM.Instance().Hide();
  Result := 0;
end;

class procedure TWMPEQU.Quit(const Module: PPlugin); cdecl;
var
  f: file;
  i: Integer;
begin
  TWMPFRM.Quit();
  try
    System.Assign(f, 'equalizer.cfg');
    System.ReWrite(f, 1);
    System.BlockWrite(f, TWMPEQU.DSP.Info^, SizeOf(TInfo) * 1);
    System.Close(f);
  except
    TWMPEQU.DSP.Info.Preamp := 0;
    TWMPEQU.DSP.Info.Enabled := False;
    for i := 0 to Length(TWMPEQU.DSP.Info.Bands) - 1 do begin
      TWMPEQU.DSP.Info.Bands[i] := 0;
    end;
  end;
  TWMPEQU.Finalize();
end;

class function TWMPEQU.Modify(const Module: PPlugin; const Data: Pointer; const Samples: Integer; const Bits: Integer; const Channels: Integer; const Rates: Integer): Integer; cdecl;
var
  i: Integer;
  k: Integer;
  x: Integer;
begin
  if((TWMPEQU.DSP.Info.Enabled)) then begin
    TWMPEQU.DSP.Data.Data := Data;
    TWMPEQU.DSP.Data.Bits := Bits;
    TWMPEQU.DSP.Data.Rates := Rates;
    TWMPEQU.DSP.Data.Samples := Samples;
    TWMPEQU.DSP.Data.Channels := Channels;
    for k := 0 to TWMPEQU.DSP.Data.Channels - 1 do begin
      for i := 0 to Length(TWMPEQU.DSP.Info.Bands) - 1 do begin
        TWMPEQU.feqz[k, i].Amp := (TWMPEQU.DSP.Info.Preamp + TWMPEQU.DSP.Info.Bands[i]) / 10;
        TWMPEQU.feqz[k, i].Freq := 35 * Power(2, 0.5 * i);
        TWMPEQU.feqz[k, i].Rate := TWMPEQU.DSP.Data.Rates;
        TWMPEQU.feqz[k, i].Width := 0.5;
        for x := 0 to TWMPEQU.DSP.Data.Samples - 1 do begin
          TWMPEQU.DSP.Samples[x, k] := TWMPEQU.feqz[k, i].Process(TWMPEQU.DSP.Samples[x, k]);
        end;
      end;
    end;
  end;
  Result := Samples;
end;

class procedure TWMPEQU.Config(const Module: PPlugin); cdecl;
begin
  TWMPFRM.Instance().Show();
end;

begin
end.
