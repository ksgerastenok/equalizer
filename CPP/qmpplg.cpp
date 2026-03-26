#pragma once
#include "qmpdcl.h"
#include "qmpplg.h"
#include "qmpmod.h"
#include "windows.h"

using namespace std;

EXPORT PMODULE QDSPModule() {
    return QMPMOD::module();
};
