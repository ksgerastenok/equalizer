library
  QMPDSPEqu;

uses
  QMPDSPMod,
  QMPDSPDecl;

{$R *.res}

var
  DSPMod: TQMPDSPMod;

function Init(const Flags: Integer): Integer; cdecl;
begin
  DSPMod := TQMPDSPMod.Create();
  Result := 1;
end;

procedure Quit(const Flags: Integer); cdecl;
begin
  DSPMod.Destroy();
end;

function Update(const Info: PEQInfo; const Flags: Integer): Integer; cdecl;
begin
  DSPMod.Info.Bands := Info.Bands;
  DSPMod.Info.Preamp := Info.Preamp;
  DSPMod.Info.Enabled := Info.Enabled;
  Result := 1;
end;

function Modify(const Data: PWriteData; const Latency: PInteger; const Flags: Integer): Integer; cdecl;
begin
  DSPMod.Data.Data := Data.Data;
  DSPMod.Data.Bits := Data.Bits;
  DSPMod.Data.Rates := Data.Rates;
  DSPMod.Data.Samples := Data.Samples;
  DSPMod.Data.Channels := Data.Channels;
  DSPMod.Process();
  Result := 1;
end;

function Module(const Which: Integer): PQMPDSPPlugin; cdecl;
begin
  Result := nil;
  case (Which) of
    0: begin
      Result := New(PQMPDSPPlugin);
      if((not(Result = nil))) then begin
        Result.Version := $012D;
        Result.Description := 'Quinnware Equalizer v3.51';
        Result.Module.Init := Init;
        Result.Module.Quit := Quit;
        Result.Module.Update := Update;
        Result.Module.Modify := Modify;
      end;
    end;
    else begin
      if((not(Result = nil))) then begin
        Result.Version := $0000;
        Result.Description := nil;
        Result.Module.Init := nil;
        Result.Module.Quit := nil;
        Result.Module.Update := nil;
        Result.Module.Modify := nil;
      end;
      Dispose(Result);
    end;
  end;
end;

function QDSPModule(): PQMPDSPHeader; cdecl;
begin
  Result := New(PQMPDSPHeader);
  if((not(Result = nil))) then begin
    Result.Version := $50;
    Result.Instance := 0;
    Result.Module := Module;
  end;
end;

exports
  QDSPModule;

begin
end.
