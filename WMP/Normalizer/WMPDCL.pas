unit
  WMPDCL;

interface

type
  PData = ^TData;
  TData = record
    var Data: Pointer;
    var Length: LongWord;
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
    var Size: LongWord;
    var Enabled: Boolean;
    var Preamp: Integer;
    var Bands: array[0..20] of Integer;
  end;

type
  PPlugin = ^TPlugin;
  TPlugin = record
    var Description: PAnsiChar;
    var Parent: LongWord;
    var Instance: LongWord;
    var Config: procedure(const Module: PPlugin); cdecl;
    var Init: function(const Module: PPlugin): Integer; cdecl;
    var Modify: function(const Module: PPlugin; const Data: Pointer; const Samples: LongWord; const Bits: LongWord; const Channels: LongWord; const Rates: LongWord): Integer; cdecl;
    var Quit: procedure(const Module: PPlugin); cdecl;
    var Data: Pointer;
  end;

type
  PModule = ^TModule;
  TModule = record
    var Version: LongWord;
    var Description: PAnsiChar;
    var Plugin: function(const Which: Integer): PPlugin; cdecl;
  end;

implementation

begin
end.
