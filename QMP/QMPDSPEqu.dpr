library
  QMPDSPEqu;

uses
  QMPDSPEqz,
  QMPDSPDecl;

{$R *.res}

function equInit(const flags: Integer): Integer; cdecl;
begin
  DSPEqz := TQMPDSPEqz.Create();
  Result := 1;
end;

procedure equShutdown(const flags: Integer); cdecl;
begin
  DSPEqz.Destroy();
end;

function equUpdate(const info: PEQInfo; const flags: Integer): Integer; cdecl;
begin
  DSPEqz.Info.bands := info.bands;
  DSPEqz.Info.preamp := info.preamp;
  DSPEqz.Info.enabled := info.enabled;
  Result := 1;
end;

function equProcess(const data: PWriteData; const latency: PInteger; const flags: Integer): Integer; cdecl;
begin
  DSPEqz.Data.data := data.data;
  DSPEqz.Data.bits := data.bits;
  DSPEqz.Data.rates := data.rates;
  DSPEqz.Data.samples := data.samples;
  DSPEqz.Data.channels := data.channels;
  DSPEqz.Process();
  Result := 1;
end;

function getModule(const which: Integer): PQMPDSPPlugin; cdecl;
begin
  Result := nil;
  case (which) of
    0: begin
      New(Result);
      if((not(Result = nil))) then begin
        Result.version := $012D;
        Result.description := 'Quinnware Equalizer v3.51';
        Result.toModule.Init := equInit;
        Result.toModule.Update := equUpdate;
        Result.toModule.Shutdown := equShutdown;
        Result.toModule.Modify := equProcess;
      end;
    end;
    else begin
      if((not(Result = nil))) then begin
        Result.version := $0000;
        Result.description := nil;
        Result.toModule.Init := nil;
        Result.toModule.Update := nil;
        Result.toModule.Shutdown := nil;
        Result.toModule.Modify := nil;
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
