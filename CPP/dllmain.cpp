#pragma once
#include "windows.h"

BOOL APIENTRY DllMain(HMODULE hModule, DWORD  dwReason, PVOID lpReserved) {
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
