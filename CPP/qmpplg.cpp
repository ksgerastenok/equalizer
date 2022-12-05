#pragma once
#include "qmpdcl.h"
#include "qmpplg.h"
#include "qmpmod.h"
#include "windows.h"

EXPORT PMODULE QDSPModule() {
    return QMPMOD::module();
};
