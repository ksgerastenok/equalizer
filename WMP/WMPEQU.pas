unit
  WMPEQU;

interface

uses
  WMPBQF,
  WMPDSP,
  WMPDCL;

type
  PWMPEQU = ^TWMPEQU;
  TWMPEQU = record
  private
    var fenabled: Boolean;
    var feqz: array[0..4, 0..20] of TWMPBQF;
  public
    procedure Init();
    procedure Done();
    procedure Update(const Info: PInfo);
    procedure Process(const Data: PData);
  end;

implementation

uses
  Math;

procedure TWMPEQU.Init();
var
  k: Integer;
  i: Integer;
begin
  for k := 0 to Length(self.feqz) - 1 do begin
    for i := 0 to Length(self.feqz[k]) - 1 do begin
      self.feqz[k, i].Init(ftEqu, btOctave, gtDb);
      self.feqz[k, i].Freq := 20 * Power(2, 0.5 * i);
      self.feqz[k, i].Width := 0.5;
    end;
  end;
end;

procedure TWMPEQU.Done();
var
  k: Integer;
  i: Integer;
begin
  for k := 0 to Length(self.feqz) - 1 do begin
    for i := 0 to Length(self.feqz[k]) - 1 do begin
      self.feqz[k, i].Freq := 0.0;
      self.feqz[k, i].Width := 0.0;
      self.feqz[k, i].Done();
    end;
  end;
end;

procedure TWMPEQU.Update(const Info: PInfo);
var
  k: Integer;
  i: Integer;
begin
  self.fenabled := Info.Enabled;
  for k := 0 to Length(self.feqz) - 1 do begin
    for i := 0 to Length(self.feqz[k]) - 1 do begin
      self.feqz[k, i].Amp := (Info.Preamp + Info.Bands[i]) / 10;
    end;
  end;
end;

procedure TWMPEQU.Process(const Data: PData);
var
  k: Integer;
  i: Integer;
  x: Integer;
  dsp: TWMPDSP;
begin
  dsp.Init(Data);
  if (self.fenabled) then begin
    for k := 0 to Length(self.feqz) - 1 do begin
      for i := 0 to Length(self.feqz[k]) - 1 do begin
        self.feqz[k, i].Rate := dsp.Data.Rates;
        for x := 0 to dsp.Data.Samples - 1 do begin
          if (k < dsp.Data.Channels) then begin
            dsp.Samples[x, k] := self.feqz[k, i].Process(dsp.Samples[x, k]);
          end;
        end;
      end;
    end;
  end;
  dsp.Done();
end;

begin
end.
