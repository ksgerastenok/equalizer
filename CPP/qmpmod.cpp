#pragma once
#include "qmpdcl.h"
#include "qmpmod.h"
#include "qmpeqz.h"
#include "qmpenh.h"
#include "qmpvol.h"
#include "windows.h"

PPLUGIN CDECL QMPMOD::plugin(INT which) {
    switch (which) {
        case 0:
            return QMPEQZ::plugin();
            break;
        case 1:
            return QMPENH::plugin();
            break;
        case 2:
            return QMPVOL::plugin();
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
