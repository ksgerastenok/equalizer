#pragma once
#include "qmpdcl.h"
#include "qmpext.h"
#include "windows.h"

struct QMPENH {
	private:
		static inline QMPEXT ext;
		static CDECL INT init(INT flags);
		static CDECL INT modify(PDATA data, PINT latency, INT flags);
		static CDECL INT update(PINFO info, INT flags);
	public:
		static CDECL PPLUGIN plugin();
};
typedef QMPENH* PQMPENH;
