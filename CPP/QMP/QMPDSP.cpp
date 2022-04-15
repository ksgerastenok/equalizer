#pragma once
#include "QMPDSP.h"
#include "QMPDCL.h"

VOID QMPDSP::init(PDATA data) {
    this->data = data;

    return;
};

DOUBLE QMPDSP::clip(DOUBLE value) {
    if (value <= -1.0) {
        return -1.0;
    };

    if (value == 0.0) {
        return 0.0;
    };

    if (value >= +1.0) {
        return +1.0;
    };

    return value;
};

DOUBLE QMPDSP::getSamples(DWORD sample, DWORD channel) {
    try {
        switch (this->data->bits) {
          case 8:
                return this->clip(1.0 * ((PCHAR)(this->data->data))[channel + sample * this->data->channels] / 0x0000007F);
                break;
            case 16:
                return this->clip(1.0 * ((PSHORT)(this->data->data))[channel + sample * this->data->channels] / 0x00007FFF);
                break;
            case 32:
                return this->clip(1.0 * ((PLONG)(this->data->data))[channel + sample * this->data->channels] / 0x7FFFFFFF);
                break;
            default:
                return 0.0;
                break;
        };
    } catch (...) {
        return 0.0;
    };
};

VOID QMPDSP::setSamples(DWORD sample, DWORD channel, DOUBLE value) {
    try {
        switch (this->data->bits) {
            case 8:
                ((PCHAR)(this->data->data))[channel + sample * this->data->channels] = (CHAR)(this->clip(value) * 0x0000007F);
                break;
            case 16:
                ((PSHORT)(this->data->data))[channel + sample * this->data->channels] = (SHORT)(this->clip(value) * 0x00007FFF);
                break;
            case 32:
                ((PLONG)(this->data->data))[channel + sample * this->data->channels] = (LONG)(this->clip(value) * 0x7FFFFFFF);
                break;
            default:
                ((PSHORT)(this->data->data))[channel + sample * this->data->channels] = 0;
                break;
        };
    } catch (...) {
        ((PSHORT)(this->data->data))[channel + sample * this->data->channels] = 0;
    };

    return;
};
