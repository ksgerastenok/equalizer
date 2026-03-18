unit
  WMPMOD;

interface

uses
  WMPDCL,
  WMPEQU;

type
  TWMPMOD = record
  private
    class function Plugin(const Which: Integer): PPlugin; cdecl; static;
  public
    class function Module(): PModule; cdecl; static;
  end;

implementation

class function TWMPMOD.Plugin(const Which: Integer): PPlugin; cdecl;
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

class function TWMPMOD.Module(): PModule; cdecl;
begin
  Result := New(PModule);
  Result.Version := $0020;
  Result.Description := 'Nullsoft Equalizer Plugin v3.51';
  Result.Plugin := TWMPMOD.Plugin;
end;

begin
end.
