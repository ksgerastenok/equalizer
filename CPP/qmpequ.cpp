#pragma once
#include "qmpdcl.h"
#include "qmpdsp.h"
#include "qmpequ.h"
#include "math.h"
#include "windows.h"

PPLUGIN QMPEQU::plugin() {
    PPLUGIN result = new PLUGIN();

    result->description = L"Quinnware Equalizer v3.51";
    result->version = 0x0000;
    result->init = QMPEQU::init;
    result->quit = QMPEQU::quit;
    result->modify = QMPEQU::modify;
    result->update = QMPEQU::update;

    return result;
};

INT QMPEQU::init(INT flags) {
    QMPEQU::dsp.init();
    for (INT k = 0; k != 5; k += 1) {
        for (INT i = 0; i != 10; i += 1) {
            QMPEQU::equ[k][i].init(ftEqu, btOctave, gtDb);
            QMPEQU::equ[k][i].setWidth(1.0);
            QMPEQU::equ[k][i].setFreq(35.0 * pow(2.0, 1.0 * i));
        };
    };

    return 1;
};

VOID QMPEQU::quit(INT flags) {
    return;
};

INT QMPEQU::modify(PDATA data, PINT latency, INT flags) {
    QMPEQU::dsp.getData()->data = data->data;
    QMPEQU::dsp.getData()->bits = data->bits;
    QMPEQU::dsp.getData()->rates = data->rates;
    QMPEQU::dsp.getData()->samples = data->samples;
    QMPEQU::dsp.getData()->channels = data->channels;
    if (QMPEQU::enabled) {
        for (DWORD k = 0; k != 5; k += 1) {
            for (INT i = 0; i != 10; i += 1) {
                QMPEQU::equ[k][i].setRate(1.0 * QMPEQU::dsp.getData()->rates);
                for (int x = 0; x != QMPEQU::dsp.getData()->samples; x += 1) {
                    if (k < QMPEQU::dsp.getData()->channels) {
                        QMPEQU::dsp.setSamples(x, k, QMPEQU::equ[k][i].process(QMPEQU::dsp.getSamples(x, k)));
                    };
                };
            };
        };
    };

    return 1;
};

INT QMPEQU::update(PINFO info, INT flags) {
    QMPEQU::enabled = info->enabled;
    for (INT k = 0; k != 5; k += 1) {
        for (INT i = 0; i != 10; i += 1) {
            QMPEQU::equ[k][i].setAmp(1.0 * (info->preamp + info->bands[i]) / 10);
        };
    };

    return 1;
};
