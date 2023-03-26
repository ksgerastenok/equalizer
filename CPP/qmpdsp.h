#pragma once
#include "qmpdcl.h"
#include "windows.h"

struct QMPDSP {
    private:
        DATA data;
        DOUBLE clip(DOUBLE value);
    public:
        VOID init();
        PVOID getData();
        VOID setData(PVOID data);
        DWORD getBits();
        VOID setBits(DWORD bits);
        DWORD getRates();
        VOID setRates(DWORD rates);
        DWORD getSamples();
        VOID setSamples(DWORD samples);
        DWORD getChannels();
        VOID setChannels(DWORD channels);
        DOUBLE getBuffer(DWORD sample, DWORD channel);
        VOID setBuffer(DWORD sample, DWORD channel, DOUBLE value);
};
typedef QMPDSP* PQMPDSP;
