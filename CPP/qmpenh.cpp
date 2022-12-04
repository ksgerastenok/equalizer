#pragma once
#include "qmpdcl.h"
#include "qmpenh.h"
#include "windows.h"

PPLUGIN QMPENH::plugin() {
	PPLUGIN	result = new PLUGIN();

	result->description = L"Quinnware Enhancer v3.51";
	result->version = 0x0000;
	result->init = QMPENH::init;
	result->update = QMPENH::update;
	result->modify = QMPENH::modify;

	return result;
};

INT QMPENH::init(INT flags) {
	QMPENH::ext.init(7.5);

	return 1;
};

INT QMPENH::modify(PDATA data, PINT latency, INT flags) {
	QMPENH::ext.process(*data);

	return 1;
};

INT QMPENH::update(PINFO info, INT flags) {
	QMPENH::ext.update(*info);

	return 1;
};