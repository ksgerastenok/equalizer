unit
  WMPMOD;

interface

uses
  WMPDCL,
  WMPNRM;

type
  PWMPMOD = ^TWMPMOD;
  TWMPMOD = record
  private
    class function Plugin(const Which: Integer): PPlugin; cdecl; static;
  public
    class function Module(): PModule; cdecl; static;
  end;

implementation

class function TWMPMOD.Plugin(const Which: Integer): PPlugin; cdecl;
begin
  Result := nil;
  case (Which) of
    0: begin
      Result := TWMPNRM.Plugin();
    end;
  end;
end;

class function TWMPMOD.Module(): PModule; cdecl;
begin
  Result := New(PModule);
  Result.Description := 'Nullsoft Normalizer Plugin v3.51';
  Result.Version := $0020;
  Result.Plugin := TWMPMOD.Plugin;
end;

begin
end.
