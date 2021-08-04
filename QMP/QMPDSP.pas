unit
  QMPDSP;

interface

uses
  QMPDCL;

type
  PQMPDSP = ^TQMPDSP;
  TQMPDSP = object
  private
    var fdata: TData;
    var finfo: TInfo;
    function getData(): PData;
    function getInfo(): PInfo;
    function getSamples(const Sample: LongWord; const Channel: LongWord): Double;
    procedure setSamples(const Sample: LongWord; const Channel: LongWord; const Value: Double);
  public
    property Data: PData read getData;
    property Info: PInfo read getInfo;
    property Samples[const Sample: LongWord; const Channel: LongWord]: Double read getSamples write setSamples;
  end;

implementation

function TQMPDSP.getData(): PData;
begin
  Result := Addr(self.fdata);
end;

function TQMPDSP.getInfo(): PInfo;
begin
  Result := Addr(self.finfo);
end;

function TQMPDSP.getSamples(const Sample: LongWord; const Channel: LongWord): Double;
var
  x: Double;
begin
  if((Sample < self.Data^.Samples) and (Channel < self.Data^.Channels)) then begin
    try
      case (self.Data^.Bits div 8) of
        1: begin
          x := PShortInt(self.Data^.Data)[Channel + Sample * self.Data^.Channels] / $0000007F;
        end;
        2: begin
          x := PSmallInt(self.Data^.Data)[Channel + Sample * self.Data^.Channels] / $00007FFF;
        end;
        4: begin
          x := PLongInt(self.Data^.Data)[Channel + Sample * self.Data^.Channels] / $7FFFFFFF;
        end;
        else begin
          x := 0.0;
        end;
      end;
    except
      x := 0.0;
    end;
  end                                                                   else begin
    x := 0.0;
  end;
  if((x < -1.0)) then begin
    x := -1.0;
  end;
  if((x = 0.0)) then begin
    x := 0.0;
  end;
  if((x > +1.0)) then begin
    x := +1.0;
  end;
  Result := x;
end;

procedure TQMPDSP.setSamples(const Sample: LongWord; const Channel: LongWord; const Value: Double);
var
  x: Double;
begin
  x := Value;
  if((x < -1.0)) then begin
    x := -1.0;
  end;
  if((x = 0.0)) then begin
    x := 0.0;
  end;
  if((x > +1.0)) then begin
    x := +1.0;
  end;
  if((Sample < self.Data^.Samples) and (Channel < self.Data^.Channels)) then begin
    try
      case (self.Data^.Bits div 8) of
        1: begin
          PShortInt(self.Data^.Data)[Channel + Sample * self.Data^.Channels] := Round(x * $0000007F);
        end;
        2: begin
          PSmallInt(self.Data^.Data)[Channel + Sample * self.Data^.Channels] := Round(x * $00007FFF);
        end;
        4: begin
          PLongInt(self.Data^.Data)[Channel + Sample * self.Data^.Channels] := Round(x * $7FFFFFFF);
        end;
        else begin
          PSmallInt(self.Data^.Data)[Channel + Sample * self.Data^.Channels] := Round(x * $00000000);
        end;
      end;
    except
      PSmallInt(self.Data^.Data)[Channel + Sample * self.Data^.Channels] := Round(x * $00000000);
    end;
  end                                                                   else begin
    PSmallInt(self.Data^.Data)[Channel + Sample * self.Data^.Channels] := Round(x * $00000000);
  end;
end;

begin
end.
