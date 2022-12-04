#pragma once
#include "qmpdcl.h"
#include "qmpdsp.h"
#include "windows.h"

struct QMPNRM {
	private:
		BOOLEAN enabled;
		DOUBLE amp[5];
		QMPDSP dsp;
	public:
		VOID init();
		VOID update(INFO& info);
		VOID process(DATA& data);
};
typedef QMPNRM* PQMPNRM;
