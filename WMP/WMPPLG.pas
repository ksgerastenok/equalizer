library
  WMPPLG;

uses
  WMPDCL,
  WMPMOD,
  Interfaces;

function winampDSPGetHeader2(): PModule; cdecl;
begin
  Result := TWMPMOD.Module();
end;

exports
  winampDSPGetHeader2;

begin
end.
