unit
  QMPDSPDCL;

interface

type
  PData = ^TData;
  TData = record
    var Data: Pointer;
    var Length: Integer;
    var Samples: LongWord;
    var Bits: LongWord;
    var Channels: LongWord;
    var Rates: LongWord;
    var Start: LongWord;
    var Finish: LongWord;
  end;

type
  PInfo = ^TInfo;
  TInfo = record
    var Size: LongInt;
    var Enabled: Boolean;
    var Preamp: ShortInt;
    var Bands: array[0..9] of ShortInt;
  end;

type
  PReserved = ^TReserved;
  TReserved = record
    var Reserved: array[0..3] of Pointer;
  end;

type
  PModule = ^TModule;
  TModule = record
    var Init: function(const Flags: Integer): Integer; cdecl;
    var Quit: procedure(const Flags: Integer); cdecl;
    var Open: function(const Media: PChar; const Format: Pointer; const Flags: Integer): Integer; cdecl;
    var Stop: procedure(const Flags: Integer); cdecl;
    var Flush: procedure(const Flags: Integer); cdecl;
    var Modify: function(const Data: PData; const Latency: Pointer; const Flags: Integer): Integer; cdecl;
    var Update: function(const Info: PInfo; const Flags: Integer): Integer; cdecl;
    var Volume: function(const Volume: Pointer; const Balance: Pointer; const Flags: Integer): Integer; cdecl;
    var Event: function(const Flags: Integer; const Value: Integer): Integer; cdecl;
    var Config: procedure(const Flags: Integer); cdecl;
    var About: procedure(const Flags: Integer); cdecl;
    var Reserved: TReserved;
  end;

type
  PPlugin = ^TPlugin;
  TPlugin = record
    var Size: LongWord;
    var Version: LongWord;
    var Description: PWideChar;
    var Service: function(const Code: Integer; const Buffer: Pointer; const Value: LongInt; const Flags: LongInt): LongInt; cdecl;
    var Reserved: TReserved;
    var Module: TModule;
  end;

type
  PHeader = ^THeader;
  THeader = record
    var Version: Integer;
    var Service: function(const Code: Integer; const Buffer: Pointer; const Value: LongInt; const Flags: LongInt): LongInt; cdecl;
    var Instance: LongWord;
    var Module: function(const Which: Integer): PPlugin; cdecl;
  end;

implementation

begin
end.

