#pragma once
#include "qmpdcl.h"
#include "qmpbqf.h"
#include "qmpnrm.h"
#include "qmpdsp.h"
#include "windows.h"
#include "array"
#include "cmath"

using namespace std;

struct QMPENH;
typedef QMPENH* PQMPENH;

struct QMPENH {
private:
	static inline INFO info;
	static inline QMPDSP dsp;
	static inline array<QMPNRM, 5> nrm;
	static inline array<QMPBQF, 5> hrm;
	static inline array<QMPBQF, 5> drm;
	static inline array<QMPBQF, 5> trb;

	static CDECL INT init(INT flags) {
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

	static CDECL VOID quit(INT flags) {
		return;
	};

	static CDECL INT modify(PDATA data, PINT latency, INT flags) {
		if (QMPENH::info.enabled) {
			QMPENH::dsp.init(data);
			for (INT k = 0; k != data->channels; k += 1) {
				QMPENH::hrm[k].setAmp(5.0);
				QMPENH::hrm[k].setFreq(150.0);
				QMPENH::hrm[k].setWidth(1.0);
				QMPENH::hrm[k].setRate(data->rates);
				QMPENH::drm[k].setAmp(7.5);
				QMPENH::drm[k].setFreq(50.0);
				QMPENH::drm[k].setWidth(1.0);
				QMPENH::drm[k].setRate(data->rates);
				QMPENH::trb[k].setAmp(12.0);
				QMPENH::trb[k].setFreq(2500.0);
				QMPENH::trb[k].setWidth(1.0);
				QMPENH::trb[k].setRate(data->rates);
				QMPENH::nrm[k].setAmp(20.0);
				QMPENH::nrm[k].setFreq(160.0);
				QMPENH::nrm[k].setWidth(0.129);
				QMPENH::nrm[k].setRate(data->rates);
				for (INT x = 0; x != data->samples; x += 1) {
					DOUBLE v = QMPENH::dsp.getData(k, x);
					v = QMPENH::hrm[k].process(v);
					v = QMPENH::drm[k].process(v);
					v = QMPENH::trb[k].process(v);
					v = QMPENH::nrm[k].process(v);
					QMPENH::dsp.setData(k, x, v);
				};
			};
		};

		return 1;
	};

	static CDECL INT update(PINFO info, INT flags) {
		QMPENH::info = *info;

		return 1;
	};
public:
	static CDECL PPLUGIN plugin() {
		PPLUGIN	result = new PLUGIN();

		result->description = L"Quinnware Enhancer v3.51";
		result->init = QMPENH::init;
		result->quit = QMPENH::quit;
		result->update = QMPENH::update;
		result->modify = QMPENH::modify;

		return result;
	};
};
