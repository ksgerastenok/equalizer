unit
  QMPDSPMod;

interface

uses
  QMPDSPDecl;

function equInit(const flags: Integer): Integer; cdecl;
function equProcess(const data: PWriteData; const latency: PInteger; const flags: Integer): Integer; cdecl;
function equUpdate(const info: PEQInfo; const flags: Integer): Integer; cdecl;
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

function equUpdate(const info: PEQInfo; const flags: Integer): Integer;
begin
  DSPEqz.Info.bands := info.bands;
  DSPEqz.Info.preamp := info.preamp;
  DSPEqz.Info.enabled := info.enabled;
  Result := 1;
end;

function equProcess(const data: PWriteData; const latency: PInteger; const flags: Integer): Integer;
begin
  DSPEqz.Process(data.data, data.samples, data.bits, data.channels, data.rates);
  Result := 1;
end;

begin
end.
