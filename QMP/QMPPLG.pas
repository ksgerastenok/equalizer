unit
  QMPPLG;

interface

uses
  QMPDCL,
  QMPMOD;

type
  TQMPPLG = record
  private
    class function Init(const Flags: Integer): Integer; cdecl; static;
    class procedure Quit(const Flags: Integer); cdecl; static;
    class function Modify(const Data: PData; const Latency: Pointer; const Flags: Integer): Integer; cdecl; static;
    class function Update(const Info: PInfo; const Flags: Integer): Integer; cdecl; static;
  public
    class function Plugin(const Which: Integer): PPlugin; cdecl; static;
  end;

implementation

class function TQMPPLG.Plugin(const Which: Integer): PPlugin; cdecl;
begin
  case (Which) of
    0: begin
      Result := New(PPlugin);
    end;
    else begin
      Result := nil;
    end;
  end;
  if((not(Result = nil))) then begin
    Result.Version := $012D;
    Result.Description := 'Quinnware Equalizer v3.51';
    Result.Init := TQMPPLG.Init;
    Result.Quit := TQMPPLG.Quit;
    Result.Modify := TQMPPLG.Modify;
    Result.Update := TQMPPLG.Update;
  end;
end;

class function TQMPPLG.Init(const Flags: Integer): Integer; cdecl;
begin
  Result := 1;
end;

class procedure TQMPPLG.Quit(const Flags: Integer); cdecl;
begin
  TQMPMOD.Quit();
end;

class function TQMPPLG.Modify(const Data: PData; const Latency: Pointer; const Flags: Integer): Integer; cdecl;
begin
  TQMPMOD.Instance().Data.Data := Data.Data;
  TQMPMOD.Instance().Data.Bits := Data.Bits;
  TQMPMOD.Instance().Data.Rates := Data.Rates;
  TQMPMOD.Instance().Data.Samples := Data.Samples;
  TQMPMOD.Instance().Data.Channels := Data.Channels;
  TQMPMOD.Instance().Process();
  Result := 1;
end;

class function TQMPPLG.Update(const Info: PInfo; const Flags: Integer): Integer; cdecl;
begin
  TQMPMOD.Instance().Info.Bands := Info.Bands;
  TQMPMOD.Instance().Info.Preamp := Info.Preamp;
  TQMPMOD.Instance().Info.Enabled := Info.Enabled;
  Result := 1;
end;

begin
end.
