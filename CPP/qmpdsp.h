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
    DOUBLE getData(const INT channel, const INT sample);
    VOID setData(const INT channel, const INT sample, const DOUBLE value);
};
typedef QMPDSP* PQMPDSP;
