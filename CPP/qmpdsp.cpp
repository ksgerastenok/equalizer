#pragma once
#include "qmpdsp.h"
#include "qmpdcl.h"
#include "math.h"
#include "windows.h"

VOID QMPDSP::init() {
    return;
};

DOUBLE QMPDSP::clip(DOUBLE value) {
    return min(max(-1.0, value), 1.0);
};

PDATA QMPDSP::getData() {
    return &this->data;
}

DOUBLE QMPDSP::getSamples(DWORD sample, DWORD channel) {
    try {
        switch (this->data.bits) {
            case 8:
                return this->clip(1.0 * ((PCHAR)(this->data.data))[channel + sample * this->data.channels] / 0x0000007F);
                break;
            case 16:
                return this->clip(1.0 * ((PSHORT)(this->data.data))[channel + sample * this->data.channels] / 0x00007FFF);
                break;
            case 32:
                return this->clip(1.0 * ((PLONG)(this->data.data))[channel + sample * this->data.channels] / 0x7FFFFFFF);
                break;
        };
    } catch (...) {
    };

    return 0.0;
};

VOID QMPDSP::setSamples(DWORD sample, DWORD channel, DOUBLE value) {
    try {
        switch (this->data.bits) {
            case 8:
                ((PCHAR)(this->data.data))[channel + sample * this->data.channels] = (CHAR)(this->clip(value) * 0x0000007F);
                break;
            case 16:
                ((PSHORT)(this->data.data))[channel + sample * this->data.channels] = (SHORT)(this->clip(value) * 0x00007FFF);
                break;
            case 32:
                ((PLONG)(this->data.data))[channel + sample * this->data.channels] = (LONG)(this->clip(value) * 0x7FFFFFFF);
                break;
        };
    } catch (...) {
    };

    return;
};
