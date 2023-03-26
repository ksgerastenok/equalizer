#pragma once
#include "windows.h"

struct DATA {
    public:
        PVOID data;
        DWORD length;
        DWORD samples;
        DWORD bits;
        DWORD channels;
        DWORD rates;
        DWORD start;
        DWORD finish;
};
typedef DATA* PDATA;

struct INFO {
    public:
        DWORD size;
        CHAR enabled;
        CHAR preamp;
        CHAR bands[10];
};
typedef INFO* PINFO;

struct PLUGIN {
    public:
        DWORD size;
        DWORD version;
        PCWCHAR description;
        CDECL INT (*service)(INT, PVOID, INT, INT);
        PVOID reserved1[4];
        CDECL INT (*init)(INT);
        CDECL VOID (*quit)(INT);
        CDECL INT (*open)(PCWCHAR, PVOID, INT);
        CDECL VOID (*stop)(INT);
        CDECL VOID (*flush)(INT);
        CDECL INT (*modify)(PDATA, PINT, INT);
        CDECL INT (*update)(PINFO, INT);
        CDECL INT (*volume)(PINT, PINT, INT);
        CDECL INT (*event)(INT, INT);
        CDECL VOID (*config)(INT);
        CDECL VOID (*about)(INT);
        PVOID reserved2[4];
};
typedef PLUGIN* PPLUGIN;

struct MODULE {
    public:
        INT version;
        CDECL INT (*service)(INT, PVOID, INT, INT);
        INT instance;
        CDECL PPLUGIN (*plugin)(INT);
};
typedef MODULE* PMODULE;
