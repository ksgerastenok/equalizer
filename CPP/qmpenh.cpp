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
	QMPENH::dsp.setData(data->data);
	QMPENH::dsp.setBits(data->bits);
	QMPENH::dsp.setRates(data->rates);
	QMPENH::dsp.setSamples(data->samples);
	QMPENH::dsp.setChannels(data->channels);
	if (QMPENH::enabled) {
		for (INT x = 0; x != QMPENH::dsp.getSamples(); x += 1) {
			DOUBLE f = 0;
			for (INT k = 0; k != QMPENH::dsp.getChannels(); k += 1) {
				f += (QMPENH::dsp.getBuffer(x, k) - f) / (k + 1);
			};
			for (INT k = 0; k != QMPENH::dsp.getChannels(); k += 1) {
				QMPENH::dsp.setBuffer(x, k, f + QMPENH::width * (QMPENH::dsp.getBuffer(x, k) - f));
			};
		};
	};

	return 1;
};

INT QMPENH::update(PINFO info, INT flags) {
	QMPENH::enabled = info->enabled;

	return 1;
};
