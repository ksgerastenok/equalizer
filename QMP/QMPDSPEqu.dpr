library
  QMPDSPEqu;

uses
  QMPDSPMod,
  QMPDSPDecl;

{$R *.res}

function equInit(const flags: Integer): Integer; cdecl;
begin
  Result := 1;
end;

procedure equQuit(const flags: Integer); cdecl;
begin
end;

function equUpdate(const info: PEQInfo; const flags: Integer): Integer; cdecl;
begin
  DSPMod.Info.bands := info.bands;
  DSPMod.Info.preamp := info.preamp;
  DSPMod.Info.enabled := info.enabled;
  Result := 1;
end;

function equProcess(const data: PWriteData; const latency: PInteger; const flags: Integer): Integer; cdecl;
begin
  DSPMod.Data.data := data.data;
  DSPMod.Data.bits := data.bits;
  DSPMod.Data.rates := data.rates;
  DSPMod.Data.samples := data.samples;
  DSPMod.Data.channels := data.channels;
  DSPMod.Process();
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
        Result.toModule.Quit := equQuit;
        Result.toModule.Update := equUpdate;
        Result.toModule.Modify := equProcess;
      end;
    end;
    else begin
      if((not(Result = nil))) then begin
        Result.version := $0000;
        Result.description := nil;
        Result.toModule.Init := nil;
        Result.toModule.Quit := nil;
        Result.toModule.Update := nil;
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

end.
