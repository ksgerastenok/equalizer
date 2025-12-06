unit
  QMPNRM;

interface

uses
  QMPBQF,
  QMPRNG,
  QMPDSP,
  QMPDCL;

type
  TQMPNRM = record
  private
    class var finfo: TInfo;
    class var fdsp: TQMPDSP;
    class var frng: array[0..4] of TQMPRNG;
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

class function TQMPNRM.Plugin(): PPlugin; cdecl;
begin
  Result := New(PPlugin);
  Result.Description := 'Quinnware Normalizer v3.51';
  Result.Version := $0000;
  Result.Init := TQMPNRM.Init;
  Result.Quit := TQMPNRM.Quit;
  Result.Modify := TQMPNRM.Modify;
  Result.Update := TQMPNRM.Update;
end;

class function TQMPNRM.Init(const Flags: Integer): Integer; cdecl;
var
  k: Integer;
begin
  for k := 0 to Length(TQMPNRM.frng) - 1 do begin
    TQMPNRM.frng[k].Init(ftBand, btSlope, gtDb);
    TQMPNRM.frng[k].Amp := 20.0;
    TQMPNRM.frng[k].Freq := 640.0;
    TQMPNRM.frng[k].Width := 0.1;
  end;
  Result := 1;
end;

class procedure TQMPNRM.Quit(const Flags: Integer); cdecl;
var
  k: Integer;
begin
  for k := 0 to Length(TQMPNRM.frng) - 1 do begin
    TQMPNRM.frng[k].Amp := 0.0;
    TQMPNRM.frng[k].Freq := 0.0;
    TQMPNRM.frng[k].Width := 0.0;
    TQMPNRM.frng[k].Done();
  end;
end;

class function TQMPNRM.Modify(const Data: PData; const Latency: PInteger; const Flags: Integer): Integer; cdecl;
var
  k: LongWord;
  x: LongWord;
begin
  if (TQMPNRM.finfo.Enabled) then begin
    TQMPNRM.fdsp.Init(Data);
    for k := 0 to Data.Channels - 1 do begin
      TQMPNRM.frng[k].Rate := Data.Rates;
      for x := 0 to Data.Samples - 1 do begin
        TQMPNRM.fdsp.Data[k, x] := TQMPNRM.frng[k].Process(TQMPNRM.fdsp.Data[k, x]);
      end;
    end;
    TQMPNRM.fdsp.Done();
  end;
  Result := 1;
end;

class function TQMPNRM.Update(const Info: PInfo; const Flags: Integer): Integer; cdecl;
begin
  TQMPNRM.finfo.Enabled := Info.Enabled;
  TQMPNRM.finfo.Preamp := Info.Preamp;
  TQMPNRM.finfo.Bands := Info.Bands;
  Result := 1;
end;

begin
end.
