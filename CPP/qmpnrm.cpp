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
	QMPNRM::dsp.getData()->data = data->data;
	QMPNRM::dsp.getData()->bits = data->bits;
	QMPNRM::dsp.getData()->rates = data->rates;
	QMPNRM::dsp.getData()->samples = data->samples;
	QMPNRM::dsp.getData()->channels = data->channels;
	if (QMPNRM::enabled) {
		for (INT k = 0; k != QMPNRM::dsp.getData()->channels; k += 1) {
			DOUBLE f = 0;
			for (INT x = 0; x != QMPNRM::dsp.getData()->samples; x += 1) {
				f += (pow(QMPNRM::dsp.getSamples(x, k), 2.0) - f) / (x + 1);
			};
			DOUBLE b = min(max(1.0, 1.0 / pow(5.0 * f, 0.5)), 10.0);
			DOUBLE a = QMPNRM::amp[k];
			for (INT x = 0; x != QMPNRM::dsp.getData()->samples; x += 1) {
				DOUBLE time = (b <= a) ? 0.5 : 25.0;
				QMPNRM::dsp.setSamples(x, k, ((b - a) * min(max(0.0, x / (time * QMPNRM::dsp.getData()->rates)), 1.0) + a) * QMPNRM::dsp.getSamples(x, k));
			};
		};
	};

	return 1;
};

INT QMPNRM::update(PINFO info, INT flags) {
	QMPNRM::enabled = info->enabled;

	return 1;
};
