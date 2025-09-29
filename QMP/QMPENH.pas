unit
  QMPENH;

interface

uses
  QMPDSP,
  QMPDCL;

type
  PQMPENH = ^TQMPENH;
  TQMPENH = record
  private
    class var finfo: TInfo;
    class var fwidth: Double;
    class var fdsp: TQMPDSP;
    class function Init(const Flags: Integer): Integer; cdecl; static;
    class procedure Quit(const Flags: Integer); cdecl; static;
    class function Modify(const Data: PData; const Latency: PInteger; const Flags: Integer): Integer; cdecl; static;
    class function Update(const Info: PInfo; const Flags: Integer): Integer; cdecl; static;
  public
    class function Plugin(): PPlugin; cdecl; static;
  end;

implementation

uses
  Math;

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
  TQMPENH.fwidth := Power(10, 5.0 / 20);
  Result := 1;
end;

class procedure TQMPENH.Quit(const Flags: Integer); cdecl;
begin
  TQMPENH.fwidth := Power(10, 0.0 / 20);
end;

class function TQMPENH.Modify(const Data: PData; const Latency: PInteger; const Flags: Integer): Integer; cdecl;
var
  k: LongWord;
  x: LongWord;
  f: Double;
begin
  if (TQMPENH.finfo.Enabled) then begin
    TQMPENH.fdsp.Init(Data);
    for x := 0 to Data.Samples - 1 do begin
      f := 0;
      for k := 0 to Data.Channels - 1 do begin
        f := f + (TQMPENH.fdsp.Buffer[x, k] - f) / (k + 1);
      end;
      for k := 0 to Data.Channels - 1 do begin
        TQMPENH.fdsp.Buffer[x, k] := f + TQMPENH.fwidth * (TQMPENH.fdsp.Buffer[x, k] - f);
      end;
    end;
    TQMPENH.fdsp.Done();
  end;
  Result := 1;
end;

class function TQMPENH.Update(const Info: PInfo; const Flags: Integer): Integer; cdecl;
begin
  TQMPENH.finfo.Enabled := Info.Enabled;
  TQMPENH.finfo.Preamp := Info.Preamp;
  TQMPENH.finfo.Bands := Info.Bands;
  Result := 1;
end;

begin
end.
