#pragma once
#include "qmpdcl.h"
#include "qmpenh.h"
#include "math.h"
#include "windows.h"

PPLUGIN QMPENH::plugin() {
	PPLUGIN	result = new PLUGIN();

	result->description = L"Quinnware Enhancer v3.51";
	result->version = 0x0000;
	result->init = QMPENH::init;
	result->quit = QMPENH::quit;
	result->update = QMPENH::update;
	result->modify = QMPENH::modify;

	return result;
};

INT QMPENH::init(INT flags) {
	QMPENH::dsp.init();
	QMPENH::width = pow(10, 7.5 / 20);

	return 1;
};

VOID QMPENH::quit(INT flags) {
	return;
};

INT QMPENH::modify(PDATA data, PINT latency, INT flags) {
	QMPENH::dsp.getData()->data = data->data;
	QMPENH::dsp.getData()->bits = data->bits;
	QMPENH::dsp.getData()->rates = data->rates;
	QMPENH::dsp.getData()->samples = data->samples;
	QMPENH::dsp.getData()->channels = data->channels;
	if (QMPENH::enabled) {
		for (INT x = 0; x != QMPENH::dsp.getData()->samples; x += 1) {
			DOUBLE f = 0;
			for (INT k = 0; k != QMPENH::dsp.getData()->channels; k += 1) {
				f += (QMPENH::dsp.getSamples(x, k) - f) / (k + 1);
			};
			for (INT k = 0; k != QMPENH::dsp.getData()->channels; k += 1) {
				QMPENH::dsp.setSamples(x, k, f + QMPENH::width * (QMPENH::dsp.getSamples(x, k) - f));
			};
		};
	};

	return 1;
};

INT QMPENH::update(PINFO info, INT flags) {
	QMPENH::enabled = info->enabled;

	return 1;
};
