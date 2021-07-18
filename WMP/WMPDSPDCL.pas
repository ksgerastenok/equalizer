unit
  WMPDSPDCL;

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
    var Preamp: Integer;
    var Bands: array[0..18] of Integer;
  end;

type
  PModule = ^TModule;
  TModule = record
    var Description: PAnsiChar;
    var Parent: LongWord;
    var Instance: LongWord;
    var Config: procedure(const Module: PModule); cdecl;
    var Init: function(const Module: PModule): Integer; cdecl;
    var Modify: function(const Module: PModule; const Data: Pointer; const Samples: Integer; const Bits: Integer; const Channels: Integer; const Rates: Integer): Integer; cdecl;
    var Quit: procedure(const Module: PModule); cdecl;
    var Data: Pointer;
  end;

type
  PHeader = ^THeader;
  THeader = record
    var Version: Integer;
    var Description: PAnsiChar;
    var Module: function(const Which: Integer): PModule; cdecl;
  end;

implementation

begin
end.

