unit
  WMPDCL;

interface

type
  PData = ^TData;
  TData = record
    var Data: Pointer;
    var Length: Integer;
    var Samples: Integer;
    var Bits: Integer;
    var Channels: Integer;
    var Rates: Integer;
    var Start: Integer;
    var Finish: Integer;
  end;

type
  PInfo = ^TInfo;
  TInfo = record
    var Size: Integer;
    var Enabled: Boolean;
    var Preamp: Integer;
    var Bands: array[0..20] of Integer;
  end;

type
  PPlugin = ^TPlugin;
  TPlugin = record
    var Description: PAnsiChar;
    var Parent: Integer;
    var Instance: Integer;
    var Config: procedure(const Module: PPlugin); cdecl;
    var Init: function(const Module: PPlugin): Integer; cdecl;
    var Modify: function(const Module: PPlugin; const Data: Pointer; const Samples: Integer; const Bits: Integer; const Channels: Integer; const Rates: Integer): Integer; cdecl;
    var Quit: procedure(const Module: PPlugin); cdecl;
    var Data: Pointer;
  end;

type
  PModule = ^TModule;
  TModule = record
    var Version: Integer;
    var Description: PAnsiChar;
    var Plugin: function(const Which: Integer): PPlugin; cdecl;
  end;

implementation

begin
end.
