#pragma once
#include "windows.h"

using namespace std;

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
    CDECL INT(*service)(const INT, const PVOID, const INT, const INT);
    PVOID reserved1[4];
    CDECL INT(*init)(const INT);
    CDECL VOID(*quit)(const INT);
    CDECL INT(*open)(const PCWCHAR, const PVOID, const INT);
    CDECL VOID(*stop)(const INT);
    CDECL VOID(*flush)(const INT);
    CDECL INT(*modify)(const PDATA, const PINT, const INT);
    CDECL INT(*update)(const PINFO, const INT);
    CDECL INT(*volume)(const PINT, const PINT, const INT);
    CDECL INT(*event)(const INT, const INT);
    CDECL VOID(*config)(const INT);
    CDECL VOID(*about)(const INT);
    PVOID reserved2[4];
};
typedef PLUGIN* PPLUGIN;

struct MODULE {
public:
    INT version;
    CDECL INT(*service)(const INT, const PVOID, const INT, const INT);
    INT instance;
    CDECL PPLUGIN(*plugin)(const INT);
};
typedef MODULE* PMODULE;
