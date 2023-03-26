unit
  QMPEQU;

interface

uses
  QMPBQF,
  QMPDSP,
  QMPDCL;

type
  PQMPEQU = ^TQMPEQU;
  TQMPEQU = record
  private
    class var fenabled: Boolean;
    class var fdsp: TQMPDSP;
    class var feqz: array[0..4, 0..9] of TQMPBQF;
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

class function TQMPEQU.Plugin(): PPlugin; cdecl;
begin
  Result := New(PPlugin);
  Result.Description := 'Quinnware Equalizer v3.51';
  Result.Version := $0000;
  Result.Init := TQMPEQU.Init;
  Result.Quit := TQMPEQU.Quit;
  Result.Modify := TQMPEQU.Modify;
  Result.Update := TQMPEQU.Update;
end;

class function TQMPEQU.Init(const Flags: Integer): Integer; cdecl;
var
  k: LongWord;
  i: LongWord;
begin
  TQMPEQU.fdsp.Init();
  for k := 0 to Length(TQMPEQU.feqz) - 1 do begin
    for i := 0 to Length(TQMPEQU.feqz[k]) - 1 do begin
      TQMPEQU.feqz[k, i].Init(ftEqu, btOctave, gtDb);
      TQMPEQU.feqz[k, i].Freq := 35 * Power(2, 1.0 * i);
      TQMPEQU.feqz[k, i].Width := 1.0;
    end;
  end;
  Result := 1;
end;

class procedure TQMPEQU.Quit(const Flags: Integer); cdecl;
var
  k: LongWord;
  i: LongWord;
begin
  for k := 0 to Length(TQMPEQU.feqz) - 1 do begin
    for i := 0 to Length(TQMPEQU.feqz[k]) - 1 do begin
      TQMPEQU.feqz[k, i].Freq := 0.0;
      TQMPEQU.feqz[k, i].Width := 0.0;
      TQMPEQU.feqz[k, i].Done();
    end;
  end;
  TQMPEQU.fdsp.Done();
end;

class function TQMPEQU.Modify(const Data: PData; const Latency: PInteger; const Flags: Integer): Integer; cdecl;
var
  k: LongWord;
  i: LongWord;
  x: LongWord;
begin
  TQMPEQU.fdsp.Data := Data.Data;
  TQMPEQU.fdsp.Bits := Data.Bits;
  TQMPEQU.fdsp.Rates := Data.Rates;
  TQMPEQU.fdsp.Samples := Data.Samples;
  TQMPEQU.fdsp.Channels := Data.Channels;
  if (TQMPEQU.fenabled) then begin
    for k := 0 to Length(TQMPEQU.feqz) - 1 do begin
      for i := 0 to Length(TQMPEQU.feqz[k]) - 1 do begin
        TQMPEQU.feqz[k, i].Rate := TQMPEQU.fdsp.Rates;
        for x := 0 to TQMPEQU.fdsp.Samples - 1 do begin
          if (k < TQMPEQU.fdsp.Channels) then begin
            TQMPEQU.fdsp.Buffer[x, k] := TQMPEQU.feqz[k, i].Process(TQMPEQU.fdsp.Buffer[x, k]);
          end;
        end;
      end;
    end;
  end;
  Result := 1;
end;

class function TQMPEQU.Update(const Info: PInfo; const Flags: Integer): Integer; cdecl;
var
  k: LongWord;
  i: LongWord;
begin
  TQMPEQU.fenabled := Info.Enabled;
  for k := 0 to Length(TQMPEQU.feqz) - 1 do begin
    for i := 0 to Length(TQMPEQU.feqz[k]) - 1 do begin
      TQMPEQU.feqz[k, i].Amp := (Info.Preamp + Info.Bands[i]) / 10;
    end;
  end;
  Result := 1;
end;

begin
end.
