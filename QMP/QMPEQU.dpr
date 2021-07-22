library
  QMPEQU;

{$R *.res}

uses
  QMPDCL,
  QMPPLG;

function QDSPModule(): PModule; cdecl;
begin
  Result := New(PModule);
  if((not(Result = nil))) then begin
    Result.Instance := $0000;
    Result.Version := $0050;
    Result.Plugin := TQMPPLG.Plugin;
  end;
end;

exports
  QDSPModule;

begin
end.
