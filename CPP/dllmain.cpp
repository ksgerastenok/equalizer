#pragma once
#include "windows.h"

using namespace std;

BOOL APIENTRY DllMain(HMODULE hModule, DWORD  dwReason, PVOID pReserved) {
    switch (dwReason) {
    case DLL_PROCESS_ATTACH:
        break;
    case DLL_THREAD_ATTACH:
        break;
    case DLL_THREAD_DETACH:
        break;
    case DLL_PROCESS_DETACH:
        break;
    };

    return TRUE;
};
