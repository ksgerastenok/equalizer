unit
  WMPDSPMod;

interface

uses
  WMPDSPDecl;

function equInit(const tmod: PWMPDSPModule): Integer; cdecl;
procedure equQuit(const tmod: PWMPDSPModule); cdecl;
function equProcess(const tmod: PWMPDSPModule; const data: Pointer; const samples, bps, nch, srate: Integer): Integer; cdecl;
procedure equConfig(const tmod: PWMPDSPModule); cdecl;

implementation

uses
  WMPDSPEqz,
  WMPDSPForm;

function equInit(const tmod: PWMPDSPModule): Integer;
var
  f: file;
  i: Integer;
begin
  DSPEqz := TWMPDSPEqz.Create();
  try
    System.Assign(f, 'equalizer.cfg');
    System.ReSet(f, 1);
    System.BlockRead(f, DSPEqz.Info^, SizeOf(TEQInfo) * 1);
    System.Close(f);
  except
    DSPEqz.Info.preamp := 0;
    DSPEqz.Info.enabled := false;
    for i := 0 to Length(DSPEqz.Info.bands) - 1 do begin
      DSPEqz.Info.bands[i] := 0;
    end;
  end;
  CFGForm := TWMPDSPForm.CreateParented(0);
  Result := 0;
end;

procedure equQuit(const tmod: PWMPDSPModule);
var
  f: file;
  i: Integer;
begin
  CFGForm.Destroy();
  try
    System.Assign(f, 'equalizer.cfg');
    System.ReWrite(f, 1);
    System.BlockWrite(f, DSPEqz.Info^, SizeOf(TEQInfo) * 1);
    System.Close(f);
  except
    DSPEqz.Info.preamp := 0;
    DSPEqz.Info.enabled := false;
    for i := 0 to Length(DSPEqz.Info.bands) - 1 do begin
      DSPEqz.Info.bands[i] := 0;
    end;
  end;
  DSPEqz.Destroy();
end;

procedure equConfig(const tmod: PWMPDSPModule);
begin
  CFGForm.Show();
end;

function equProcess(const tmod: PWMPDSPModule; const data: Pointer; const samples, bps, nch, srate: Integer): Integer;
begin
  DSPEqz.Data.bps := bps;
  DSPEqz.Data.nch := nch;
  DSPEqz.Data.data := data;
  DSPEqz.Data.srate := srate;
  DSPEqz.Data.samples := samples;
  DSPEqz.Process();
  Result := samples;
end;

begin
end.
