unit
  QMPENH;

interface

uses
  QMPBQF,
  QMPDSP,
  QMPDCL;

type
  TQMPENH = record
  private
    class var finfo: TInfo;
    class var fdsp: TQMPDSP;
    class var fhrm: array[0..4] of TQMPBQF;
    class var fdrm: array[0..4] of TQMPBQF;
    class var ftrb: array[0..4] of TQMPBQF;
    class var frng: array[0..4] of TQMPBQF;
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
  Result.Init := TQMPENH.Init;
  Result.Quit := TQMPENH.Quit;
  Result.Modify := TQMPENH.Modify;
  Result.Update := TQMPENH.Update;
end;

class function TQMPENH.Init(const Flags: Integer): Integer; cdecl;
var
  k: LongWord;
begin
  for k := 0 to Length(TQMPENH.fhrm) - 1 do begin
    TQMPENH.fhrm[k].Init(ptZDF, ftBass, btSlope, gtDb);
  end;
  for k := 0 to Length(TQMPENH.fdrm) - 1 do begin
    TQMPENH.fdrm[k].Init(ptZDF, ftBass, btSlope, gtDb);
  end;
  for k := 0 to Length(TQMPENH.ftrb) - 1 do begin
    TQMPENH.ftrb[k].Init(ptZDF, ftTreble, btSlope, gtDb);
  end;
  for k := 0 to Length(TQMPENH.frng) - 1 do begin
    TQMPENH.frng[k].Init(ptZDF, ftBand, btSlope, gtDb);
  end;
  Result := 1;
end;

class procedure TQMPENH.Quit(const Flags: Integer); cdecl;
var
  k: LongWord;
begin
  for k := 0 to Length(TQMPENH.fhrm) - 1 do begin
    TQMPENH.fhrm[k].Done();
  end;
  for k := 0 to Length(TQMPENH.fdrm) - 1 do begin
    TQMPENH.fdrm[k].Done();
  end;
  for k := 0 to Length(TQMPENH.ftrb) - 1 do begin
    TQMPENH.ftrb[k].Done();
  end;
  for k := 0 to Length(TQMPENH.frng) - 1 do begin
    TQMPENH.frng[k].Done();
  end;
end;

class function TQMPENH.Modify(const Data: PData; const Latency: PInteger; const Flags: Integer): Integer; cdecl;
var
  k: LongWord;
  x: LongWord;
  v: Double;
begin
  if (TQMPENH.finfo.Enabled) then begin
    TQMPENH.fdsp.Init(Data);
    for k := 0 to Data.Channels - 1 do begin
      TQMPENH.fhrm[k].Amp := 3.5;
      TQMPENH.fhrm[k].Freq := 150.0;
      TQMPENH.fhrm[k].Width := 1.0;
      TQMPENH.fhrm[k].Rate := Data.Rates;
      TQMPENH.fdrm[k].Amp := -3.5;
      TQMPENH.fdrm[k].Freq := 150.0;
      TQMPENH.fdrm[k].Width := 1.0;
      TQMPENH.fdrm[k].Rate := Data.Rates;
      TQMPENH.ftrb[k].Amp := 12.5;
      TQMPENH.ftrb[k].Freq := 3500.0;
      TQMPENH.ftrb[k].Width := 1.0;
      TQMPENH.ftrb[k].Rate := Data.Rates;
      TQMPENH.frng[k].Amp := 20.0;
      TQMPENH.frng[k].Freq := 640.0;
      TQMPENH.frng[k].Width := 0.05;
      TQMPENH.frng[k].Rate := Data.Rates;
      for x := 0 to Data.Samples - 1 do begin
        v := TQMPENH.fdsp.Data[k, x];
        v := TQMPENH.fhrm[k].Process(v);
        v := TQMPENH.fdrm[k].Process(v);
        v := TQMPENH.ftrb[k].Process(v);
        v := TQMPENH.frng[k].Process(v);
        TQMPENH.fdsp.Data[k, x] := v;
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
