#pragma once
#include <windows.h>

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
		INT (CDECL* service)(INT, PVOID, INT, INT);
		PVOID reserved1[4];
		INT (CDECL* init)(INT);
		VOID (CDECL* quit)(INT);
		INT (CDECL* open)(PCWCHAR, PVOID, INT);
		VOID (CDECL* stop)(INT);
		VOID (CDECL* flush)(INT);
		INT (CDECL* modify)(PDATA, PVOID, INT);
		INT (CDECL* update)(PINFO, INT);
		INT (CDECL* volume)(PINT, PINT, INT);
		INT (CDECL* event)(INT, INT);
		VOID (CDECL* config)(INT);
		VOID (CDECL* about)(INT);
		PVOID reserved2[4];
};
typedef PLUGIN* PPLUGIN;

struct MODULE {
	public:
		INT version;
		INT (CDECL* service)(INT, PVOID, INT, INT);
		INT instance;
		PPLUGIN (CDECL* plugin)(INT);
};
typedef MODULE* PMODULE;
