library
  WMPPLG;

uses
  WMPDCL,
  WMPMOD;

function winampDSPGetHeader2(): PModule;
begin
  Result := TWMPMOD.Module();
end;

exports
  winampDSPGetHeader2;

begin
end.
