unit
  QMPDSP;

interface

uses
  QMPDCL;

type
  PQMPDSP = ^TQMPDSP;
  TQMPDSP = record
  private
    var fdata: TData;
    function clip(const Value: Double): Double;
    function getData(): Pointer;
    procedure setData(const Data: Pointer);
    function getBits(): LongWord;
    procedure setBits(const Bits: LongWord);
    function getRates(): LongWord;
    procedure setRates(const Rates: LongWord);
    function getSamples(): LongWord;
    procedure setSamples(const Samples: LongWord);
    function getChannels(): LongWord;
    procedure setChannels(const Channels: LongWord);
    function getBuffer(const Sample: LongWord; const Channel: LongWord): Double;
    procedure setBuffer(const Sample: LongWord; const Channel: LongWord; const Value: Double);
  public
    procedure Init();
    procedure Done();
    property Data: Pointer read getData write setData;
    property Bits: LongWord read getBits write setBits;
    property Rates: LongWord read getRates write setRates;
    property Samples: LongWord read getSamples write setSamples;
    property Channels: LongWord read getChannels write setChannels;
    property Buffer[const Sample: LongWord; const Channel: LongWord]: Double read getBuffer write setBuffer;
  end;

implementation

uses
  Math;

procedure TQMPDSP.Init();
begin
end;

procedure TQMPDSP.Done();
begin
end;

function TQMPDSP.clip(const Value: Double): Double;
begin
  Result := Min(Max(-1.0, Value), +1.0);
end;

function TQMPDSP.getData(): Pointer;
begin
  Result := self.fdata.Data;
end;

procedure TQMPDSP.setData(const Data: Pointer);
begin
  self.fdata.Data := Data;
end;

function TQMPDSP.getBits(): LongWord;
begin
  Result := self.fdata.Bits;
end;

procedure TQMPDSP.setBits(const Bits: LongWord);
begin
  self.fdata.Bits := Bits;
end;

function TQMPDSP.getRates(): LongWord;
begin
  Result := self.fdata.Rates;
end;

procedure TQMPDSP.setRates(const Rates: LongWord);
begin
  self.fdata.Rates := Rates;
end;

function TQMPDSP.getSamples(): LongWord;
begin
  Result := self.fdata.Samples;
end;

procedure TQMPDSP.setSamples(const Samples: LongWord);
begin
  self.fdata.Samples := Samples;
end;

function TQMPDSP.getChannels(): LongWord;
begin
  Result := self.fdata.Channels;
end;

procedure TQMPDSP.setChannels(const Channels: LongWord);
begin
  self.fdata.Channels := Channels;
end;

function TQMPDSP.getBuffer(const Sample: LongWord; const Channel: LongWord): Double;
begin
  try
    case (self.fdata.Bits) of
      8: begin
        Result := self.clip(PShortInt(self.fdata.Data)[Channel + Sample * self.fdata.Channels] / $0000007F);
      end;
      16: begin
        Result := self.clip(PSmallInt(self.fdata.Data)[Channel + Sample * self.fdata.Channels] / $00007FFF);
      end;
      32: begin
        Result := self.clip(PLongInt(self.fdata.Data)[Channel + Sample * self.fdata.Channels] / $7FFFFFFF);
      end;
    end;
  except
  end;
end;

procedure TQMPDSP.setBuffer(const Sample: LongWord; const Channel: LongWord; const Value: Double);
begin
  try
    case (self.fdata.Bits) of
      8: begin
        PShortInt(self.fdata.Data)[Channel + Sample * self.fdata.Channels] := Round(self.clip(Value) * $0000007F);
      end;
      16: begin
        PSmallInt(self.fdata.Data)[Channel + Sample * self.fdata.Channels] := Round(self.clip(Value) * $00007FFF);
      end;
      32: begin
        PLongInt(self.fdata.Data)[Channel + Sample * self.fdata.Channels] := Round(self.clip(Value) * $7FFFFFFF);
      end;
    end;
  except
  end;
end;

begin
end.
