library
  WMPDSPEQU;

{$R *.res}

uses
  WMPDSPMOD,
  WMPDSPDCL,
  WMPDSPFRM;

function Init(const Module: PPlugin): Integer; cdecl;
var
  f: file;
  i: LongWord;
begin
  try
    System.Assign(f, 'equalizer.cfg');
    System.ReSet(f, 1);
    System.BlockRead(f, TWMPDSPMOD.Instance().Info^, SizeOf(TInfo) * 1);
    System.Close(f);
  except
    TWMPDSPMOD.Instance().Info.Preamp := 0;
    TWMPDSPMOD.Instance().Info.Enabled := False;
    for i := 0 to Length(TWMPDSPMOD.Instance().Info.Bands) - 1 do begin
      TWMPDSPMOD.Instance().Info.Bands[i] := 0;
    end;
  end;
  TWMPDSPFRM.Instance().Hide();
  Result := 0;
end;

procedure Quit(const Module: PPlugin); cdecl;
var
  f: file;
  i: LongWord;
begin
  try
    System.Assign(f, 'equalizer.cfg');
    System.ReWrite(f, 1);
    System.BlockWrite(f, TWMPDSPMOD.Instance().Info^, SizeOf(TInfo) * 1);
    System.Close(f);
  except
    TWMPDSPMOD.Instance().Info.Preamp := 0;
    TWMPDSPMOD.Instance().Info.Enabled := False;
    for i := 0 to Length(TWMPDSPMOD.Instance().Info.Bands) - 1 do begin
      TWMPDSPMOD.Instance().Info.Bands[i] := 0;
    end;
  end;
  TWMPDSPFRM.Quit();
  TWMPDSPMOD.Quit();
end;

function Modify(const Module: PPlugin; const Data: Pointer; const Samples: Integer; const Bits: Integer; const Channels: Integer; const Rates: Integer): Integer; cdecl;
begin
  TWMPDSPMOD.Instance().Data.Data := Data;
  TWMPDSPMOD.Instance().Data.Bits := Bits;
  TWMPDSPMOD.Instance().Data.Rates := Rates;
  TWMPDSPMOD.Instance().Data.Samples := Samples;
  TWMPDSPMOD.Instance().Data.Channels := Channels;
  TWMPDSPMOD.Instance().Process();
  Result := Samples;
end;

procedure Config(const Module: PPlugin); cdecl;
begin
  TWMPDSPFRM.Instance().Show();
end;

function Plugin(const Which: Integer): PPlugin; cdecl;
begin
  Result := nil;
  case (Which) of
    0: begin
      Result := New(PPlugin);
      if((not(Result = nil))) then begin
        Result.Instance := $0000;
        Result.Description := 'Nullsoft Equalizer Plugin v3.51';
        Result.Init := Init;
        Result.Quit := Quit;
        Result.Config := Config;
        Result.Modify := Modify;
      end;
    end;
    else begin
      if((not(Result = nil))) then begin
        Result.Instance := $0000;
        Result.Description := nil;
        Result.Init := nil;
        Result.Quit := nil;
        Result.Config := nil;
        Result.Modify := nil;
      end;
      Dispose(Result);
    end;
  end;
end;

function winampDSPGetHeader2(): PModule; cdecl;
begin
  Result := New(PModule);
  if((not(Result = nil))) then begin
    Result.Version := $0020;
    Result.Plugin := Plugin;
  end;
end;

exports
  winampDSPGetHeader2;

begin
end.

