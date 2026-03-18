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
    TQMPENH.fhrm[k].Amp := 5.0;
    TQMPENH.fhrm[k].Freq := 350.0;
    TQMPENH.fhrm[k].Width := 1.0;
  end;
  for k := 0 to Length(TQMPENH.fdrm) - 1 do begin
    TQMPENH.fdrm[k].Init(ptZDF, ftBass, btSlope, gtDb);
    TQMPENH.fdrm[k].Amp := -5.0;
    TQMPENH.fdrm[k].Freq := 350.0;
    TQMPENH.fdrm[k].Width := 1.0;
  end;
  for k := 0 to Length(TQMPENH.ftrb) - 1 do begin
    TQMPENH.ftrb[k].Init(ptZDF, ftTreble, btSlope, gtDb);
    TQMPENH.ftrb[k].Amp := 15.0;
    TQMPENH.ftrb[k].Freq := 3500.0;
    TQMPENH.ftrb[k].Width := 1.0;
  end;
  for k := 0 to Length(TQMPENH.frng) - 1 do begin
    TQMPENH.frng[k].Init(ptZDF, ftBand, btSlope, gtDb);
    TQMPENH.frng[k].Amp := 20.0;
    TQMPENH.frng[k].Freq := 640.0;
    TQMPENH.frng[k].Width := 0.05;
  end;
  Result := 1;
end;

class procedure TQMPENH.Quit(const Flags: Integer); cdecl;
var
  k: LongWord;
begin
  for k := 0 to Length(TQMPENH.fhrm) - 1 do begin
    TQMPENH.fhrm[k].Amp := 0.0;
    TQMPENH.fhrm[k].Freq := 0.0;
    TQMPENH.fhrm[k].Width := 0.0;
    TQMPENH.fhrm[k].Done();
  end;
  for k := 0 to Length(TQMPENH.fdrm) - 1 do begin
    TQMPENH.fdrm[k].Amp := 0.0;
    TQMPENH.fdrm[k].Freq := 0.0;
    TQMPENH.fdrm[k].Width := 0.0;
    TQMPENH.fdrm[k].Done();
  end;
  for k := 0 to Length(TQMPENH.ftrb) - 1 do begin
    TQMPENH.ftrb[k].Amp := 0.0;
    TQMPENH.ftrb[k].Freq := 0.0;
    TQMPENH.ftrb[k].Width := 0.0;
    TQMPENH.ftrb[k].Done();
  end;
  for k := 0 to Length(TQMPENH.frng) - 1 do begin
    TQMPENH.frng[k].Amp := 0.0;
    TQMPENH.frng[k].Freq := 0.0;
    TQMPENH.frng[k].Width := 0.0;
    TQMPENH.frng[k].Done();
  end;
end;

class function TQMPENH.Modify(const Data: PData; const Latency: PInteger; const Flags: Integer): Integer; cdecl;
var
  k: LongWord;
  x: LongWord;
begin
  if (TQMPENH.finfo.Enabled) then begin
    TQMPENH.fdsp.Init(Data);
    for k := 0 to Data.Channels - 1 do begin
      TQMPENH.fhrm[k].Rate := Data.Rates;
      TQMPENH.fdrm[k].Rate := Data.Rates;
      TQMPENH.ftrb[k].Rate := Data.Rates;
      TQMPENH.frng[k].Rate := Data.Rates;
      for x := 0 to Data.Samples - 1 do begin
        TQMPENH.fdsp.Data[k, x] := TQMPENH.frng[k].Process(TQMPENH.ftrb[k].Process(TQMPENH.fdrm[k].Process(TQMPENH.fhrm[k].Process(TQMPENH.fdsp.Data[k, x]))));
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
