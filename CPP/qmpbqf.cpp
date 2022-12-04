#pragma once
#define _USE_MATH_DEFINES
#include "qmpbqf.h"
#include "math.h"
#include "windows.h"

DOUBLE sinc(DOUBLE x) {
    return (x == 0.0) ? 1.0 : sin(x) / x;
};

VOID QMPBQF::init(FILTER filter, BAND band, GAIN gain) {
    this->band = band;
    this->gain = gain;
    this->filter = filter;

    return;
};

DOUBLE QMPBQF::calcOmega() {
    try {
        switch (this->gain) {
            case gtDb:
                return sqrt(pow(10, this->amp / 20));
                break;
            case gtAmp:
                return sqrt(this->amp);
                break;
        };
    } catch (...) {
    };

    return 0.0;
};

DOUBLE QMPBQF::calcAlpha() {
    try {
        switch (this->band) {
            case btQ:
                return (sin(2 * M_PI * this->freq / this->rate) / 2) * (1 / this->width);
                break;
            case btSlope:
                return (sin(2 * M_PI * this->freq / this->rate) / 2) * sqrt((this->calcOmega() + 1 / this->calcOmega()) * (1 / this->width - 1) + 2);
                break;
            case btOctave:
                return (sin(2 * M_PI * this->freq / this->rate) / 2) * 2 * sinh((M_LN2 / 2) * (this->width / 1) / sinc(2 * M_PI * this->freq / this->rate));
                break;
            case btSemitone:
                return (sin(2 * M_PI * this->freq / this->rate) / 2) * 2 * sinh((M_LN2 / 2) * (this->width / 12) / sinc(2 * M_PI * this->freq / this->rate));
                break;
        };
    } catch (...) {
    };

    return 0.0;
};

VOID QMPBQF::calcConfig() {
    try {
        switch (this->filter) {
            case ftEqu:
                this->config[0][2] = 1 - this->calcAlpha() * this->calcOmega();
                this->config[0][1] = -2 * cos(2 * M_PI * this->freq / this->rate);
                this->config[0][0] = 1 + this->calcAlpha() * this->calcOmega();
                this->config[1][2] = 1 - this->calcAlpha() / this->calcOmega();
                this->config[1][1] = -2 * cos(2 * M_PI * this->freq / this->rate);
                this->config[1][0] = 1 + this->calcAlpha() / this->calcOmega();
                break;
            case ftInv:
                this->config[0][2] = 1 + this->calcAlpha();
                this->config[0][1] = -2 * cos(2 * M_PI * this->freq / this->rate);
                this->config[0][0] = 1 - this->calcAlpha();
                this->config[1][2] = 1 - this->calcAlpha();
                this->config[1][1] = -2 * cos(2 * M_PI * this->freq / this->rate);
                this->config[1][0] = 1 + this->calcAlpha();
                break;
            case ftLow:
                this->config[0][2] = (1 - cos(2 * M_PI * this->freq / this->rate)) / 2;
                this->config[0][1] = (1 - cos(2 * M_PI * this->freq / this->rate)) / +1;
                this->config[0][0] = (1 - cos(2 * M_PI * this->freq / this->rate)) / 2;
                this->config[1][2] = 1 - this->calcAlpha();
                this->config[1][1] = -2 * cos(2 * M_PI * this->freq / this->rate);
                this->config[1][0] = 1 + this->calcAlpha();
                break;
            case ftHigh:
                this->config[0][2] = (1 + cos(2 * M_PI * this->freq / this->rate)) / 2;
                this->config[0][1] = (1 + cos(2 * M_PI * this->freq / this->rate)) / -1;
                this->config[0][0] = (1 + cos(2 * M_PI * this->freq / this->rate)) / 2;
                this->config[1][2] = 1 - this->calcAlpha();
                this->config[1][1] = -2 * cos(2 * M_PI * this->freq / this->rate);
                this->config[1][0] = 1 + this->calcAlpha();
                break;
            case ftPeak:
                this->config[0][2] = -1 * sin(2 * M_PI * this->freq / this->rate) / 2;
                this->config[0][1] = 0.0;
                this->config[0][0] = +1 * sin(2 * M_PI * this->freq / this->rate) / 2;
                this->config[1][2] = 1 - this->calcAlpha();
                this->config[1][1] = -2 * cos(2 * M_PI * this->freq / this->rate);
                this->config[1][0] = 1 + this->calcAlpha();
                break;
            case ftBand:
                this->config[0][2] = -1 * this->calcAlpha();
                this->config[0][1] = 0.0;
                this->config[0][0] = +1 * this->calcAlpha();
                this->config[1][2] = 1 - this->calcAlpha();
                this->config[1][1] = -2 * cos(2 * M_PI * this->freq / this->rate);
                this->config[1][0] = 1 + this->calcAlpha();
                break;
            case ftNotch:
                this->config[0][2] = 1;
                this->config[0][1] = -2 * cos(2 * M_PI * this->freq / this->rate);
                this->config[0][0] = 1;
                this->config[1][2] = 1 - this->calcAlpha();
                this->config[1][1] = -2 * cos(2 * M_PI * this->freq / this->rate);
                this->config[1][0] = 1 + this->calcAlpha();
                break;
            case ftBass:
                this->config[0][2] = this->calcOmega() * ((this->calcOmega() + 1) - (this->calcOmega() - 1) * cos(2 * M_PI * this->freq / this->rate) - 2 * sqrt(this->calcOmega()) * this->calcAlpha());
                this->config[0][1] = +2 * this->calcOmega() * ((this->calcOmega() - 1) - (this->calcOmega() + 1) * cos(2 * M_PI * this->freq / this->rate));
                this->config[0][0] = this->calcOmega() * ((this->calcOmega() + 1) - (this->calcOmega() - 1) * cos(2 * M_PI * this->freq / this->rate) + 2 * sqrt(this->calcOmega()) * this->calcAlpha());
                this->config[1][2] = (this->calcOmega() + 1) + (this->calcOmega() - 1) * cos(2 * M_PI * this->freq / this->rate) - 2 * sqrt(this->calcOmega()) * this->calcAlpha();
                this->config[1][1] = -2 * 1 * ((this->calcOmega() - 1) + (this->calcOmega() + 1) * cos(2 * M_PI * this->freq / this->rate));
                this->config[1][0] = (this->calcOmega() + 1) + (this->calcOmega() - 1) * cos(2 * M_PI * this->freq / this->rate) + 2 * sqrt(this->calcOmega()) * this->calcAlpha();
                break;
            case ftTreble:
                this->config[0][2] = this->calcOmega() * ((this->calcOmega() + 1) + (this->calcOmega() - 1) * cos(2 * M_PI * this->freq / this->rate) - 2 * sqrt(this->calcOmega()) * this->calcAlpha());
                this->config[0][1] = -2 * this->calcOmega() * ((this->calcOmega() - 1) + (this->calcOmega() + 1) * cos(2 * M_PI * this->freq / this->rate));
                this->config[0][0] = this->calcOmega() * ((this->calcOmega() + 1) + (this->calcOmega() - 1) * cos(2 * M_PI * this->freq / this->rate) + 2 * sqrt(this->calcOmega()) * this->calcAlpha());
                this->config[1][2] = (this->calcOmega() + 1) - (this->calcOmega() - 1) * cos(2 * M_PI * this->freq / this->rate) - 2 * sqrt(this->calcOmega()) * this->calcAlpha();
                this->config[1][1] = +2 * 1 * ((this->calcOmega() - 1) - (this->calcOmega() + 1) * cos(2 * M_PI * this->freq / this->rate));
                this->config[1][0] = (this->calcOmega() + 1) - (this->calcOmega() - 1) * cos(2 * M_PI * this->freq / this->rate) + 2 * sqrt(this->calcOmega()) * this->calcAlpha();
                break;
        };
    } catch (...) {
    };

    return;
};

DOUBLE QMPBQF::process(DOUBLE input) {
    try {
        this->signal[0][2] = this->signal[0][1];
        this->signal[0][1] = this->signal[0][0];
        this->signal[0][0] = input;
        this->signal[1][2] = this->signal[1][1];
        this->signal[1][1] = this->signal[1][0];
        this->signal[1][0] = ((this->signal[0][0] * this->config[0][0] + this->signal[0][1] * this->config[0][1] + this->signal[0][2] * this->config[0][2]) - (this->signal[1][1] * this->config[1][1] + this->signal[1][2] * this->config[1][2])) / this->config[1][0];
    } catch (...) {
    };

    return this->signal[1][0];
};

BAND QMPBQF::getBand() {
    return this->band;
};

GAIN QMPBQF::getGain() {
    return this->gain;
};

FILTER QMPBQF::getFilter() {
    return this->filter;
};

DOUBLE QMPBQF::getAmp() {
    return this->amp;
};

VOID QMPBQF::setAmp(DOUBLE value) {
    if (this->amp != value) {
        this->amp = value;
        this->calcConfig();
    };

    return;
};

DOUBLE QMPBQF::getFreq() {
    return this->freq;
};

VOID QMPBQF::setFreq(DOUBLE value) {
    if (this->freq != value) {
        this->freq = value;
        this->calcConfig();
    };

    return;
};

DOUBLE QMPBQF::getRate() {
    return this->rate;
};

VOID QMPBQF::setRate(DOUBLE value) {
    if (this->rate != value) {
        this->rate = value;
        this->calcConfig();
    };

    return;
};

DOUBLE QMPBQF::getWidth() {
    return this->width;
};

VOID QMPBQF::setWidth(DOUBLE value) {
    if (this->width != value) {
        this->width = value;
        this->calcConfig();
    };

    return;
};
