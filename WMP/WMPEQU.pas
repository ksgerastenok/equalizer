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
    class var feqz: array[0..4, 0..18] of TWMPBQF;
    class var finfo: PInfo;
    class var fdata: PData;
    class function getInfo(): PInfo; cdecl; static;
    class function getData(): PData; cdecl; static;
    class function Init(const Module: PPlugin): Integer; cdecl; static;
    class procedure Quit(const Module: PPlugin); cdecl; static;
    class function Modify(const Module: PPlugin; const Data: Pointer; const Samples: Integer; const Bits: Integer; const Channels: Integer; const Rates: Integer): Integer; cdecl; static;
    class procedure Config(const Module: PPlugin); cdecl; static;
  public
    class property Info: PInfo read getInfo;
    class property Data: PData read getData;
    class function Plugin(): PPlugin; cdecl; static;
  end;

implementation

uses
  Math;

class function TWMPEQU.Plugin(): PPlugin; cdecl;
begin
  Result := New(PPlugin);
  Result.Description := 'Nullsoft Equalizer Plugin v3.51';
  Result.Instance := $0000;
  Result.Init := TWMPEQU.Init;
  Result.Quit := TWMPEQU.Quit;
  Result.Modify := TWMPEQU.Modify;
  Result.Config := TWMPEQU.Config;
end;

class function TWMPEQU.Init(const Module: PPlugin): Integer; cdecl;
var
  f: file;
  i: Integer;
  k: Integer;
begin
  TWMPEQU.finfo := New(PInfo);
  TWMPEQU.fdata := New(PData);
  for k := 0 to Length(TWMPEQU.feqz) - 1 do begin
    for i := 0 to Length(TWMPEQU.feqz[k]) - 1 do begin
      TWMPEQU.feqz[k, i] := TWMPBQF.Create(ftEqu, btOctave, gtDb);
    end;
  end;
  try
    System.Assign(f, 'equalizer.cfg');
    System.ReSet(f, 1);
    System.BlockRead(f, TWMPEQU.finfo^, SizeOf(TInfo) * 1);
    System.Close(f);
  except
    TWMPEQU.finfo.Preamp := 0;
    TWMPEQU.finfo.Enabled := False;
    for i := 0 to Length(TWMPEQU.finfo.Bands) - 1 do begin
      TWMPEQU.finfo.Bands[i] := 0;
    end;
  end;
  TWMPFRM.Instance().Hide();
  Result := 0;
end;

class procedure TWMPEQU.Quit(const Module: PPlugin); cdecl;
var
  f: file;
  i: Integer;
  k: Integer;
begin
  try
    System.Assign(f, 'equalizer.cfg');
    System.ReWrite(f, 1);
    System.BlockWrite(f, TWMPEQU.finfo^, SizeOf(TInfo) * 1);
    System.Close(f);
  except
    TWMPEQU.finfo.Preamp := 0;
    TWMPEQU.finfo.Enabled := False;
    for i := 0 to Length(TWMPEQU.finfo.Bands) - 1 do begin
      TWMPEQU.finfo.Bands[i] := 0;
    end;
  end;
  for k := 0 to Length(TWMPEQU.feqz) - 1 do begin
    for i := 0 to Length(TWMPEQU.feqz[k]) - 1 do begin
      TWMPEQU.feqz[k, i].Destroy();
    end;
  end;
  Dispose(TWMPEQU.finfo);
  Dispose(TWMPEQU.fdata);
  TWMPFRM.Quit();
end;

class function TWMPEQU.Modify(const Module: PPlugin; const Data: Pointer; const Samples: Integer; const Bits: Integer; const Channels: Integer; const Rates: Integer): Integer; cdecl;
var
  i: Integer;
  k: Integer;
  x: Integer;
begin
  TWMPEQU.fdata.Data := Data;
  TWMPEQU.fdata.Bits := Bits;
  TWMPEQU.fdata.Rates := Rates;
  TWMPEQU.fdata.Samples := Samples;
  TWMPEQU.fdata.Channels := Channels;
  if((TWMPEQU.finfo.Enabled)) then begin
    for k := 0 to TWMPEQU.fdata.Channels - 1 do begin
      for i := 0 to Length(TWMPEQU.finfo.Bands) - 1 do begin
        TWMPEQU.feqz[k, i].Amp := (TWMPEQU.finfo.Preamp + TWMPEQU.finfo.Bands[i]) / 10;
        TWMPEQU.feqz[k, i].Freq := 35 * Power(2, 0.5 * i);
        TWMPEQU.feqz[k, i].Rate := TWMPEQU.fdata.Rates;
        TWMPEQU.feqz[k, i].Width := 0.5;
        for x := 0 to TWMPEQU.fdata.Samples - 1 do begin
          TWMPDSP.Samples[TWMPEQU.fdata, x, k] := TWMPEQU.feqz[k, i].Process(TWMPDSP.Samples[TWMPEQU.fdata, x, k]);
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

class function TWMPEQU.getInfo(): PInfo; cdecl;
begin
  Result := TWMPEQU.finfo;
end;

class function TWMPEQU.getData(): PData; cdecl;
begin
  Result := TWMPEQU.fdata;
end;

begin
end.
