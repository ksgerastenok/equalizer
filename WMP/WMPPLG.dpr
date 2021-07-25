library
  WMPPLG;

{$R *.res}

uses
  WMPDCL,
  WMPEQU;

function Plugin(const Which: Integer): PPlugin; cdecl;
begin
  case (Which) of
    0: begin
      Result := TWMPEQU.Plugin();
    end;
    else begin
      Result := nil;
    end;
  end;
end;

function winampDSPGetHeader2(): PModule; cdecl;
begin
  Result := New(PModule);
  if((not(Result = nil))) then begin
    Result.Description := 'Nullsoft Equalizer Plugin v3.51';
    Result.Version := $0020;
    Result.Plugin := Plugin;
  end;
end;

exports
  winampDSPGetHeader2;

begin
end.
