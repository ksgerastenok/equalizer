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
    class var fdata: TData;
    class var finfo: TInfo;
    class var fdsp: TQMPDSP;
    class var feqz: array[0..4, 0..9] of TQMPBQF;
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
  k: Integer;
  i: Integer;
begin
  TQMPEQU.fdsp.Init(Addr(TQMPEQU.fdata));
  for k := 0 to Length(TQMPEQU.feqz) - 1 do begin
    for i := 0 to Length(TQMPEQU.feqz[k]) - 1 do begin
      TQMPEQU.feqz[k, i].Init(ftEqu, btOctave, gtDb);
    end;
  end;
  Result := 1;
end;

class procedure TQMPEQU.Quit(const Flags: Integer); cdecl;
var
  k: Integer;
  i: Integer;
begin
  for k := 0 to Length(TQMPEQU.feqz) - 1 do begin
    for i := 0 to Length(TQMPEQU.feqz[k]) - 1 do begin
      TQMPEQU.feqz[k, i].Done();
    end;
  end;
  TQMPEQU.fdsp.Done();
end;

class function TQMPEQU.Modify(const Data: PData; const Latency: Pointer; const Flags: Integer): Integer; cdecl;
var
  k: Integer;
  i: Integer;
  x: Integer;
begin
  if((TQMPEQU.finfo.Enabled)) then begin
    TQMPEQU.fdata.Data := Data.Data;
    TQMPEQU.fdata.Bits := Data.Bits;
    TQMPEQU.fdata.Rates := Data.Rates;
    TQMPEQU.fdata.Samples := Data.Samples;
    TQMPEQU.fdata.Channels := Data.Channels;
    for k := 0 to TQMPEQU.fdata.Channels - 1 do begin
      for i := 0 to Length(TQMPEQU.finfo.Bands) - 1 do begin
        TQMPEQU.feqz[k, i].Amp := (TQMPEQU.finfo.Preamp + TQMPEQU.finfo.Bands[i]) / 10;
        TQMPEQU.feqz[k, i].Freq := 35 * Power(2, 1.0 * i);
        TQMPEQU.feqz[k, i].Rate := TQMPEQU.fdata.Rates;
        TQMPEQU.feqz[k, i].Width := 1.0;
        for x := 0 to TQMPEQU.fdata.Samples - 1 do begin
          TQMPEQU.fdsp.Samples[x, k] := TQMPEQU.feqz[k, i].Process(TQMPEQU.fdsp.Samples[x, k]);
        end;
      end;
    end;
  end;
  Result := 1;
end;

class function TQMPEQU.Update(const Info: PInfo; const Flags: Integer): Integer; cdecl;
begin
  TQMPEQU.finfo.Bands := Info.Bands;
  TQMPEQU.finfo.Preamp := Info.Preamp;
  TQMPEQU.finfo.Enabled := Info.Enabled;
  Result := 1;
end;

begin
end.
