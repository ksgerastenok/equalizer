#pragma once
#include "qmpdcl.h"
#include "windows.h"

struct QMPDSP {
    private:
        DATA data;
        DOUBLE clip(DOUBLE value);
    public:
        VOID init();
        PDATA getData();
        DOUBLE getSamples(DWORD sample, DWORD channel);
        VOID setSamples(DWORD sample, DWORD channel, DOUBLE value);
};
typedef QMPDSP* PQMPDSP;
