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
    var fenabled: Boolean;
    var fdsp: TQMPDSP;
    var feqz: array[0..4, 0..9] of TQMPBQF;
  public
    procedure Init();
    procedure Done();
    procedure Update(const Info: TInfo);
    procedure Process(const Data: TData);
  end;

implementation

uses
  Math;

procedure TQMPEQU.Init();
var
  k: LongWord;
  i: LongWord;
begin
  self.fdsp.Init();
  for k := 0 to Length(self.feqz) - 1 do begin
    for i := 0 to Length(self.feqz[k]) - 1 do begin
      self.feqz[k, i].Init(ftEqu, btOctave, gtDb);
      self.feqz[k, i].Freq := 35 * Power(2, 1.0 * i);
      self.feqz[k, i].Width := 1.0;
    end;
  end;
end;

procedure TQMPEQU.Done();
var
  k: LongWord;
  i: LongWord;
begin
  for k := 0 to Length(self.feqz) - 1 do begin
    for i := 0 to Length(self.feqz[k]) - 1 do begin
      self.feqz[k, i].Freq := 0.0;
      self.feqz[k, i].Width := 0.0;
      self.feqz[k, i].Done();
    end;
  end;
  self.fdsp.Done();
end;

procedure TQMPEQU.Update(const Info: TInfo);
var
  k: LongWord;
  i: LongWord;
begin
  self.fenabled := Info.Enabled;
  for k := 0 to Length(self.feqz) - 1 do begin
    for i := 0 to Length(self.feqz[k]) - 1 do begin
      self.feqz[k, i].Amp := (Info.Preamp + Info.Bands[i]) / 10;
    end;
  end;
end;

procedure TQMPEQU.Process(const Data: TData);
var
  k: LongWord;
  i: LongWord;
  x: LongWord;
begin
  self.fdsp.Data := Data;
  if (self.fenabled) then begin
    for k := 0 to Length(self.feqz) - 1 do begin
      for i := 0 to Length(self.feqz[k]) - 1 do begin
        self.feqz[k, i].Rate := self.fdsp.Data.Rates;
        for x := 0 to self.fdsp.Data.Samples - 1 do begin
          if (k < self.fdsp.Data.Channels) then begin
            self.fdsp.Samples[x, k] := self.feqz[k, i].Process(self.fdsp.Samples[x, k]);
          end;
        end;
      end;
    end;
  end;
end;

begin
end.
