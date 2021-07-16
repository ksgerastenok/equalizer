library
  QMPDSPEQU;

uses
  QMPDSPMOD,
  QMPDSPDCL;

{$R *.res}

function Init(const Flags: Integer): Integer; cdecl;
begin
  Result := 1;
end;

procedure Quit(const Flags: Integer); cdecl;
begin
end;

function Modify(const Data: PWriteData; const Latency: PInteger; const Flags: Integer): Integer; cdecl;
begin
  TQMPDSPMOD.Instance().Data.Data := Data.Data;
  TQMPDSPMOD.Instance().Data.Bits := Data.Bits;
  TQMPDSPMOD.Instance().Data.Rates := Data.Rates;
  TQMPDSPMOD.Instance().Data.Samples := Data.Samples;
  TQMPDSPMOD.Instance().Data.Channels := Data.Channels;
  TQMPDSPMOD.Instance().Process();
  Result := 1;
end;

function Update(const Info: PEQInfo; const Flags: Integer): Integer; cdecl;
begin
  TQMPDSPMOD.Instance().Info.Bands := Info.Bands;
  TQMPDSPMOD.Instance().Info.Preamp := Info.Preamp;
  TQMPDSPMOD.Instance().Info.Enabled := Info.Enabled;
  Result := 1;
end;

function Module(const Which: Integer): PQMPDSPPlugin; cdecl;
begin
  Result := nil;
  case (Which) of
    0: begin
      Result := New(PQMPDSPPlugin);
      if((not(Result = nil))) then begin
        Result.Version := $012D;
        Result.Description := 'Quinnware Equalizer v3.51';
        Result.Module.Init := Init;
        Result.Module.Quit := Quit;
        Result.Module.Update := Update;
        Result.Module.Modify := Modify;
      end;
    end;
    else begin
      if((not(Result = nil))) then begin
        Result.Version := $0000;
        Result.Description := nil;
        Result.Module.Init := nil;
        Result.Module.Quit := nil;
        Result.Module.Update := nil;
        Result.Module.Modify := nil;
      end;
      Dispose(Result);
    end;
  end;
end;

function QDSPModule(): PQMPDSPHeader; cdecl;
begin
  Result := New(PQMPDSPHeader);
  if((not(Result = nil))) then begin
    Result.Version := $0050;
    Result.Instance := $0000;
    Result.Module := Module;
  end;
end;

exports
  QDSPModule;

end.
