#pragma once
#include "QMPDCL.h"
#include "QMPDSP.h"
#include "QMPEQU.h"

PPLUGIN CDECL QMPEQU::plugin() {
    PPLUGIN result = new PLUGIN();

    result->description = L"Quinnware Equalizer v3.51";
    result->version = 0x0000;
    result->init = QMPEQU::init;
    result->quit = QMPEQU::quit;
    result->modify = QMPEQU::modify;
    result->update = QMPEQU::update;

    return result;
};

INT CDECL QMPEQU::init(INT flags) {
    QMPEQU::dsp.init(QMPEQU::data);
    for (INT k = 0; k != 5; k += 1) {
        for (INT i = 0; i != 10; i += 1) {
            QMPEQU::eqz[i][k].init(ftEqu, btOctave, gtDb);
        };
    };

    return 1;
};

VOID CDECL QMPEQU::quit(INT flags) {
    return;
};

INT CDECL QMPEQU::modify(PDATA data, PVOID latency, INT flags) {
    if (QMPEQU::info.enabled) {
        QMPEQU::data.data = data->data;
        QMPEQU::data.bits = data->bits;
        QMPEQU::data.rates = data->rates;
        QMPEQU::data.samples = data->samples;
        QMPEQU::data.channels = data->channels;
        for (DWORD k = 0; k != QMPEQU::data.channels; k += 1) {
            for (INT i = 0; i != 10; i += 1) {
                QMPEQU::eqz[i][k].setWidth(1.0);
                QMPEQU::eqz[i][k].setRate(1.0 * QMPEQU::data.rates);
                QMPEQU::eqz[i][k].setFreq((i == 0) ? 35.0 : 2.0 * QMPEQU::eqz[i - 1][k].getFreq());
                QMPEQU::eqz[i][k].setAmp(1.0 * QMPEQU::info.preamp / 10 + 1.0 * QMPEQU::info.bands[i] / 10);
                for (int x = 0; x != QMPEQU::data.samples; x += 1) {
                    QMPEQU::dsp.setSamples(x, k, QMPEQU::eqz[i][k].process(QMPEQU::dsp.getSamples(x, k)));
                };
            };
        };
    };

    return 1;
};

INT CDECL QMPEQU::update(PINFO info, INT flags) {
    QMPEQU::info.preamp = info->preamp;
    QMPEQU::info.enabled = info->enabled;
    for (INT i = 0; i != 10; i += 1) {
        QMPEQU::info.bands[i] = info->bands[i];
    };

    return 1;
};
