#pragma once
#include "QMPDCL.h"
#include "QMPBQF.h"
#include "QMPDSP.h"

struct QMPEQU {
    private:
        static inline DATA data;
        static inline INFO info;
        static inline QMPDSP dsp;
        static inline QMPBQF eqz[10][5];
        static INT CDECL init(INT flags);
        static INT CDECL modify(PDATA data, PVOID latency, INT flags);
        static INT CDECL update(PINFO info, INT flags);
        static VOID CDECL quit(INT flags);
    public:
        static PPLUGIN CDECL plugin();
};
typedef QMPEQU* PQMPEQU;
