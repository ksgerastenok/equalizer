library
  QMPDSPEqu;

uses
  XPMan,
  QMPDSPMod,
  QMPDSPDecl;

{$R *.res}

function getModule(const which: Integer): PQMPDSPPlugin; cdecl;
begin
  Result := nil;
  case (which) of
    0: begin
      New(Result);
      if((not(Result = nil))) then begin
        Result.version := $012D;
        Result.description := 'Quinnware SuperEqu v3.51';
        Result.toModule.Init := equInit;
        Result.toModule.EQUpdate := equEQUpdate;
        Result.toModule.Shutdown := equShutdown;
        Result.toModule.ModifyAudio := equProcess;
      end;
    end;
    else begin
      if((not(Result = nil))) then begin
        Result.version := $0000;
        Result.description := nil;
        Result.toModule.Init := nil;
        Result.toModule.EQUpdate := nil;
        Result.toModule.Shutdown := nil;
        Result.toModule.ModifyAudio := nil;
      end;
      Dispose(Result);
    end;
  end;
end;

function QDSPModule(): PQMPDSPHeader; cdecl;
begin
  New(Result);
  if((not(Result = nil))) then begin
    Result.version := $50;
    Result.instance := 0;
    Result.getModule := getModule;
  end;
end;

exports
  QDSPModule;

begin
end.
