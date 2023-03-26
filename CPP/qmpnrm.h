#pragma once
#include "qmpdcl.h"
#include "qmpdsp.h"
#include "windows.h"

struct QMPNRM {
private:
	static inline BOOLEAN enabled;
	static inline DOUBLE amp[5];
	static inline QMPDSP dsp;
	static CDECL INT init(INT flags);
	static CDECL VOID quit(INT flags);
	static CDECL INT modify(PDATA data, PINT latency, INT flags);
	static CDECL INT update(PINFO info, INT flags);
public:
	static CDECL PPLUGIN plugin();
};
typedef QMPNRM* PQMPNRM;
