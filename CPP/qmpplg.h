#pragma once
#include "qmpdcl.h"
#include "qmpmod.h"
#include "windows.h"
#define EXPORT extern "C" __declspec(dllexport)

using namespace std;

EXPORT PMODULE QDSPModule();

EXPORT PMODULE QDSPModule() {
    return QMPMOD::module();
};
