#pragma once
#include "qmpdcl.h"
#include "qmpext.h"
#include "math.h"
#include "windows.h"

VOID QMPEXT::init(DOUBLE width) {
	this->dsp.init();
	this->width = pow(10, width / 20);
};

VOID QMPEXT::update(INFO& info) {
	this->enabled = info.enabled;
};

VOID QMPEXT::process(DATA& data) {
	this->dsp.setData(data);
    if (this->enabled) {
        for (INT x = 0; x != this->dsp.getData().samples; x += 1) {
            DOUBLE f = 0;
            for (INT k = 0; k != this->dsp.getData().channels; k += 1) {
                f += (this->dsp.getSamples(x, k) - f) / (k + 1);
            };
            for (INT k = 0; k != this->dsp.getData().channels; k += 1) {
                this->dsp.setSamples(x, k, f + this->width * (this->dsp.getSamples(x, k) - f));
            };
        };
    };
};
