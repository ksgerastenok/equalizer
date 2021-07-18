library
  QMPDSPEQU;

{$R *.res}

uses
  QMPDSPMOD,
  QMPDSPDCL;

function Init(const Flags: Integer): Integer; cdecl;
begin
  Result := 1;
end;

procedure Quit(const Flags: Integer); cdecl;
begin
  TQMPDSPMOD.Quit();
end;

function Modify(const Data: PData; const Latency: Pointer; const Flags: Integer): Integer; cdecl;
begin
  TQMPDSPMOD.Instance().Data.Data := Data.Data;
  TQMPDSPMOD.Instance().Data.Bits := Data.Bits;
  TQMPDSPMOD.Instance().Data.Rates := Data.Rates;
  TQMPDSPMOD.Instance().Data.Samples := Data.Samples;
  TQMPDSPMOD.Instance().Data.Channels := Data.Channels;
  TQMPDSPMOD.Instance().Process();
  Result := 1;
end;

function Update(const Info: PInfo; const Flags: Integer): Integer; cdecl;
begin
  TQMPDSPMOD.Instance().Info.Bands := Info.Bands;
  TQMPDSPMOD.Instance().Info.Preamp := Info.Preamp;
  TQMPDSPMOD.Instance().Info.Enabled := Info.Enabled;
  Result := 1;
end;

function Plugin(const Which: Integer): PPlugin; cdecl;
begin
  Result := nil;
  case (Which) of
    0: begin
      Result := New(PPlugin);
      if((not(Result = nil))) then begin
        Result.Version := $012D;
        Result.Description := 'Quinnware Equalizer v3.51';
        Result.Init := Init;
        Result.Quit := Quit;
        Result.Update := Update;
        Result.Modify := Modify;
      end;
    end;
    else begin
      if((not(Result = nil))) then begin
        Result.Version := $0000;
        Result.Description := nil;
        Result.Init := nil;
        Result.Quit := nil;
        Result.Update := nil;
        Result.Modify := nil;
      end;
      Dispose(Result);
    end;
  end;
end;

function QDSPModule(): PModule; cdecl;
begin
  Result := New(PModule);
  if((not(Result = nil))) then begin
    Result.Version := $0050;
    Result.Plugin := Plugin;
  end;
end;

exports
  QDSPModule;

begin
end.

