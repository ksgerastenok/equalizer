unit
  QMPVOL;

interface

uses
  QMPNRM,
  QMPDCL;

type
  PQMPVOL = ^TQMPVOL;
  TQMPVOL = record
  private
    class var fnrm: TQMPNRM;
    class function Init(const Flags: Integer): Integer; cdecl; static;
    class procedure Quit(const Flags: Integer); cdecl; static;
    class function Modify(const Data: PData; const Latency: PInteger; const Flags: Integer): Integer; cdecl; static;
    class function Update(const Info: PInfo; const Flags: Integer): Integer; cdecl; static;
  public
    class function Plugin(): PPlugin; cdecl; static;
  end;

implementation

class function TQMPVOL.Plugin(): PPlugin; cdecl;
begin
  Result := New(PPlugin);
  Result.Description := 'Quinnware Normalizer v3.51';
  Result.Version := $0000;
  Result.Init := TQMPVOL.Init;
  Result.Quit := TQMPVOL.Quit;
  Result.Modify := TQMPVOL.Modify;
  Result.Update := TQMPVOL.Update;
end;

class function TQMPVOL.Init(const Flags: Integer): Integer; cdecl;
begin
  TQMPVOL.fnrm.Init();
  Result := 1;
end;

class procedure TQMPVOL.Quit(const Flags: Integer); cdecl;
begin
  TQMPVOL.fnrm.Done();
end;

class function TQMPVOL.Modify(const Data: PData; const Latency: PInteger; const Flags: Integer): Integer; cdecl;
begin
  TQMPVOL.fnrm.Process(Data^);
  Result := 1;
end;

class function TQMPVOL.Update(const Info: PInfo; const Flags: Integer): Integer; cdecl;
begin
  TQMPVOL.fnrm.Update(Info^);
  Result := 1;
end;

begin
end.
