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
    class var fdsp: TQMPDSP;
    class var feqz: array[0..4, 0..9] of TQMPBQF;
    class function getDSP(): PQMPDSP; cdecl; static;
    class function Init(const Flags: Integer): Integer; cdecl; static;
    class function Modify(const Data: PData; const Latency: Pointer; const Flags: Integer): Integer; cdecl; static;
    class function Update(const Info: PInfo; const Flags: Integer): Integer; cdecl; static;
    class procedure Quit(const Flags: Integer); cdecl; static;
  public
    class function Plugin(): PPlugin; cdecl; static;
    class property DSP: PQMPDSP read getDSP;
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

class function TQMPEQU.getDSP(): PQMPDSP; cdecl;
begin
  Result := Addr(TQMPEQU.fdsp);
end;

class function TQMPEQU.Init(const Flags: Integer): Integer; cdecl;
var
  k: Integer;
  i: Integer;
begin
  for k := 0 to Length(TQMPEQU.feqz) - 1 do begin
    for i := 0 to Length(TQMPEQU.feqz[k]) - 1 do begin
      TQMPEQU.feqz[k, i] := TQMPBQF.Create(ftEqu, btOctave, gtDb);
    end;
  end;
  Result := 1;
end;

class procedure TQMPEQU.Quit(const Flags: Integer); cdecl;
begin
end;

class function TQMPEQU.Modify(const Data: PData; const Latency: Pointer; const Flags: Integer): Integer; cdecl;
var
  k: Integer;
  i: Integer;
  x: Integer;
begin
  if((TQMPEQU.DSP.Info.Enabled)) then begin
    TQMPEQU.DSP.Data.Data := Data.Data;
    TQMPEQU.DSP.Data.Bits := Data.Bits;
    TQMPEQU.DSP.Data.Rates := Data.Rates;
    TQMPEQU.DSP.Data.Samples := Data.Samples;
    TQMPEQU.DSP.Data.Channels := Data.Channels;
    for k := 0 to TQMPEQU.DSP.Data.Channels - 1 do begin
      for i := 0 to Length(TQMPEQU.DSP.Info.Bands) - 1 do begin
        TQMPEQU.feqz[k, i].Amp := (TQMPEQU.DSP.Info.Preamp + TQMPEQU.DSP.Info.Bands[i]) / 10;
        TQMPEQU.feqz[k, i].Freq := 35 * Power(2, 1.0 * i);
        TQMPEQU.feqz[k, i].Rate := TQMPEQU.DSP.Data.Rates;
        TQMPEQU.feqz[k, i].Width := 1.0;
        for x := 0 to TQMPEQU.DSP.Data.Samples - 1 do begin
          TQMPEQU.DSP.Samples[x, k] := TQMPEQU.feqz[k, i].Process(TQMPEQU.DSP.Samples[x, k]);
        end;
      end;
    end;
  end;
  Result := 1;
end;

class function TQMPEQU.Update(const Info: PInfo; const Flags: Integer): Integer; cdecl;
begin
  TQMPEQU.DSP.Info.Size := Info.Size;
  TQMPEQU.DSP.Info.Bands := Info.Bands;
  TQMPEQU.DSP.Info.Preamp := Info.Preamp;
  TQMPEQU.DSP.Info.Enabled := Info.Enabled;
  Result := 1;
end;

begin
end.
