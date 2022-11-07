unit
  QMPEQZ;

interface

uses
  QMPEQU,
  QMPDCL;

type
  PQMPEQZ = ^TQMPEQZ;
  TQMPEQZ = record
  private
    class var fequ: TQMPEQU;
    class function Init(const Flags: Integer): Integer; cdecl; static;
    class function Modify(const Data: PData; const Latency: PInteger; const Flags: Integer): Integer; cdecl; static;
    class function Update(const Info: PInfo; const Flags: Integer): Integer; cdecl; static;
    class procedure Quit(const Flags: Integer); cdecl; static;
  public
    class function Plugin(): PPlugin; cdecl; static;
  end;

implementation

class function TQMPEQZ.Plugin(): PPlugin; cdecl;
begin
  Result := New(PPlugin);
  Result.Description := 'Quinnware Equalizer v3.51';
  Result.Version := $0000;
  Result.Init := TQMPEQZ.Init;
  Result.Quit := TQMPEQZ.Quit;
  Result.Modify := TQMPEQZ.Modify;
  Result.Update := TQMPEQZ.Update;
end;

class function TQMPEQZ.Init(const Flags: Integer): Integer; cdecl;
begin
  TQMPEQZ.fequ.Init();
  Result := 1;
end;

class procedure TQMPEQZ.Quit(const Flags: Integer); cdecl;
begin
  TQMPEQZ.fequ.Done();
end;

class function TQMPEQZ.Modify(const Data: PData; const Latency: PInteger; const Flags: Integer): Integer; cdecl;
begin
  TQMPEQZ.fequ.Data.Data := Data.Data;
  TQMPEQZ.fequ.Data.Bits := Data.Bits;
  TQMPEQZ.fequ.Data.Rates := Data.Rates;
  TQMPEQZ.fequ.Data.Samples := Data.Samples;
  TQMPEQZ.fequ.Data.Channels := Data.Channels;
  TQMPEQZ.fequ.Process();
  Result := 1;
end;

class function TQMPEQZ.Update(const Info: PInfo; const Flags: Integer): Integer; cdecl;
begin
  TQMPEQZ.fequ.Info.Enabled := Info.Enabled;
  TQMPEQZ.fequ.Info.Preamp := Info.Preamp;
  TQMPEQZ.fequ.Info.Bands := Info.Bands;
  Result := 1;
end;

begin
end.
