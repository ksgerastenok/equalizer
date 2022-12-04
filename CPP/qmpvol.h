#pragma once
#include "qmpdcl.h"
#include "qmpnrm.h"
#include "windows.h"

struct QMPVOL {
	private:
		static inline QMPNRM nrm;
		static CDECL INT init(INT flags);
		static CDECL INT modify(PDATA data, PINT latency, INT flags);
		static CDECL INT update(PINFO info, INT flags);
	public:
		static CDECL PPLUGIN plugin();
};
typedef QMPVOL* PQMPVOL;
