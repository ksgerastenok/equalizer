library
  WMPDSPEqu;

uses
  WMPDSPMod,
  WMPDSPDecl;

{$R *.res}

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
