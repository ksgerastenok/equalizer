#pragma once
#include "qmpdcl.h"
#include "qmpequ.h"
#include "windows.h"

struct QMPEQZ {
    private:
        static inline QMPEQU equ;
        static CDECL INT init(INT flags);
        static CDECL INT modify(PDATA data, PINT latency, INT flags);
        static CDECL INT update(PINFO info, INT flags);
    public:
        static CDECL PPLUGIN plugin();
};
typedef QMPEQZ* PQMPEQZ;
