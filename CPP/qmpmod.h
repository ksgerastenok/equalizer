#pragma once
#include "qmpdcl.h"
#include "windows.h"

using namespace std;

struct QMPMOD {
private:
    static CDECL PPLUGIN plugin(INT which);
public:
    static CDECL PMODULE module();
};
typedef QMPMOD* PQMPMOD;
