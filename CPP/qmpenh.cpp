#pragma once
#include "qmpdcl.h"
#include "qmpenh.h"
#include "windows.h"
#include "cmath"

using namespace std;

PPLUGIN QMPENH::plugin() {
	PPLUGIN	result = new PLUGIN();

	result->description = L"Quinnware Enhancer v3.51";
	result->init = QMPENH::init;
	result->quit = QMPENH::quit;
	result->update = QMPENH::update;
	result->modify = QMPENH::modify;

	return result;
};

INT QMPENH::init(const INT flags) {
	for (INT k = 0; k != QMPENH::nrm.size(); k += 1) {
		QMPENH::nrm[k].init(ptLAT, ftBand, btSlope, gtDb);
	};
	for (INT k = 0; k != QMPENH::hrm.size(); k += 1) {
		QMPENH::hrm[k].init(ptLAT, ftBass, btSlope, gtDb);
	};
	for (INT k = 0; k != QMPENH::drm.size(); k += 1) {
		QMPENH::drm[k].init(ptLAT, ftBass, btSlope, gtDb);
	};
	for (INT k = 0; k != QMPENH::trb.size(); k += 1) {
		QMPENH::trb[k].init(ptLAT, ftTreble, btSlope, gtDb);
	};

	return 1;
};

VOID QMPENH::quit(const INT flags) {
	return;
};

INT QMPENH::modify(const PDATA data, const PINT latency, const INT flags) {
    if (QMPENH::info.enabled) {
        QMPENH::dsp.init(data);
        for (INT k = 0; k != data->channels; k += 1) {
            QMPENH::hrm[k].setAmp(5.0);
            QMPENH::hrm[k].setFreq(70.0);
            QMPENH::hrm[k].setWidth(1.0);
            QMPENH::hrm[k].setRate(data->rates);
            QMPENH::drm[k].setAmp(3.5);
            QMPENH::drm[k].setFreq(150.0);
            QMPENH::drm[k].setWidth(1.0);
            QMPENH::drm[k].setRate(data->rates);
            QMPENH::trb[k].setAmp(12.0);
            QMPENH::trb[k].setFreq(2500.0);
            QMPENH::trb[k].setWidth(1.0);
            QMPENH::trb[k].setRate(data->rates);
            QMPENH::nrm[k].setAmp(20.0);
            QMPENH::nrm[k].setFreq(640.0);
            QMPENH::nrm[k].setWidth(0.002);
            QMPENH::nrm[k].setRate(data->rates);
            for (INT x = 0; x != data->samples; x += 1) {
                DOUBLE v = QMPENH::dsp.getBuffer(k, x);
                v = QMPENH::hrm[k].process(v);
                v = QMPENH::drm[k].process(v);
                v = QMPENH::trb[k].process(v);
                v = QMPENH::nrm[k].process(v);
                QMPENH::dsp.setBuffer(k, x, v);
            };
        };
    };

	return 1;
};

INT QMPENH::update(const PINFO info, const INT flags) {
	QMPENH::info = *info;

	return 1;
};
