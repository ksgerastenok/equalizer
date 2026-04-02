#pragma once
#include "qmpdcl.h"
#include "qmpdsp.h"
#include "qmpequ.h"
#include "windows.h"
#include "cmath"

using namespace std;

PPLUGIN QMPEQU::plugin() {
    PPLUGIN result = new PLUGIN();

    result->description = L"Quinnware Equalizer v3.51";
    result->init = QMPEQU::init;
    result->quit = QMPEQU::quit;
    result->modify = QMPEQU::modify;
    result->update = QMPEQU::update;

    return result;
};

INT QMPEQU::init(const INT flags) {
    for (INT k = 0; k != QMPEQU::equ.size(); k += 1) {
        for (INT i = 0; i != QMPEQU::equ[k].size(); i += 1) {
            QMPEQU::equ[k][i].init(ptLAT, ftEqu, btOctave, gtDb);
        };
    };
    for (INT k = 0; k != QMPEQU::nrm.size(); k += 1) {
        QMPEQU::nrm[k].init(ptLAT, ftBand, btOctave, gtDb);
    };

    return 1;
};

VOID QMPEQU::quit(const INT flags) {
    return;
};

INT QMPEQU::modify(const PDATA data, const PINT latency, const INT flags) {
    if (QMPEQU::info.enabled) {
        QMPEQU::dsp.init(data);
        for (INT k = 0; k != data->channels; k += 1) {
            for (INT i = 0; i != QMPEQU::equ[k].size(); i += 1) {
                QMPEQU::equ[k][i].setAmp((QMPEQU::info.preamp + QMPEQU::info.bands[i]) / 10.0);
                QMPEQU::equ[k][i].setFreq(20.0 * pow(2.0, 1.0 * (i + 0.5)));
                QMPEQU::equ[k][i].setWidth(1.0);
                QMPEQU::equ[k][i].setRate(data->rates);
            };
            QMPEQU::nrm[k].setAmp(20.0);
            QMPEQU::nrm[k].setFreq(640.0);
            QMPEQU::nrm[k].setWidth(10.0);
            QMPEQU::nrm[k].setRate(data->rates);
            for (INT x = 0; x != data->samples; x += 1) {
                DOUBLE v = QMPEQU::dsp.getBuffer(k, x);
                for (INT i = 0; i != QMPEQU::equ[k].size(); i += 1) {
                    v = QMPEQU::equ[k][i].process(v);
                };
                v = QMPEQU::nrm[k].process(v);
                QMPEQU::dsp.setBuffer(k, x, v);
            };
        };
    };

    return 1;
};

INT QMPEQU::update(const PINFO info, const INT flags) {
    QMPEQU::info = *info;

    return 1;
};
