unit
  QMPDSPDecl;

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
    markerstart: LongWord;
    markerend: LongWord;
  end;

type
  PEQInfo = ^TEQInfo;
  TEQInfo = record
    size: LongInt;
    enabled: Boolean;
    preamp: ShortInt;
    bands: array[0..9] of ShortInt;
  end;

type
  PQMPDSPModule = ^TQMPDSPModule;
  TQMPDSPModule = record
    Init: function(const flags: Integer): Integer; cdecl;
    Shutdown: procedure(const flags: Integer); cdecl;
    Open: function(const medianame: PChar; const wf: PWAVEFORMATEX; const flags: Integer): Integer; cdecl;
    Stop: procedure(const flags: Integer); cdecl;
    Flush: procedure(const flags: Integer); cdecl;
    Modify: function(const data: PWriteData; const latency: PInteger; const flags: Integer): Integer; cdecl;
    Update: function(const info: PEQInfo; const flags: Integer): Integer; cdecl;
    Volume: function(const volume: PInteger; const balance: PInteger; const flags: Integer): Integer; cdecl;
    Event: function(const flag: Integer; const value: Integer): Integer; cdecl;
    Configure: procedure(const flags: Integer); cdecl;
    About: procedure(const flags: Integer); cdecl;
    Reserved: array[0..3] of Pointer;
  end;

type
  PQMPDSPPlayer = ^TQMPDSPPlayer;
  TQMPDSPPlayer = record
    Reserved: array[0..3] of Pointer;
  end;

type
  PQMPDSPPlugin = ^TQMPDSPPlugin;
  TQMPDSPPlugin = record
    size: LongWord;
    version: LongWord;
    description: PWideChar;
    service: function(const op: Integer; const buffer: Pointer; const param1: LongInt; const param2: LongInt): LongInt; cdecl;
    toPlayer: TQMPDSPPlayer;
    toModule: TQMPDSPModule;
  end;

type
  PQMPDSPHeader = ^TQMPDSPHeader;
  TQMPDSPHeader = record
    version: Integer;
    service: function(const op: Integer; const buffer: Pointer; const param1: LongInt; const param2: LongInt): LongInt; cdecl;
    instance: LongWord;
    getModule: function(const which: Integer): PQMPDSPPlugin; cdecl;
  end;

implementation

begin
end.
