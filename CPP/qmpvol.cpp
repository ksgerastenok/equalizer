#pragma once
#include "qmpdcl.h"
#include "qmpvol.h"
#include "windows.h"

PPLUGIN QMPVOL::plugin() {
	PPLUGIN	result = new PLUGIN();

	result->description = L"Quinnware Normalizer v3.51";
	result->version = 0x0000;
	result->init = QMPVOL::init;
	result->update = QMPVOL::update;
	result->modify = QMPVOL::modify;

	return result;
};

INT QMPVOL::init(INT flags) {
	QMPVOL::nrm.init();

	return 1;
};

INT QMPVOL::modify(PDATA data, PINT latency, INT flags) {
	QMPVOL::nrm.process(*data);

	return 1;
};

INT QMPVOL::update(PINFO info, INT flags) {
	QMPVOL::nrm.update(*info);

	return 1;
};