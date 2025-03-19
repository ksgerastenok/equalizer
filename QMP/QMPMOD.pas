unit
  QMPMOD;

interface

uses
  QMPDCL,
  QMPEQU,
  QMPENH,
  QMPNRM,
  QMPBSS,
  QMPTRB;

type
  PQMPMOD = ^TQMPMOD;
  TQMPMOD = record
  private
    class function Plugin(const Which: Integer): PPlugin; cdecl; static;
  public
    class function Module(): PModule; cdecl; static;
  end;

implementation

class function TQMPMOD.Plugin(const Which: Integer): PPlugin; cdecl;
begin
  Result := nil;
  case (Which) of
    0: begin
      Result := TQMPEQU.Plugin();
    end;
    1: begin
      Result := TQMPENH.Plugin();
    end;
    2: begin
      Result := TQMPNRM.Plugin();
    end;
    3: begin
      Result := TQMPBSS.Plugin();
    end;
    4: begin
      Result := TQMPTRB.Plugin();
    end;
  end;
end;

class function TQMPMOD.Module(): PModule; cdecl;
begin
  Result := New(PModule);
  Result.Instance := $0000;
  Result.Version := $0050;
  Result.Plugin := TQMPMOD.Plugin;
end;

begin
end.
