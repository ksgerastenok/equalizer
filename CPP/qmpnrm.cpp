#pragma once
#include "qmpdcl.h"
#include "qmpnrm.h"
#include "math.h"
#include "windows.h"

VOID QMPNRM::init() {
	this->dsp.init();
    for (INT k = 0; k != 5; k += 1) {
        this->amp[k] = 1.0;
    }
};

VOID QMPNRM::update(INFO& info) {
	this->enabled = info.enabled;
};

VOID QMPNRM::process(DATA& data) {
	this->dsp.setData(data);
    if (this->enabled) {
        for (INT k = 0; k != this->dsp.getData().channels; k += 1) {
            DOUBLE f = 0;
            for (INT x = 0; x != this->dsp.getData().samples; x += 1) {
                f += (pow(this->dsp.getSamples(x, k), 2.0) - f) / (x + 1);
            };
            DOUBLE b = min(max(1.0, 1.0 / pow(5.0 * f, 0.5)), 10.0);
            DOUBLE a = this->amp[k];
            for (INT x = 0; x != this->dsp.getData().samples; x += 1) {
                DOUBLE time = (b <= a) ? 0.2 : 5.0;
                this->dsp.setSamples(x, k, ((b - a) * min(max(0.0, x / (time * this->dsp.getData().rates)), 1.0) + a) * this->dsp.getSamples(x, k));
            };
        };
    };
};
