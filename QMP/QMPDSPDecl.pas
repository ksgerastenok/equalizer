unit
  QMPDSPDecl;

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
    Preamp: ShortInt;
    Bands: array[0..9] of ShortInt;
  end;

type
  PQMPDSPModule = ^TQMPDSPModule;
  TQMPDSPModule = record
    Init: function(const Flags: Integer): Integer; cdecl;
    Quit: procedure(const Flags: Integer); cdecl;
    Open: function(const Media: PChar; const Format: PWAVEFORMATEX; const Flags: Integer): Integer; cdecl;
    Stop: procedure(const Flags: Integer); cdecl;
    Flush: procedure(const Flags: Integer); cdecl;
    Modify: function(const Data: PWriteData; const Latency: PInteger; const Flags: Integer): Integer; cdecl;
    Update: function(const Info: PEQInfo; const Flags: Integer): Integer; cdecl;
    Volume: function(const Volume: PInteger; const Balance: PInteger; const Flags: Integer): Integer; cdecl;
    Event: function(const Flags: Integer; const Value: Integer): Integer; cdecl;
    Config: procedure(const Flags: Integer); cdecl;
    About: procedure(const Flags: Integer); cdecl;
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
    Size: LongWord;
    Version: LongWord;
    Description: PWideChar;
    Service: function(const Code: Integer; const Buffer: Pointer; const Value: LongInt; const Flags: LongInt): LongInt; cdecl;
    Player: TQMPDSPPlayer;
    Module: TQMPDSPModule;
  end;

type
  PQMPDSPHeader = ^TQMPDSPHeader;
  TQMPDSPHeader = record
    Version: Integer;
    Service: function(const Code: Integer; const Buffer: Pointer; const Value: LongInt; const Flags: LongInt): LongInt; cdecl;
    Instance: LongWord;
    Module: function(const Which: Integer): PQMPDSPPlugin; cdecl;
  end;

implementation

begin
end.
