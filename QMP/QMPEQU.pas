unit
  QMPEQU;

interface

uses
  QMPBQF,
  QMPDSP,
  QMPDCL;

type
  TQMPEQU = record
  private
    class var finfo: TInfo;
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
  for k := 0 to Length(TQMPEQU.feqz) - 1 do begin
    for i := 0 to Length(TQMPEQU.feqz[k]) - 1 do begin
      TQMPEQU.feqz[k, i].Init(ftEqu, btOctave, gtDb);
      TQMPEQU.feqz[k, i].Amp := 0.0;
      TQMPEQU.feqz[k, i].Freq := 32 * Power(2, 1.0 * i);
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
      TQMPEQU.feqz[k, i].Amp := 0.0;
      TQMPEQU.feqz[k, i].Freq := 0.0;
      TQMPEQU.feqz[k, i].Width := 0.0;
      TQMPEQU.feqz[k, i].Done();
    end;
  end;
end;

class function TQMPEQU.Modify(const Data: PData; const Latency: PInteger; const Flags: Integer): Integer; cdecl;
var
  i: LongWord;
  k: LongWord;
  x: LongWord;
begin
  if (TQMPEQU.finfo.Enabled) then begin
    TQMPEQU.fdsp.Init(Data);
    for i := 0 to Length(TQMPEQU.finfo.Bands) - 1 do begin
      for k := 0 to Data.Channels - 1 do begin
        TQMPEQU.feqz[k, i].Amp := (TQMPEQU.finfo.Preamp + TQMPEQU.finfo.Bands[i]) / 10;
        TQMPEQU.feqz[k, i].Rate := Data.Rates;
        for x := 0 to Data.Samples - 1 do begin
          TQMPEQU.fdsp.Data[k, x] := TQMPEQU.feqz[k, i].Process(TQMPEQU.fdsp.Data[k, x]);
        end;
      end;
    end;
    TQMPEQU.fdsp.Done();
  end;
  Result := 1;
end;

class function TQMPEQU.Update(const Info: PInfo; const Flags: Integer): Integer; cdecl;
begin
  TQMPEQU.finfo.Enabled := Info.Enabled;
  TQMPEQU.finfo.Preamp := Info.Preamp;
  TQMPEQU.finfo.Bands := Info.Bands;
  Result := 1;
end;

begin
end.
