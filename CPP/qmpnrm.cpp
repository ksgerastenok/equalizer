#pragma once
#include "qmpdcl.h"
#include "qmpnrm.h"
#include "math.h"
#include "windows.h"

PPLUGIN QMPNRM::plugin() {
	PPLUGIN	result = new PLUGIN();

	result->description = L"Quinnware Normalizer v3.51";
	result->version = 0x0000;
	result->init = QMPNRM::init;
	result->quit = QMPNRM::quit;
	result->update = QMPNRM::update;
	result->modify = QMPNRM::modify;

	return result;
};

INT QMPNRM::init(INT flags) {
	QMPNRM::dsp.init();
	for (INT k = 0; k != 5; k += 1) {
		QMPNRM::amp[k] = 1.0;
	};

	return 1;
};

VOID QMPNRM::quit(INT flags) {
	return;
};

INT QMPNRM::modify(PDATA data, PINT latency, INT flags) {
	QMPNRM::dsp.setData(data->data);
	QMPNRM::dsp.setBits(data->bits);
	QMPNRM::dsp.setRates(data->rates);
	QMPNRM::dsp.setSamples(data->samples);
	QMPNRM::dsp.setChannels(data->channels);
	if (QMPNRM::enabled) {
		for (INT k = 0; k != QMPNRM::dsp.getChannels(); k += 1) {
			DOUBLE f = 1.0;
			for (INT x = 0; x != QMPNRM::dsp.getSamples(); x += 1) {
				f /= pow(1.0 + ((4.5 * pow(f * QMPNRM::dsp.getBuffer(x, k), 2.0) - 1.0) / (x + 1)), 0.5);
			};
			DOUBLE b = min(max(1.0, f), 10.0);
			DOUBLE a = min(max(1.0, QMPNRM::amp[k]), 10.0);
			for (INT x = 0; x != QMPNRM::dsp.getSamples(); x += 1) {
                                QMPNRM::amp[k] = (b - a) * min(max(0.0, x / (((b <= a) ? 0.5 : 25.0) * QMPNRM::dsp.getRates())), 1.0) + a;
				QMPNRM::dsp.setBuffer(x, k, QMPNRM::amp[k] * QMPNRM::dsp.getBuffer(x, k));
			};
		};
	};

	return 1;
};

INT QMPNRM::update(PINFO info, INT flags) {
	QMPNRM::enabled = info->enabled;

	return 1;
};
