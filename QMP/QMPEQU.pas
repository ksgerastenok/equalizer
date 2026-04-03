unit
  QMPEQU;

interface

uses
  QMPBQF,
  QMPRNG,
  QMPDSP,
  QMPDCL;

type
  TQMPEQU = record
  private
    class var finfo: TInfo;
    class var fdsp: TQMPDSP;
    class var fequ: array[0..4] of array[0..9] of TQMPBQF;
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

class function TQMPEQU.Plugin(): PPlugin; cdecl;
begin
  Result := New(PPlugin);
  Result.Description := 'Quinnware Equalizer v3.51';
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
  for k := 0 to Length(TQMPEQU.fequ) - 1 do begin
    for i := 0 to Length(TQMPEQU.fequ[k]) - 1 do begin
      TQMPEQU.fequ[k, i].Init(ptLAT, ftEqu, btOctave, gtDb);
    end;
  end;
  for k := 0 to Length(TQMPEQU.frng) - 1 do begin
    TQMPEQU.frng[k].Init(ptLAT, ftBand, btOctave, gtDb);
  end;
  Result := 1;
end;

class procedure TQMPEQU.Quit(const Flags: Integer); cdecl;
var
  k: LongWord;
  i: LongWord;
begin
  for k := 0 to Length(TQMPEQU.fequ) - 1 do begin
    for i := 0 to Length(TQMPEQU.fequ[k]) - 1 do begin
      TQMPEQU.fequ[k, i].Done();
    end;
  end;
  for k := 0 to Length(TQMPEQU.frng) - 1 do begin
    TQMPEQU.frng[k].Done();
  end;
end;

class function TQMPEQU.Modify(const Data: PData; const Latency: PInteger; const Flags: Integer): Integer; cdecl;
var
  k: LongWord;
  i: LongWord;
  x: LongWord;
  v: Double;
begin
  if (TQMPEQU.finfo.Enabled) then begin
    TQMPEQU.fdsp.Init(Data);
    for k := 0 to Data.Channels - 1 do begin
      for i := 0 to Length(TQMPEQU.finfo.Bands) - 1 do begin
        TQMPEQU.fequ[k, i].Amp := (TQMPEQU.finfo.Preamp + TQMPEQU.finfo.Bands[i]) / 10.0;
        TQMPEQU.fequ[k, i].Freq := 20.0 * Power(2.0, 1.0 * (i + 0.5));
        TQMPEQU.fequ[k, i].Width := 1.0;
        TQMPEQU.fequ[k, i].Rate := Data.Rates;
      end;
      TQMPEQU.frng[k].Amp := 20.0;
      TQMPEQU.frng[k].Freq := 160.0;
      TQMPEQU.frng[k].Width := 6.0;
      TQMPEQU.frng[k].Rate := Data.Rates;
      for x := 0 to Data.Samples - 1 do begin
        v := TQMPEQU.fdsp.Data[k, x];
        for i := 0 to Length(TQMPEQU.finfo.Bands) - 1 do begin
          v := TQMPEQU.fequ[k, i].Process(v);
        end;
        v := TQMPEQU.frng[k].Process(v);
        TQMPEQU.fdsp.Data[k, x] := v;
      end;
    end;
    TQMPEQU.fdsp.Done();
  end;
  Result := 1;
end;

class function TQMPEQU.Update(const Info: PInfo; const Flags: Integer): Integer; cdecl;
begin
  TQMPEQU.finfo := Info^;
  Result := 1;
end;

begin
end.
