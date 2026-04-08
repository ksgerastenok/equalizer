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
    LPCWSTR description;
    CDECL INT(*service)(INT code, PVOID buffer, INT value, INT flags);
    PVOID reserved1[4];
    CDECL INT(*init)(INT flags);
    CDECL VOID(*quit)(INT flags);
    CDECL INT(*open)(LPCWSTR media, PVOID format, INT flags);
    CDECL VOID(*stop)(INT flags);
    CDECL VOID(*flush)(INT flags);
    CDECL INT(*modify)(PDATA data, PINT latency, INT flags);
    CDECL INT(*update)(PINFO info, INT flags);
    CDECL INT(*volume)(PINT volume, PINT balance, INT flags);
    CDECL INT(*event)(INT event, INT flags);
    CDECL VOID(*config)(INT flags);
    CDECL VOID(*about)(INT flags);
    PVOID reserved2[4];
};
typedef PLUGIN* PPLUGIN;

struct MODULE {
public:
    INT version;
    CDECL INT(*service)(INT code, PVOID buffer, INT value, INT flags);
    INT instance;
    CDECL PPLUGIN(*plugin)(INT which);
};
typedef MODULE* PMODULE;
