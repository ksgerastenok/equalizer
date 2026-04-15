#pragma once
#include "qmpdcl.h"
#include "windows.h"
#include "cmath"

using namespace std;

struct QMPDSP;
typedef QMPDSP* PQMPDSP;

struct QMPDSP {
private:
    DATA data;

    DOUBLE clip(DOUBLE value) {
        return min(max(-1.0, value), 1.0);
    };
public:
    VOID init(PDATA data) {
        this->data = *data;

        return;
    };

    DOUBLE getData(INT channel, INT sample) {
        switch (this->data.bits) {
            case 8: {
                return this->clip(1.0 * ((PCHAR)(this->data.data))[channel + sample * this->data.channels] / 0x0000007F);
            };
            break;
            case 16: {
                return this->clip(1.0 * ((PSHORT)(this->data.data))[channel + sample * this->data.channels] / 0x00007FFF);
            };
            break;
            case 32: {
                return this->clip(1.0 * ((PLONG)(this->data.data))[channel + sample * this->data.channels] / 0x7FFFFFFF);
            };
            break;
        };

        return 0.0;
    };

    VOID setData(INT channel, INT sample, DOUBLE value) {
        switch (this->data.bits) {
            case 8: {
                ((PCHAR)(this->data.data))[channel + sample * this->data.channels] = (CHAR)(this->clip(value) * 0x0000007F);
            };
            break;
            case 16: {
                ((PSHORT)(this->data.data))[channel + sample * this->data.channels] = (SHORT)(this->clip(value) * 0x00007FFF);
            };
            break;
            case 32: {
                ((PLONG)(this->data.data))[channel + sample * this->data.channels] = (LONG)(this->clip(value) * 0x7FFFFFFF);
            };
            break;
        };

        return;
    };
};
