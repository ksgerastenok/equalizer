unit
  WMPDSP;

interface

uses
  WMPDCL;

type
  PWMPDSP = ^TWMPDSP;
  TWMPDSP = record
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

procedure TWMPDSP.Init();
begin
end;

procedure TWMPDSP.Done();
begin
end;

function TWMPDSP.clip(const Value: Double): Double;
begin
  Result := Min(Max(-1.0, Value), +1.0);
end;

function TWMPDSP.getData(): Pointer;
begin
  Result := self.fdata.Data;
end;

procedure TWMPDSP.setData(const Data: Pointer);
begin
  self.fdata.Data := Data;
end;

function TWMPDSP.getBits(): LongWord;
begin
  Result := self.fdata.Bits;
end;

procedure TWMPDSP.setBits(const Bits: LongWord);
begin
  self.fdata.Bits := Bits;
end;

function TWMPDSP.getRates(): LongWord;
begin
  Result := self.fdata.Rates;
end;

procedure TWMPDSP.setRates(const Rates: LongWord);
begin
  self.fdata.Rates := Rates;
end;

function TWMPDSP.getSamples(): LongWord;
begin
  Result := self.fdata.Samples;
end;

procedure TWMPDSP.setSamples(const Samples: LongWord);
begin
  self.fdata.Samples := Samples;
end;

function TWMPDSP.getChannels(): LongWord;
begin
  Result := self.fdata.Channels;
end;

procedure TWMPDSP.setChannels(const Channels: LongWord);
begin
  self.fdata.Channels := Channels;
end;

function TWMPDSP.getBuffer(const Sample: LongWord; const Channel: LongWord): Double;
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

procedure TWMPDSP.setBuffer(const Sample: LongWord; const Channel: LongWord; const Value: Double);
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
