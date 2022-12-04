#pragma once
#include "qmpdcl.h"
#include "qmpbqf.h"
#include "qmpdsp.h"
#include "windows.h"

struct QMPEQU {
    private:
        BOOLEAN enabled;
        QMPDSP dsp;
        QMPBQF equ[5][10];
    public:
        VOID init();
        VOID update(INFO& info);
        VOID process(DATA& data);
};
typedef QMPEQU* PQMPEQU;
