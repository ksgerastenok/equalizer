#pragma once
#include "QMPDCL.h"
#include "QMPMOD.h"
#include "QMPPLG.h"

EXPORT PMODULE QDSPModule() {
    return QMPMOD::module();
};
