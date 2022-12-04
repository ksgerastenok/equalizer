#pragma once
#include "qmpdcl.h"
#include "qmpequ.h"
#include "math.h"
#include "windows.h"

VOID QMPEQU::init() {
    this->dsp.init();
    for (INT k = 0; k != 5; k += 1) {
        for (INT i = 0; i != 10; i += 1) {
            this->equ[k][i].init(ftEqu, btOctave, gtDb);
            this->equ[k][i].setWidth(1.0);
            this->equ[k][i].setFreq(35.0 * pow(2.0, 1.0 * i));
        };
    };

    return;
};

VOID QMPEQU::update(INFO& info) {
    this->enabled = info.enabled;
    for (INT k = 0; k != 5; k += 1) {
        for (INT i = 0; i != 10; i += 1) {
            this->equ[k][i].setAmp(1.0 * (info.preamp + info.bands[i]) / 10);
        };
    };

    return;
};

VOID QMPEQU::process(DATA& data) {
    this->dsp.setData(data);
    if (this->enabled) {
        for (DWORD k = 0; k != 5; k += 1) {
            for (INT i = 0; i != 10; i += 1) {                
                this->equ[k][i].setRate(1.0 * this->dsp.getData().rates);
                for (int x = 0; x != this->dsp.getData().samples; x += 1) {
                    if (k < this->dsp.getData().channels) {
                        this->dsp.setSamples(x, k, this->equ[k][i].process(this->dsp.getSamples(x, k)));
                    };
                };
            };
        };
    };

    return;
};