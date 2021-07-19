unit
  WMPPLG;

interface

uses
  WMPDCL,
  WMPMOD,
  WMPFRM;

type
  TWMPPLG = record
  private
    class function Init(const Module: PPlugin): Integer; cdecl; static;
    class procedure Quit(const Module: PPlugin); cdecl; static;
    class function Modify(const Module: PPlugin; const Data: Pointer; const Samples: Integer; const Bits: Integer; const Channels: Integer; const Rates: Integer): Integer; cdecl; static;
    class procedure Config(const Module: PPlugin); cdecl; static;
  public
    class function Plugin(const Which: Integer): PPlugin; cdecl; static;
  end;

implementation

class function TWMPPLG.Plugin(const Which: Integer): PPlugin; cdecl;
begin
  case (Which) of
    0: begin
      Result := New(PPlugin);
    end;
    else begin
      Result := nil;
    end;
  end;
  if((not(Result = nil))) then begin
    Result.Instance := $0000;
    Result.Description := 'Nullsoft Equalizer Plugin v3.51';
    Result.Init := TWMPPLG.Init;
    Result.Quit := TWMPPLG.Quit;
    Result.Config := TWMPPLG.Config;
    Result.Modify := TWMPPLG.Modify;
  end;
end;

class function TWMPPLG.Init(const Module: PPlugin): Integer; cdecl;
var
  f: file;
  i: LongWord;
begin
  try
    System.Assign(f, 'equalizer.cfg');
    System.ReSet(f, 1);
    System.BlockRead(f, TWMPMOD.Instance().Info^, SizeOf(TInfo) * 1);
    System.Close(f);
  except
    TWMPMOD.Instance().Info.Preamp := 0;
    TWMPMOD.Instance().Info.Enabled := False;
    for i := 0 to Length(TWMPMOD.Instance().Info.Bands) - 1 do begin
      TWMPMOD.Instance().Info.Bands[i] := 0;
    end;
  end;
  TWMPFRM.Instance().Hide();
  Result := 0;
end;

class procedure TWMPPLG.Quit(const Module: PPlugin); cdecl;
var
  f: file;
  i: LongWord;
begin
  try
    System.Assign(f, 'equalizer.cfg');
    System.ReWrite(f, 1);
    System.BlockWrite(f, TWMPMOD.Instance().Info^, SizeOf(TInfo) * 1);
    System.Close(f);
  except
    TWMPMOD.Instance().Info.Preamp := 0;
    TWMPMOD.Instance().Info.Enabled := False;
    for i := 0 to Length(TWMPMOD.Instance().Info.Bands) - 1 do begin
      TWMPMOD.Instance().Info.Bands[i] := 0;
    end;
  end;
  TWMPFRM.Quit();
  TWMPMOD.Quit();
end;

class function TWMPPLG.Modify(const Module: PPlugin; const Data: Pointer; const Samples: Integer; const Bits: Integer; const Channels: Integer; const Rates: Integer): Integer; cdecl;
begin
  TWMPMOD.Instance().Data.Data := Data;
  TWMPMOD.Instance().Data.Bits := Bits;
  TWMPMOD.Instance().Data.Rates := Rates;
  TWMPMOD.Instance().Data.Samples := Samples;
  TWMPMOD.Instance().Data.Channels := Channels;
  TWMPMOD.Instance().Process();
  Result := Samples;
end;

class procedure TWMPPLG.Config(const Module: PPlugin); cdecl;
begin
  TWMPFRM.Instance().Show();
end;

begin
end.
