#pragma once
#include "qmpdcl.h"
#include "qmpdsp.h"
#include "windows.h"

struct QMPENH {
	private:
		static inline BOOLEAN enabled;
		static inline DOUBLE width;
		static inline QMPDSP dsp;
		static CDECL INT init(INT flags);
		static CDECL VOID quit(INT flags);
		static CDECL INT modify(PDATA data, PINT latency, INT flags);
		static CDECL INT update(PINFO info, INT flags);
	public:
		static CDECL PPLUGIN plugin();
};
typedef QMPENH* PQMPENH;
