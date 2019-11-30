unit
  QMPDSPMod;

interface

uses
  QMPDSPDecl;

function equInit(const flags: Integer): Integer; cdecl;
function equProcess(const writeData: PWriteData; const latency: PInteger; const flags: Integer): Integer; cdecl;
function equEQUpdate(const EQInfo: PEQInfo; const flags: Integer): Integer; cdecl;
procedure equShutdown(const flags: Integer); cdecl;

implementation

uses
  QMPDSPEqz;

function equInit(const flags: Integer): Integer;
begin
  DSPEqz := TQMPDSPEqz.Create();
  Result := 1;
end;

procedure equShutdown(const flags: Integer);
begin
  DSPEqz.Destroy();
end;

function equEQUpdate(const EQInfo: PEQInfo; const flags: Integer): Integer;
begin
  DSPEqz.Info.bands := EQInfo.bands;
  DSPEqz.Info.preamp := EQInfo.preamp;
  DSPEqz.Info.enabled := EQInfo.enabled;
  Result := 1;
end;

function equProcess(const writeData: PWriteData; const latency: PInteger; const flags: Integer): Integer;
begin
  DSPEqz.Data.bps := writeData.bps;
  DSPEqz.Data.nch := writeData.nch;
  DSPEqz.Data.data := writeData.data;
  DSPEqz.Data.srate := writeData.srate;
  DSPEqz.Data.samples := writeData.samples;
  DSPEqz.Process();
  Result := 1;
end;

begin
end.
