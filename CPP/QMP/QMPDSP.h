#pragma once
#include "QMPDCL.h"

struct QMPDSP {
    private:
        PDATA data;
        DOUBLE clip(DOUBLE value);
    public:
        VOID init(DATA& data);
        DOUBLE getSamples(DWORD sample, DWORD channel);
        VOID setSamples(DWORD sample, DWORD channel, DOUBLE value);
};
typedef QMPDSP* PQMPDSP;
