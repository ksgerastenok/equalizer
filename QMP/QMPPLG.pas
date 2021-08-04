library
  QMPPLG;

uses
  QMPDCL,
  QMPEQU;

function Plugin(const Which: Integer): PPlugin; cdecl;
begin
  case (Which) of
    0: begin
      Result := TQMPEQU.Plugin();
    end;
    else begin
      Result := nil;
    end;
  end;
end;

function QDSPModule(): PModule; cdecl;
begin
  Result := New(PModule);
  Result^.Instance := $0000;
  Result^.Version := $0050;
  Result^.Plugin := @Plugin;
end;

exports
  QDSPModule;

begin
end.
