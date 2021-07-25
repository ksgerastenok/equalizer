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
    class var feqz: array[0..4, 0..9] of TQMPBQF;
    class var finfo: PInfo;
    class function Init(const Flags: Integer): Integer; cdecl; static;
    class function Modify(const Data: PData; const Latency: Pointer; const Flags: Integer): Integer; cdecl; static;
    class function Update(const Info: PInfo; const Flags: Integer): Integer; cdecl; static;
    class procedure Quit(const Flags: Integer); cdecl; static;
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
  TQMPEQU.finfo := New(PInfo);
  for k := 0 to Length(TQMPEQU.feqz) - 1 do begin
    for i := 0 to Length(TQMPEQU.feqz[k]) - 1 do begin
      TQMPEQU.feqz[k, i] := TQMPBQF.Create(ftEqu, btOctave, gtDb);
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
      TQMPEQU.feqz[k, i].Destroy();
    end;
  end;
  Dispose(TQMPEQU.finfo);
end;

class function TQMPEQU.Modify(const Data: PData; const Latency: Pointer; const Flags: Integer): Integer; cdecl;
var
  k: LongWord;
  i: LongWord;
  x: LongWord;
begin
  if((TQMPEQU.finfo.Enabled)) then begin
    for k := 0 to Data.Channels - 1 do begin
      for i := 0 to Length(TQMPEQU.finfo.Bands) - 1 do begin
        TQMPEQU.feqz[k, i].Amp := (TQMPEQU.finfo.Preamp + TQMPEQU.finfo.Bands[i]) / 10;
        TQMPEQU.feqz[k, i].Freq := 35 * Power(2, 1.0 * i);
        TQMPEQU.feqz[k, i].Rate := Data.Rates;
        TQMPEQU.feqz[k, i].Width := 1.0;
        for x := 0 to Data.Samples - 1 do begin
          TQMPDSP.Samples[Data, x, k] := TQMPEQU.feqz[k, i].Process(TQMPDSP.Samples[Data, x, k]);
        end;
      end;
    end;
  end;
  Result := 1;
end;

class function TQMPEQU.Update(const Info: PInfo; const Flags: Integer): Integer; cdecl;
begin
  TQMPEQU.finfo.Size := Info.Size;
  TQMPEQU.finfo.Bands := Info.Bands;
  TQMPEQU.finfo.Preamp := Info.Preamp;
  TQMPEQU.finfo.Enabled := Info.Enabled;
  Result := 1;
end;

begin
end.
