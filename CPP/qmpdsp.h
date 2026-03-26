#pragma once
#include "qmpdcl.h"
#include "windows.h"

using namespace std;

struct QMPDSP {
private:
    DATA data;
    DOUBLE clip(const DOUBLE value);
public:
    VOID init(const PDATA data);
    PVOID getData();
    DWORD getBits();
    DWORD getRates();
    DWORD getSamples();
    DWORD getChannels();
    DOUBLE getData(const DWORD channel, const DWORD sample);
    VOID setData(const DWORD channel, const DWORD sample, const DOUBLE value);
};
typedef QMPDSP* PQMPDSP;
