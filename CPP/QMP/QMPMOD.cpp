#pragma once
#include "QMPDCL.h"
#include "QMPEQU.h"
#include "QMPMOD.h"

PPLUGIN CDECL QMPMOD::plugin(INT which) {
    switch (which) {
        case 0:
            return QMPEQU::plugin();
            break;
        default:
            return NULL;
            break;
    };
};

PMODULE CDECL QMPMOD::module() {
    PMODULE result = new MODULE();

    result->instance = 0x0000;
    result->version = 0x0050;
    result->plugin = QMPMOD::plugin;

    return result;
};
