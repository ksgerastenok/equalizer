library
  QMPPLG;

uses
  QMPDCL,
  QMPMOD;

function QDSPModule(): PModule; cdecl;
begin
  Result := TQMPMOD.Module();
end;

exports
  QDSPModule;

begin
end.
