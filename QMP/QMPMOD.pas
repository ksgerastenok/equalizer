unit
  QMPMOD;

interface

uses
  QMPDCL,
  QMPEQU,
  QMPENH;

type
  TQMPMOD = record
  private
    class function Plugin(const Which: Integer): PPlugin; cdecl; static;
  public
    class function Module(): PModule; cdecl; static;
  end;

implementation

class function TQMPMOD.Plugin(const Which: Integer): PPlugin; cdecl;
begin
  case (Which) of
    0: begin
      Result := TQMPEQU.Plugin();
    end;
    1: begin
      Result := TQMPENH.Plugin();
    end;
    else begin
      Result := nil;
    end;
  end;
end;

class function TQMPMOD.Module(): PModule; cdecl;
begin
  Result := New(PModule);
  Result.Plugin := TQMPMOD.Plugin;
end;

begin
end.
