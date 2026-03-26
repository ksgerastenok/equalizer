#pragma once
#include "qmpdcl.h"
#include "qmpmod.h"
#include "qmpequ.h"
#include "qmpenh.h"
#include "windows.h"

using namespace std;

PPLUGIN CDECL QMPMOD::plugin(INT which) {
    switch (which) {
    case 0:
        return QMPEQU::plugin();
        break;
    case 1:
        return QMPENH::plugin();
        break;
    default:
        return NULL;
        break;
    };

    return NULL;
};

PMODULE CDECL QMPMOD::module() {
    PMODULE result = new MODULE();

    result->plugin = QMPMOD::plugin;

    return result;
};
