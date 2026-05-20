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
    DOUBLE val;

    VOID addSample(DOUBLE value) {
        if (this->val * abs(value) < 1.0) {
            this->sqr -= (this->sqr - pow(value, 2.0)) / (5.0 * this->bqf.getRate());
            this->avg -= (this->avg - abs(value)) / (5.0 * this->bqf.getRate());
        }
        else {
            this->sqr -= (this->sqr - pow(value, 2.0)) / (0.5 * this->bqf.getRate());
            this->avg -= (this->avg - abs(value)) / (0.5 * this->bqf.getRate());
        };
        this->val = fmin(fmax(1.0 / this->calcAmp(), 1.0 / (this->avg + 3.0 * sqrt(this->sqr - pow(this->avg, 2.0)))), 1.0 * this->calcAmp());
    };
public:
    VOID init(TRANSFORM transform, FILTER filter, BAND band, GAIN gain) {
        this->bqf.init(transform, filter, band, gain);
    };

    DOUBLE process(DOUBLE value) {
        this->addSample(this->bqf.process(value));
        return this->val * value;
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
                return log10(this->val) * 20.0;
            };
            break;
            case gtAmp: {
                return this->val;
            };
            break;
            default: {
                return 0.0;
            };
            break;
        };
    };

    VOID setAmp(DOUBLE value) {
        switch (this->bqf.getGain()) {
            case gtDb: {
                this->amp = pow(10.0, value / 20.0);
            };
            break;
            case gtAmp: {
                this->amp = value;
            };
            break;
            default: {
                this->amp = 0.0;
            };
            break;
        };
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
