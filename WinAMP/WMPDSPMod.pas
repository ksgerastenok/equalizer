unit
  WMPDSPMod;

interface

uses
  WMPDSPDecl;

function equInit(const tmod: PWMPDSPModule): Integer; cdecl;
procedure equQuit(const tmod: PWMPDSPModule); cdecl;
function equProcess(const tmod: PWMPDSPModule; const data: Pointer; const samples: Integer; const bits: Integer; const channels: Integer; const rates: Integer): Integer; cdecl;
procedure equConfig(const tmod: PWMPDSPModule); cdecl;

implementation

uses
  WMPDSPEqz,
  WMPDSPForm;

function equInit(const tmod: PWMPDSPModule): Integer;
begin
  DSPEqz := TWMPDSPEqz.Create();
  CFGForm := TWMPDSPForm.Create(nil);
  Result := 0;
end;

procedure equQuit(const tmod: PWMPDSPModule);
begin
  CFGForm.Destroy();
  DSPEqz.Destroy();
end;

procedure equConfig(const tmod: PWMPDSPModule);
begin
  CFGForm.Show();
end;

function equProcess(const tmod: PWMPDSPModule; const data: Pointer; const samples: Integer; const bits: Integer; const channels: Integer; const rates: Integer): Integer;
begin
  DSPEqz.Process(data, samples, bits, channels, rates);
  Result := samples;
end;

begin
end.
