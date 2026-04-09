#pragma once
#include "qmpdcl.h"
#include "qmpbqf.h"
#include "qmpnrm.h"
#include "qmpdsp.h"
#include "windows.h"
#include "array"
#include "cmath"

using namespace std;

struct QMPEQU;
typedef QMPEQU* PQMPEQU;

struct QMPEQU {
private:
    static inline INFO info;
    static inline QMPDSP dsp;
    static inline array<QMPNRM, 5> nrm;
    static inline array<array<QMPBQF, 10>, 5> equ;

    static CDECL INT init(INT flags) {
        for (INT k = 0; k != QMPEQU::equ.size(); k += 1) {
            for (INT i = 0; i != QMPEQU::equ[k].size(); i += 1) {
                QMPEQU::equ[k][i].init(ptLAT, ftEqu, btOctave, gtDb);
            };
        };
        for (INT k = 0; k != QMPEQU::nrm.size(); k += 1) {
            QMPEQU::nrm[k].init(ptLAT, ftBand, btOctave, gtDb);
        };

        return 1;
    };

    static CDECL VOID quit(INT flags) {
        return;
    };

    static CDECL INT modify(PDATA data, PINT latency, INT flags) {
        if (QMPEQU::info.enabled) {
            QMPEQU::dsp.init(data);
            for (INT k = 0; k != data->channels; k += 1) {
                for (INT i = 0; i != QMPEQU::equ[k].size(); i += 1) {
                    QMPEQU::equ[k][i].setAmp((QMPEQU::info.preamp + QMPEQU::info.bands[i]) / 10.0);
                    QMPEQU::equ[k][i].setFreq(20.0 * pow(2.0, 1.0 * (i + 0.5)));
                    QMPEQU::equ[k][i].setWidth(1.0);
                    QMPEQU::equ[k][i].setRate(data->rates);
                };
                QMPEQU::nrm[k].setAmp(20.0);
                QMPEQU::nrm[k].setFreq(160.0);
                QMPEQU::nrm[k].setWidth(6.0);
                QMPEQU::nrm[k].setRate(data->rates);
                for (INT x = 0; x != data->samples; x += 1) {
                    DOUBLE v = QMPEQU::dsp.getData(k, x);
                    for (INT i = 0; i != QMPEQU::equ[k].size(); i += 1) {
                        v = QMPEQU::equ[k][i].process(v);
                    };
                    v = QMPEQU::nrm[k].process(v);
                    QMPEQU::dsp.setData(k, x, v);
                };
            };
        };

        return 1;
    };

    static CDECL INT update(PINFO info, INT flags) {
        QMPEQU::info = *info;

        return 1;
    };
public:
    static CDECL PPLUGIN plugin() {
        PPLUGIN result = new PLUGIN();

        result->description = L"Quinnware Equalizer v3.51";
        result->init = QMPEQU::init;
        result->quit = QMPEQU::quit;
        result->modify = QMPEQU::modify;
        result->update = QMPEQU::update;

        return result;
    };
};
