library
  WMPEQU;

{$R *.res}

uses
  WMPDCL,
  WMPPLG;

function winampDSPGetHeader2(): PModule; cdecl;
begin
  Result := New(PModule);
  if((not(Result = nil))) then begin
    Result.Description := 'Nullsoft Equalizer Plugin v3.51';
    Result.Version := $0020;
    Result.Plugin := TWMPPLG.Plugin;
  end;
end;

exports
  winampDSPGetHeader2;

begin
end.
