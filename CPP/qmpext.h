#pragma once
#include "qmpdcl.h"
#include "qmpdsp.h"
#include "windows.h"

struct QMPEXT {
	private:
		BOOLEAN enabled;
		DOUBLE width;
		QMPDSP dsp;
	public:
		VOID init(DOUBLE width);
		VOID update(INFO& info);
		VOID process(DATA& data);
};
typedef QMPEXT* PQMPEXT;
