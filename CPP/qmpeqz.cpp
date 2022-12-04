#pragma once
#include "qmpdcl.h"
#include "qmpdsp.h"
#include "qmpeqz.h"
#include "windows.h"

PPLUGIN CDECL QMPEQZ::plugin() {
    PPLUGIN result = new PLUGIN();

    result->description = L"Quinnware Equalizer v3.51";
    result->version = 0x0000;
    result->init = QMPEQZ::init;
    result->modify = QMPEQZ::modify;
    result->update = QMPEQZ::update;

    return result;
};

INT CDECL QMPEQZ::init(INT flags) {
    QMPEQZ::equ.init();

    return 1;
};

INT CDECL QMPEQZ::modify(PDATA data, PINT latency, INT flags) {
    QMPEQZ::equ.process(*data);

    return 1;
};

INT CDECL QMPEQZ::update(PINFO info, INT flags) {
    QMPEQZ::equ.update(*info);

    return 1;
};
