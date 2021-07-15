library
  WMPDSPEqu;

uses
  WMPDSPMod,
  WMPDSPForm,
  WMPDSPDecl;

{$R *.res}

var
  CFGForm: TWMPDSPForm;

function Init(const Module: PWMPDSPModule): Integer; cdecl;
begin
  CFGForm := TWMPDSPForm.Create(nil);
  Result := 0;
end;

procedure Quit(const Module: PWMPDSPModule); cdecl;
begin
  CFGForm.Destroy();
end;

procedure Config(const Module: PWMPDSPModule); cdecl;
begin
  CFGForm.Show();
end;

function Modify(const Module: PWMPDSPModule; const Data: Pointer; const Samples: Integer; const Bits: Integer; const Channels: Integer; const Rates: Integer): Integer; cdecl;
begin
  CFGForm.Process(Data, Samples, Bits, Channels, Rates);
  Result := Samples;
end;

function Module(const Which: Integer): PWMPDSPModule; cdecl;
begin
  Result := nil;
  case (Which) of
    0: begin
      Result := New(PWMPDSPModule);
      if((not(Result = nil))) then begin
        Result.Instance := 0;
        Result.Description := 'Equalizer';
        Result.Init := Init;
        Result.Quit := Quit;
        Result.Config := Config;
        Result.Modify := Modify;
      end;
    end;
    else begin
      if((not(Result = nil))) then begin
        Result.Instance := 0;
        Result.Description := nil;
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
  Result := New(PWMPDSPHeader);
  if((not(Result = nil))) then begin
    Result.Version := $20;
    Result.Description := 'Nullsoft Equalizer Plugin v3.51';
    Result.Module := Module;
  end;
end;

exports
  winampDSPGetHeader2;

begin
end.
