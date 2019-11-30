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
    bps: LongWord;
    nch: LongWord;
    srate: LongWord;
    markerstart: LongWord;
    markerend: LongWord;
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
    description: PChar;
    hwndParent: LongWord;
    instance: LongWord;
    Config: procedure(const tmod: PWMPDSPModule); cdecl;
    Init: function(const tmod: PWMPDSPModule): Integer; cdecl;
    ModifySamples: function(const tmod: PWMPDSPModule; const data: Pointer; const samples, bps, nch, srate: Integer): Integer; cdecl;
    Quit: procedure(const tmod: PWMPDSPModule); cdecl;
    userData: Pointer;
  end;

type
  PWMPDSPHeader = ^TWMPDSPHeader;
  TWMPDSPHeader = record
    version: Integer;
    description: PChar;
    getModule: function(const which: Integer): PWMPDSPModule; cdecl;
  end;

implementation

begin
end.
