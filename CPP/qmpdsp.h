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
    DOUBLE getBuffer(const INT channel, const INT sample);
    VOID setBuffer(const INT channel, const INT sample, const DOUBLE value);
};
typedef QMPDSP* PQMPDSP;
