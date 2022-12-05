#pragma once
#include "qmpdcl.h"
#include "qmpmod.h"
#include "qmpequ.h"
#include "qmpenh.h"
#include "qmpnrm.h"
#include "windows.h"

PPLUGIN CDECL QMPMOD::plugin(INT which) {
    switch (which) {
        case 0:
            return QMPEQU::plugin();
            break;
        case 1:
            return QMPENH::plugin();
            break;
        case 2:
            return QMPNRM::plugin();
            break;
    };

    return NULL;
};

PMODULE CDECL QMPMOD::module() {
    PMODULE result = new MODULE();

    result->instance = 0x0000;
    result->version = 0x0050;
    result->plugin = QMPMOD::plugin;

    return result;
};
