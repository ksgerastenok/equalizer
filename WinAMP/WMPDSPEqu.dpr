library
  WMPDSPEqu;

uses
  WMPDSPMod,
  WMPDSPForm,
  WMPDSPDecl;

{$R *.res}

function equInit(const tmod: PWMPDSPModule): Integer; cdecl;
begin
  Result := 0;
end;

procedure equQuit(const tmod: PWMPDSPModule); cdecl;
begin
end;

procedure equConfig(const tmod: PWMPDSPModule); cdecl;
begin
  CFGForm.Show();
end;

function equProcess(const tmod: PWMPDSPModule; const data: Pointer; const samples: Integer; const bits: Integer; const channels: Integer; const rates: Integer): Integer; cdecl;
begin
  DSPMod.Data.data := data;
  DSPMod.Data.bits := bits;
  DSPMod.Data.rates := rates;
  DSPMod.Data.samples := samples;
  DSPMod.Data.channels := channels;
  DSPMod.Process();
  Result := samples;
end;

function getModule(const which: Integer): PWMPDSPModule; cdecl;
begin
  Result := nil;
  case (which) of
    0: begin
      New(Result);
      if((not(Result = nil))) then begin
        Result.instance := 0;
        Result.description := 'Equalizer';
        Result.Init := equInit;
        Result.Quit := equQuit;
        Result.Config := equConfig;
        Result.Modify := equProcess;
      end;
    end;
    else begin
      if((not(Result = nil))) then begin
        Result.instance := 0;
        Result.description := nil;
        Result.Init := nil;
        Result.Quit := nil;
        Result.Config := nil;
        Result.Modify := nil;
      end;
      Dispose(Result);
    end;
  end;
end;

function winampDSPGetHeader2(): PWMPDSPHeader; cdecl;
begin
  New(Result);
  if((not(Result = nil))) then begin
    Result.version := $20;
    Result.description := 'Nullsoft Equalizer Plugin v3.51';
    Result.getModule := getModule;
  end;
end;

exports
  winampDSPGetHeader2;

begin
end.
