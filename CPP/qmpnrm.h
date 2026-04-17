#pragma once
#include "qmpbqf.h"
#include "qmpdcl.h"
#include "qmpdsp.h"
#include "windows.h"
#include "cmath"

using namespace std;

struct QMPNRM;
typedef QMPNRM* PQMPNRM;

struct QMPNRM {
private:
    QMPBQF bqf;
    DOUBLE sqr;
    DOUBLE avg;
    DOUBLE amp;

    DOUBLE calcAmp() {
        switch (this->bqf.getGain()) {
            case gtDb: {
                return pow(10.0, this->amp / 20.0);
            };
            break;
            case gtAmp: {
                return this->amp;
            };
            break;
            default: {
                return 0.0;
            };
            break;
        };
    };

    DOUBLE calcValue() {
        return fmin(fmax(1.0 / this->calcAmp(), 1.0 / (this->avg + 3.0 * sqrt(this->sqr - pow(this->avg, 2.0)))), 1.0 * this->calcAmp());
    };

    VOID addSample(DOUBLE value) {
        if (this->calcValue() * abs(value) < 1.0) {
            this->sqr -= (this->sqr - pow(value, 2.0)) / (5.0 * this->bqf.getRate());
            this->avg -= (this->avg - abs(value)) / (5.0 * this->bqf.getRate());
        }
        else {
            this->sqr -= (this->sqr - pow(value, 2.0)) / (0.5 * this->bqf.getRate());
            this->avg -= (this->avg - abs(value)) / (0.5 * this->bqf.getRate());
        };
    };
public:
    VOID init(TRANSFORM transform, FILTER filter, BAND band, GAIN gain) {
        this->bqf.init(transform, filter, band, gain);
    };

    DOUBLE process(DOUBLE value) {
        this->addSample(this->bqf.process(value));
        return this->calcValue() * value;
    };

    BAND getBand() {
        return this->bqf.getBand();
    };

    GAIN getGain() {
        return this->bqf.getGain();
    };

    FILTER getFilter() {
        return this->bqf.getFilter();
    };

    DOUBLE getAmp() {
        switch (this->bqf.getGain()) {
            case gtDb: {
                return log10(this->calcValue()) * 20.0;
            };
            break;
            case gtAmp: {
                return this->calcValue();
            };
            break;
            default: {
                return 0.0;
            };
            break;
        };
    };

    VOID setAmp(DOUBLE value) {
        this->amp = value;
    };

    DOUBLE getFreq() {
        return this->bqf.getFreq();
    };

    VOID setFreq(DOUBLE value) {
        this->bqf.setFreq(value);
    };

    DOUBLE getRate() {
        return this->bqf.getRate();
    };

    VOID setRate(DOUBLE value) {
        this->bqf.setRate(value);
    };

    DOUBLE getWidth() {
        return this->bqf.getWidth();
    };

    VOID setWidth(DOUBLE value) {
        this->bqf.setWidth(value);
    };
};
