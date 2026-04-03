#pragma once
#include "qmpdcl.h"
#include "qmpnrm.h"
#include "windows.h"
#include "cmath"

using namespace std;

VOID QMPNRM::init(const TRANSFORM transform, const FILTER filter, const BAND band, const GAIN gain) {
	this->bqf.init(transform, filter, band, gain);
};

BAND QMPNRM::getBand() {
	return this->bqf.getBand();
};

GAIN QMPNRM::getGain() {
	return this->bqf.getGain();
};

FILTER QMPNRM::getFilter() {
	return this->bqf.getFilter();
};

DOUBLE QMPNRM::getAmp() {
	return this->bqf.getAmp();
};

VOID QMPNRM::setAmp(const DOUBLE value) {
	this->bqf.setAmp(value);
};

DOUBLE QMPNRM::getFreq() {
	return this->bqf.getFreq();
};

VOID QMPNRM::setFreq(const DOUBLE value) {
	this->bqf.setFreq(value);
};

DOUBLE QMPNRM::getRate() {
	return this->bqf.getRate();
};

VOID QMPNRM::setRate(const DOUBLE value) {
	this->bqf.setRate(value);
};

DOUBLE QMPNRM::getWidth() {
	return this->bqf.getWidth();
};

VOID QMPNRM::setWidth(const DOUBLE value) {
	this->bqf.setWidth(value);
};

DOUBLE QMPNRM::getValue() {
	switch (this->bqf.getGain()) {
	case gtDb:
		return 20.0 * log10(this->calcValue());
	case gtAmp:
		return this->calcValue();
	default:
		return 0.0;
	};
};

DOUBLE QMPNRM::calcAmp() {
	switch (this->bqf.getGain()) {
	case gtDb:
		return pow(10.0, this->bqf.getAmp() / 20.0);
	case gtAmp:
		return this->bqf.getAmp();
	default:
		return 0.0;
	};
};

DOUBLE QMPNRM::calcValue() {
	return fmin(fmax(1.0 / this->calcAmp(), 1.0 / (this->avg + 3.0 * sqrt(this->sqr - pow(this->avg, 2.0)))), this->calcAmp());
};

VOID QMPNRM::addSample(const DOUBLE value) {
	if (this->calcValue() * abs(value) < 1.0) {
		this->sqr -= (this->sqr - pow(value, 2.0)) / (5.0 * this->bqf.getRate());
		this->avg -= (this->avg - abs(value))      / (5.0 * this->bqf.getRate());
	}
	else {
		this->sqr -= (this->sqr - pow(value, 2.0)) / (0.5 * this->bqf.getRate());
		this->avg -= (this->avg - abs(value))      / (0.5 * this->bqf.getRate());
	};
};

DOUBLE QMPNRM::process(const DOUBLE value) {
	this->addSample(this->bqf.process(value));
	return this->calcValue() * value;
};
