unit
  QMPENH;

interface

uses
  QMPDCL,
  QMPEXT;

type
  PQMPENH = ^TQMPENH;
  TQMPENH = record
  private
    class var fext: TQMPEXT;
    class function Init(const Flags: Integer): Integer; cdecl; static;
    class function Modify(const Data: PData; const Latency: PInteger; const Flags: Integer): Integer; cdecl; static;
    class function Update(const Info: PInfo; const Flags: Integer): Integer; cdecl; static;
    class procedure Quit(const Flags: Integer); cdecl; static;
  public
    class function Plugin(): PPlugin; cdecl; static;
  end;

implementation

class function TQMPENH.Plugin(): PPlugin; cdecl;
begin
  Result := New(PPlugin);
  Result.Description := 'Quinnware Enhancer v3.51';
  Result.Version := $0000;
  Result.Init := TQMPENH.Init;
  Result.Quit := TQMPENH.Quit;
  Result.Modify := TQMPENH.Modify;
  Result.Update := TQMPENH.Update;
end;

class function TQMPENH.Init(const Flags: Integer): Integer; cdecl;
begin
  TQMPENH.fext.Init(7.5);
  Result := 1;
end;

class procedure TQMPENH.Quit(const Flags: Integer); cdecl;
begin
  TQMPENH.fext.Done();
end;

class function TQMPENH.Modify(const Data: PData; const Latency: PInteger; const Flags: Integer): Integer; cdecl;
begin
  TQMPENH.fext.Data.Data := Data.Data;
  TQMPENH.fext.Data.Bits := Data.Bits;
  TQMPENH.fext.Data.Rates := Data.Rates;
  TQMPENH.fext.Data.Samples := Data.Samples;
  TQMPENH.fext.Data.Channels := Data.Channels;
  TQMPENH.fext.Process();
  Result := 1;
end;

class function TQMPENH.Update(const Info: PInfo; const Flags: Integer): Integer; cdecl;
begin
  TQMPENH.fext.Info.Enabled := Info.Enabled;
  TQMPENH.fext.Info.Preamp := Info.Preamp;
  TQMPENH.fext.Info.Bands := Info.Bands;
  Result := 1;
end;

begin
end.
