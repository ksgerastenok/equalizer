#pragma once
#include "QMPDCL.h"

struct QMPMOD {
    private:
        static PPLUGIN CDECL plugin(INT which);
    public:
        static PMODULE CDECL module();
};
typedef QMPMOD* PQMPMOD;
