unit
  WMPDSPDecl;

interface

uses
  MMSystem;
  
type
  PWriteData = ^TWriteData;
  TWriteData = record
    Data: Pointer;
    Length: Integer;
    Samples: LongWord;
    Bits: LongWord;
    Channels: LongWord;
    Rates: LongWord;
    Start: LongWord;
    Finish: LongWord;
  end;

type
  PEQInfo = ^TEQInfo;
  TEQInfo = record
    Size: LongInt;
    Enabled: Boolean;
    Preamp: Integer;
    Bands: array[0..18] of Integer;
  end;

type
  PWMPDSPModule = ^TWMPDSPModule;
  TWMPDSPModule = record
    Description: PAnsiChar;
    Parent: LongWord;
    Instance: LongWord;
    Config: procedure(const Module: PWMPDSPModule); cdecl;
    Init: function(const Module: PWMPDSPModule): Integer; cdecl;
    Modify: function(const Module: PWMPDSPModule; const Data: Pointer; const Samples: Integer; const Bits: Integer; const Channels: Integer; const Rates: Integer): Integer; cdecl;
    Quit: procedure(const Module: PWMPDSPModule); cdecl;
    Data: Pointer;
  end;

type
  PWMPDSPHeader = ^TWMPDSPHeader;
  TWMPDSPHeader = record
    Version: Integer;
    Description: PAnsiChar;
    Module: function(const Which: Integer): PWMPDSPModule; cdecl;
  end;

implementation

initialization

finalization

end.
