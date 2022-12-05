#pragma once
#include "qmpdcl.h"
#include "qmpbqf.h"
#include "qmpdsp.h"
#include "windows.h"

struct QMPEQU {
private:
    static inline BOOLEAN enabled;
    static inline QMPDSP dsp;
    static inline QMPBQF equ[5][10];
    static CDECL INT init(INT flags);
    static CDECL VOID quit(INT flags);
    static CDECL INT modify(PDATA data, PINT latency, INT flags);
    static CDECL INT update(PINFO info, INT flags);
public:
    static CDECL PPLUGIN plugin();
};
typedef QMPEQU* PQMPEQU;
