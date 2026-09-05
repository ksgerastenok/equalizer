unit
  QMPEXT;

interface

uses
  QMPNRM,
  QMPDSP,
  QMPDCL;

type
  TQMPEXT = record
  private
    class var finfo: TInfo;
    class var fdsp: TQMPDSP;
    class var fnrm: array[0..4] of TQMPNRM;
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

class function TQMPEXT.Plugin(): PPlugin; cdecl;
begin
  Result := New(PPlugin);
  Result.Description := 'Quinnware Extra v3.51';
  Result.Init := TQMPEXT.Init;
  Result.Quit := TQMPEXT.Quit;
  Result.Modify := TQMPEXT.Modify;
  Result.Update := TQMPEXT.Update;
end;

class function TQMPEXT.Init(const Flags: Integer): Integer; cdecl;
var
  k: LongWord;
begin
  for k := 0 to Length(TQMPEXT.fnrm) - 1 do begin
    TQMPEXT.fnrm[k].Init(QMPNRM.ttABS, QMPNRM.gtDb);
  end;
  Result := 1;
end;

class procedure TQMPEXT.Quit(const Flags: Integer); cdecl;
var
  k: LongWord;
begin
  for k := 0 to Length(TQMPEXT.fnrm) - 1 do begin
    TQMPEXT.fnrm[k].Done();
  end;
end;

class function TQMPEXT.Modify(const Data: PData; const Latency: PInteger; const Flags: Integer): Integer; cdecl;
var
  k: LongWord;
  x: LongWord;
  v: Double;
  s: Double;
begin
  if (TQMPEXT.finfo.Enabled) then begin
    for k := 0 to Length(TQMPEXT.fnrm) - 1 do begin
      TQMPEXT.fnrm[k].Amp := 20.0;
      TQMPEXT.fnrm[k].Attack := 5.0;
      TQMPEXT.fnrm[k].Release := 0.5;
      TQMPEXT.fnrm[k].Rate := Data.Rates;
    end;
    TQMPEXT.fdsp.Init(Data);
    for x := 0 to Data.Samples - 1 do begin
      s := 0.0;
      for k := 0 to Data.Channels - 1 do begin
        v := TQMPEXT.fdsp.Data[k, x];
        s := s - (s - v) / (k + 1);
        TQMPEXT.fdsp.Data[k, x] := v;
      end;
      for k := 0 to Data.Channels - 1 do begin
        v := TQMPEXT.fdsp.Data[k, x];
        v := v + (v - s) * 1.0;
        v := TQMPEXT.fnrm[k].Process(v);
        TQMPEXT.fdsp.Data[k, x] := v;
      end;
    end;
    TQMPEXT.fdsp.Done();
  end;
  Result := 1;
end;

class function TQMPEXT.Update(const Info: PInfo; const Flags: Integer): Integer; cdecl;
begin
  TQMPEXT.finfo := Info^;
  Result := 1;
end;

begin
end.
