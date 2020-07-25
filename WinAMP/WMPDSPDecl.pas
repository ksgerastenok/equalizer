unit
  WMPDSPDecl;

interface

uses
  MMSystem;
  
type
  PWriteData = ^TWriteData;
  TWriteData = record
    data: Pointer;
    length: Integer;
    samples: LongWord;
    bits: LongWord;
    channels: LongWord;
    rates: LongWord;
    start: LongWord;
    finish: LongWord;
  end;

type
  PEQInfo = ^TEQInfo;
  TEQInfo = record
    size: LongInt;
    enabled: Boolean;
    preamp: Integer;
    bands: array[0..18] of Integer;
  end;

type
  PWMPDSPModule = ^TWMPDSPModule;
  TWMPDSPModule = record
    description: PAnsiChar;
    parent: LongWord;
    instance: LongWord;
    Config: procedure(const tmod: PWMPDSPModule); cdecl;
    Init: function(const tmod: PWMPDSPModule): Integer; cdecl;
    Modify: function(const tmod: PWMPDSPModule; const data: Pointer; const samples: Integer; const bits: Integer; const channels: Integer; const rates: Integer): Integer; cdecl;
    Quit: procedure(const tmod: PWMPDSPModule); cdecl;
    data: Pointer;
  end;

type
  PWMPDSPHeader = ^TWMPDSPHeader;
  TWMPDSPHeader = record
    version: Integer;
    description: PAnsiChar;
    getModule: function(const which: Integer): PWMPDSPModule; cdecl;
  end;

implementation

initialization

finalization

end.
