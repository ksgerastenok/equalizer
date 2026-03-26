#pragma once
#include "qmpdcl.h"
#include "qmpbqf.h"
#include "qmpnrm.h"
#include "qmpdsp.h"
#include "windows.h"
#include "array"

using namespace std;

struct QMPEQU {
private:
    static inline INFO info;
    static inline QMPDSP dsp;
    static inline array<QMPNRM, 5> nrm;
    static inline array<array<QMPBQF, 10>, 5> equ;
    static CDECL INT init(const INT flags);
    static CDECL VOID quit(const INT flags);
    static CDECL INT modify(const PDATA data, const PINT latency, const INT flags);
    static CDECL INT update(const PINFO info, const INT flags);
public:
    static CDECL PPLUGIN plugin();
};
typedef QMPEQU* PQMPEQU;
