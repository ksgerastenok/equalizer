#pragma once
#include "qmpbqf.h"
#include "windows.h"
#include "cmath"
#include "numbers"

using namespace std;

VOID QMPBQF::init(const TRANSFORM transform, const FILTER filter, const BAND band, const GAIN gain) {
    this->band = band;
    this->gain = gain;
    this->filter = filter;
    this->transform = transform;

    return;
};

DOUBLE QMPBQF::calcOmega() {
    return 2.0 * numbers::pi * this->freq / this->rate;
}

DOUBLE QMPBQF::calcAmp() {
    switch (this->gain) {
    case gtDb:
        return pow(10.0, this->amp / 20.0);
        break;
    case gtAmp:
        return this->amp;
        break;
    default:
        return 0.0;
        break;
    };
};

DOUBLE QMPBQF::calcAlpha() {
    switch (this->band) {
    case btQ:
        return (1.0 / this->width);
        break;
    case btSlope:
        return pow(pow(this->calcAmp(), 0.5) * (1.0 / this->calcAmp() + 1.0) * (1.0 / this->width - 1.0) + 2.0, 0.5);
        break;
    case btOctave:
        return 2.0 * sinh((numbers::ln2 / 2.0) * this->width / (sin(this->calcOmega()) / this->calcOmega()));
        break;
    default:
        return 0.0;
        break;
    };
};

VOID QMPBQF::calcConfig() {
    switch (this->transform) {
    case ptLAT:
        switch (this->filter) {
        case ftLow:
            this->config[0][2] = 1.0 * ((1.0 - cos(this->calcOmega())) / 2.0);
            this->config[0][1] = +2.0 * ((1.0 - cos(this->calcOmega())) / 2.0);
            this->config[0][0] = 1.0 * ((1.0 - cos(this->calcOmega())) / 2.0);
            this->config[1][2] = 1.0 - (sin(this->calcOmega()) / 2.0) * this->calcAlpha();
            this->config[1][1] = -2.0 * (cos(this->calcOmega()));
            this->config[1][0] = 1.0 + (sin(this->calcOmega()) / 2.0) * this->calcAlpha();
            break;
        case ftHigh:
            this->config[0][2] = 1.0 * ((1.0 + cos(this->calcOmega())) / 2.0);
            this->config[0][1] = -2.0 * ((1.0 + cos(this->calcOmega())) / 2.0);
            this->config[0][0] = 1.0 * ((1.0 + cos(this->calcOmega())) / 2.0);
            this->config[1][2] = 1.0 - (sin(this->calcOmega()) / 2.0) * this->calcAlpha();
            this->config[1][1] = -2.0 * (cos(this->calcOmega()));
            this->config[1][0] = 1.0 + (sin(this->calcOmega()) / 2.0) * this->calcAlpha();
            break;
        case ftPeak:
            this->config[0][2] = 0.0 - (sin(this->calcOmega()) / 2.0) * 1.0;
            this->config[0][1] = 0.0;
            this->config[0][0] = 0.0 + (sin(this->calcOmega()) / 2.0) * 1.0;
            this->config[1][2] = 1.0 - (sin(this->calcOmega()) / 2.0) * this->calcAlpha();
            this->config[1][1] = -2.0 * (cos(this->calcOmega()));
            this->config[1][0] = 1.0 + (sin(this->calcOmega()) / 2.0) * this->calcAlpha();
            break;
        case ftBand:
            this->config[0][2] = 0.0 - (sin(this->calcOmega()) / 2.0) * this->calcAlpha();
            this->config[0][1] = 0.0;
            this->config[0][0] = 0.0 + (sin(this->calcOmega()) / 2.0) * this->calcAlpha();
            this->config[1][2] = 1.0 - (sin(this->calcOmega()) / 2.0) * this->calcAlpha();
            this->config[1][1] = -2.0 * (cos(this->calcOmega()));
            this->config[1][0] = 1.0 + (sin(this->calcOmega()) / 2.0) * this->calcAlpha();
            break;
        case ftNotch:
            this->config[0][2] = 1.0;
            this->config[0][1] = -2.0 * (cos(this->calcOmega()));
            this->config[0][0] = 1.0;
            this->config[1][2] = 1.0 - (sin(this->calcOmega()) / 2.0) * this->calcAlpha();
            this->config[1][1] = -2.0 * (cos(this->calcOmega()));
            this->config[1][0] = 1.0 + (sin(this->calcOmega()) / 2.0) * this->calcAlpha();
            break;
        case ftAll:
            this->config[0][2] = 1.0 + (sin(this->calcOmega()) / 2.0) * this->calcAlpha();
            this->config[0][1] = -2.0 * (cos(this->calcOmega()));
            this->config[0][0] = 1.0 - (sin(this->calcOmega()) / 2.0) * this->calcAlpha();
            this->config[1][2] = 1.0 - (sin(this->calcOmega()) / 2.0) * this->calcAlpha();
            this->config[1][1] = -2.0 * (cos(this->calcOmega()));
            this->config[1][0] = 1.0 + (sin(this->calcOmega()) / 2.0) * this->calcAlpha();
            break;
        case ftEqu:
            this->config[0][2] = 1.0 - (sin(this->calcOmega()) / 2.0) * this->calcAlpha() * pow(this->calcAmp(), 0.5);
            this->config[0][1] = -2.0 * (cos(this->calcOmega()));
            this->config[0][0] = 1.0 + (sin(this->calcOmega()) / 2.0) * this->calcAlpha() * pow(this->calcAmp(), 0.5);
            this->config[1][2] = 1.0 - (sin(this->calcOmega()) / 2.0) * this->calcAlpha() / pow(this->calcAmp(), 0.5);
            this->config[1][1] = -2.0 * (cos(this->calcOmega()));
            this->config[1][0] = 1.0 + (sin(this->calcOmega()) / 2.0) * this->calcAlpha() / pow(this->calcAmp(), 0.5);
            break;
        case ftBass:
            this->config[0][2] = 1.0 * pow(this->calcAmp(), 0.5) * ((pow(this->calcAmp(), 0.5) + 1.0) - (pow(this->calcAmp(), 0.5) - 1.0) * cos(this->calcOmega()) - 2.0 * pow(this->calcAmp(), 0.25) * (sin(this->calcOmega()) / 2.0) * this->calcAlpha());
            this->config[0][1] = +2.0 * pow(this->calcAmp(), 0.5) * ((pow(this->calcAmp(), 0.5) - 1.0) - (pow(this->calcAmp(), 0.5) + 1.0) * cos(this->calcOmega()));
            this->config[0][0] = 1.0 * pow(this->calcAmp(), 0.5) * ((pow(this->calcAmp(), 0.5) + 1.0) - (pow(this->calcAmp(), 0.5) - 1.0) * cos(this->calcOmega()) + 2.0 * pow(this->calcAmp(), 0.25) * (sin(this->calcOmega()) / 2.0) * this->calcAlpha());
            this->config[1][2] = 1.0 * 1.0 * ((pow(this->calcAmp(), 0.5) + 1.0) + (pow(this->calcAmp(), 0.5) - 1.0) * cos(this->calcOmega()) - 2.0 * pow(this->calcAmp(), 0.25) * (sin(this->calcOmega()) / 2.0) * this->calcAlpha());
            this->config[1][1] = -2.0 * 1.0 * ((pow(this->calcAmp(), 0.5) - 1.0) + (pow(this->calcAmp(), 0.5) + 1.0) * cos(this->calcOmega()));
            this->config[1][0] = 1.0 * 1.0 * ((pow(this->calcAmp(), 0.5) + 1.0) + (pow(this->calcAmp(), 0.5) - 1.0) * cos(this->calcOmega()) + 2.0 * pow(this->calcAmp(), 0.25) * (sin(this->calcOmega()) / 2.0) * this->calcAlpha());
            break;
        case ftTreble:
            this->config[0][2] = 1.0 * pow(this->calcAmp(), 0.5) * ((pow(this->calcAmp(), 0.5) + 1.0) + (pow(this->calcAmp(), 0.5) - 1.0) * cos(this->calcOmega()) - 2.0 * pow(this->calcAmp(), 0.25) * (sin(this->calcOmega()) / 2.0) * this->calcAlpha());
            this->config[0][1] = -2.0 * pow(this->calcAmp(), 0.5) * ((pow(this->calcAmp(), 0.5) - 1.0) + (pow(this->calcAmp(), 0.5) + 1.0) * cos(this->calcOmega()));
            this->config[0][0] = 1.0 * pow(this->calcAmp(), 0.5) * ((pow(this->calcAmp(), 0.5) + 1.0) + (pow(this->calcAmp(), 0.5) - 1.0) * cos(this->calcOmega()) + 2.0 * pow(this->calcAmp(), 0.25) * (sin(this->calcOmega()) / 2.0) * this->calcAlpha());
            this->config[1][2] = 1.0 * 1.0 * ((pow(this->calcAmp(), 0.5) + 1.0) - (pow(this->calcAmp(), 0.5) - 1.0) * cos(this->calcOmega()) - 2.0 * pow(this->calcAmp(), 0.25) * (sin(this->calcOmega()) / 2.0) * this->calcAlpha());
            this->config[1][1] = +2.0 * 1.0 * ((pow(this->calcAmp(), 0.5) - 1.0) - (pow(this->calcAmp(), 0.5) + 1.0) * cos(this->calcOmega()));
            this->config[1][0] = 1.0 * 1.0 * ((pow(this->calcAmp(), 0.5) + 1.0) - (pow(this->calcAmp(), 0.5) - 1.0) * cos(this->calcOmega()) + 2.0 * pow(this->calcAmp(), 0.25) * (sin(this->calcOmega()) / 2.0) * this->calcAlpha());
            break;
        default:
            this->config[0][2] = 0.0;
            this->config[0][1] = 0.0;
            this->config[0][0] = 0.0;
            this->config[1][2] = 0.0;
            this->config[1][1] = 0.0;
            this->config[1][0] = 0.0;
            break;
        };
        break;
    case ptSVF:
        switch (this->filter) {
        case ftLow:
            this->config[0][2] = 1.0 * pow(tan(this->calcOmega() / 2.0), 2.0);
            this->config[0][1] = +2.0 * pow(tan(this->calcOmega() / 2.0), 2.0);
            this->config[0][0] = 1.0 * pow(tan(this->calcOmega() / 2.0), 2.0);
            this->config[1][2] = 1.0 - tan(this->calcOmega() / 2.0) * this->calcAlpha() + pow(tan(this->calcOmega() / 2.0), 2.0);
            this->config[1][1] = +2.0 * (pow(tan(this->calcOmega() / 2.0), 2.0) - 1.0);
            this->config[1][0] = 1.0 + tan(this->calcOmega() / 2.0) * this->calcAlpha() + pow(tan(this->calcOmega() / 2.0), 2.0);
            break;
        case ftHigh:
            this->config[0][2] = 1.0;
            this->config[0][1] = -2.0;
            this->config[0][0] = 1.0;
            this->config[1][2] = 1.0 - tan(this->calcOmega() / 2.0) * this->calcAlpha() + pow(tan(this->calcOmega() / 2.0), 2.0);
            this->config[1][1] = +2.0 * (pow(tan(this->calcOmega() / 2.0), 2.0) - 1.0);
            this->config[1][0] = 1.0 + tan(this->calcOmega() / 2.0) * this->calcAlpha() + pow(tan(this->calcOmega() / 2.0), 2.0);
            break;
        case ftPeak:
            this->config[0][2] = 0.0 - tan(this->calcOmega() / 2.0);
            this->config[0][1] = 0.0;
            this->config[0][0] = 0.0 + tan(this->calcOmega() / 2.0);
            this->config[1][2] = 1.0 - tan(this->calcOmega() / 2.0) * this->calcAlpha() + pow(tan(this->calcOmega() / 2.0), 2.0);
            this->config[1][1] = +2.0 * (pow(tan(this->calcOmega() / 2.0), 2.0) - 1.0);
            this->config[1][0] = 1.0 + tan(this->calcOmega() / 2.0) * this->calcAlpha() + pow(tan(this->calcOmega() / 2.0), 2.0);
            break;
        case ftBand:
            this->config[0][2] = 0.0 - tan(this->calcOmega() / 2.0) * this->calcAlpha();
            this->config[0][1] = 0.0;
            this->config[0][0] = 0.0 + tan(this->calcOmega() / 2.0) * this->calcAlpha();
            this->config[1][2] = 1.0 - tan(this->calcOmega() / 2.0) * this->calcAlpha() + pow(tan(this->calcOmega() / 2.0), 2.0);
            this->config[1][1] = +2.0 * (pow(tan(this->calcOmega() / 2.0), 2.0) - 1.0);
            this->config[1][0] = 1.0 + tan(this->calcOmega() / 2.0) * this->calcAlpha() + pow(tan(this->calcOmega() / 2.0), 2.0);
            break;
        case ftNotch:
            this->config[0][2] = 1.0 + (pow(tan(this->calcOmega() / 2.0), 2.0));
            this->config[0][1] = +2.0 * (pow(tan(this->calcOmega() / 2.0), 2.0) - 1.0);
            this->config[0][0] = 1.0 + (pow(tan(this->calcOmega() / 2.0), 2.0));
            this->config[1][2] = 1.0 - tan(this->calcOmega() / 2.0) * this->calcAlpha() + pow(tan(this->calcOmega() / 2.0), 2.0);
            this->config[1][1] = +2.0 * (pow(tan(this->calcOmega() / 2.0), 2.0) - 1.0);
            this->config[1][0] = 1.0 + tan(this->calcOmega() / 2.0) * this->calcAlpha() + pow(tan(this->calcOmega() / 2.0), 2.0);
            break;
        case ftAll:
            this->config[0][2] = 1.0 + tan(this->calcOmega() / 2.0) * this->calcAlpha() + pow(tan(this->calcOmega() / 2.0), 2.0);
            this->config[0][1] = +2.0 * (pow(tan(this->calcOmega() / 2.0), 2.0) - 1.0);
            this->config[0][0] = 1.0 - tan(this->calcOmega() / 2.0) * this->calcAlpha() + pow(tan(this->calcOmega() / 2.0), 2.0);
            this->config[1][2] = 1.0 - tan(this->calcOmega() / 2.0) * this->calcAlpha() + pow(tan(this->calcOmega() / 2.0), 2.0);
            this->config[1][1] = +2.0 * (pow(tan(this->calcOmega() / 2.0), 2.0) - 1.0);
            this->config[1][0] = 1.0 + tan(this->calcOmega() / 2.0) * this->calcAlpha() + pow(tan(this->calcOmega() / 2.0), 2.0);
            break;
        case ftEqu:
            this->config[0][2] = 1.0 - tan(this->calcOmega() / 2.0) * this->calcAlpha() * this->calcAmp() + pow(tan(this->calcOmega() / 2.0), 2.0);
            this->config[0][1] = +2.0 * (pow(tan(this->calcOmega() / 2.0), 2.0) - 1.0);
            this->config[0][0] = 1.0 + tan(this->calcOmega() / 2.0) * this->calcAlpha() * this->calcAmp() + pow(tan(this->calcOmega() / 2.0), 2.0);
            this->config[1][2] = 1.0 - tan(this->calcOmega() / 2.0) * this->calcAlpha() *       1.0       + pow(tan(this->calcOmega() / 2.0), 2.0);
            this->config[1][1] = +2.0 * (pow(tan(this->calcOmega() / 2.0), 2.0) - 1.0);
            this->config[1][0] = 1.0 + tan(this->calcOmega() / 2.0) * this->calcAlpha() *       1.0       + pow(tan(this->calcOmega() / 2.0), 2.0);
            break;
        case ftBass:
            this->config[0][2] = (      1.0       - tan(this->calcOmega() / 2.0) * this->calcAlpha() *            1.0            + pow(tan(this->calcOmega() / 2.0), 2.0)) /       1.0      ;
            this->config[0][1] = +2.0 * (pow(tan(this->calcOmega() / 2.0), 2.0) -       1.0      ) /       1.0      ;
            this->config[0][0] = (      1.0       + tan(this->calcOmega() / 2.0) * this->calcAlpha() *            1.0            + pow(tan(this->calcOmega() / 2.0), 2.0)) /       1.0      ;
            this->config[1][2] = (this->calcAmp() - tan(this->calcOmega() / 2.0) * this->calcAlpha() * pow(this->calcAmp(), 0.5) + pow(tan(this->calcOmega() / 2.0), 2.0)) / this->calcAmp();
            this->config[1][1] = +2.0 * (pow(tan(this->calcOmega() / 2.0), 2.0) - this->calcAmp()) / this->calcAmp();
            this->config[1][0] = (this->calcAmp() + tan(this->calcOmega() / 2.0) * this->calcAlpha() * pow(this->calcAmp(), 0.5) + pow(tan(this->calcOmega() / 2.0), 2.0)) / this->calcAmp();
            break;
        case ftTreble:
            this->config[0][2] = (this->calcAmp() - tan(this->calcOmega() / 2.0) * this->calcAlpha() * pow(this->calcAmp(), 0.5) + pow(tan(this->calcOmega() / 2.0), 2.0));
            this->config[0][1] = +2.0 * (pow(tan(this->calcOmega() / 2.0), 2.0) - this->calcAmp());
            this->config[0][0] = (this->calcAmp() + tan(this->calcOmega() / 2.0) * this->calcAlpha() * pow(this->calcAmp(), 0.5) + pow(tan(this->calcOmega() / 2.0), 2.0));
            this->config[1][2] = (      1.0       - tan(this->calcOmega() / 2.0) * this->calcAlpha() *            1.0            + pow(tan(this->calcOmega() / 2.0), 2.0));
            this->config[1][1] = +2.0 * (pow(tan(this->calcOmega() / 2.0), 2.0) -       1.0      );
            this->config[1][0] = (      1.0       + tan(this->calcOmega() / 2.0) * this->calcAlpha() *            1.0            + pow(tan(this->calcOmega() / 2.0), 2.0));
            break;
        default:
            this->config[0][2] = 0.0;
            this->config[0][1] = 0.0;
            this->config[0][0] = 0.0;
            this->config[1][2] = 0.0;
            this->config[1][1] = 0.0;
            this->config[1][0] = 0.0;
            break;
        };
        break;
    case ptZDF:
        switch (this->filter) {
        case ftLow:
            this->config[0][2] = 1.0 * pow(tan(this->calcOmega() / 2.0), 2.0);
            this->config[0][1] = +2.0 * pow(tan(this->calcOmega() / 2.0), 2.0);
            this->config[0][0] = 1.0 * pow(tan(this->calcOmega() / 2.0), 2.0);
            this->config[1][2] = 1.0 - tan(this->calcOmega() / 2.0) * this->calcAlpha() + pow(tan(this->calcOmega() / 2.0), 2.0);
            this->config[1][1] = +2.0 * (pow(tan(this->calcOmega() / 2.0), 2.0) - 1.0);
            this->config[1][0] = 1.0 + tan(this->calcOmega() / 2.0) * this->calcAlpha() + pow(tan(this->calcOmega() / 2.0), 2.0);
            break;
        case ftHigh:
            this->config[0][2] = 1.0;
            this->config[0][1] = -2.0;
            this->config[0][0] = 1.0;
            this->config[1][2] = 1.0 - tan(this->calcOmega() / 2.0) * this->calcAlpha() + pow(tan(this->calcOmega() / 2.0), 2.0);
            this->config[1][1] = +2.0 * (pow(tan(this->calcOmega() / 2.0), 2.0) - 1.0);
            this->config[1][0] = 1.0 + tan(this->calcOmega() / 2.0) * this->calcAlpha() + pow(tan(this->calcOmega() / 2.0), 2.0);
            break;
        case ftPeak:
            this->config[0][2] = 0.0 - tan(this->calcOmega() / 2.0);
            this->config[0][1] = 0.0;
            this->config[0][0] = 0.0 + tan(this->calcOmega() / 2.0);
            this->config[1][2] = 1.0 - tan(this->calcOmega() / 2.0) * this->calcAlpha() + pow(tan(this->calcOmega() / 2.0), 2.0);
            this->config[1][1] = +2.0 * (pow(tan(this->calcOmega() / 2.0), 2.0) - 1.0);
            this->config[1][0] = 1.0 + tan(this->calcOmega() / 2.0) * this->calcAlpha() + pow(tan(this->calcOmega() / 2.0), 2.0);
            break;
        case ftBand:
            this->config[0][2] = 0.0 - tan(this->calcOmega() / 2.0) * this->calcAlpha();
            this->config[0][1] = 0.0;
            this->config[0][0] = 0.0 + tan(this->calcOmega() / 2.0) * this->calcAlpha();
            this->config[1][2] = 1.0 - tan(this->calcOmega() / 2.0) * this->calcAlpha() + pow(tan(this->calcOmega() / 2.0), 2.0);
            this->config[1][1] = +2.0 * (pow(tan(this->calcOmega() / 2.0), 2.0) - 1.0);
            this->config[1][0] = 1.0 + tan(this->calcOmega() / 2.0) * this->calcAlpha() + pow(tan(this->calcOmega() / 2.0), 2.0);
            break;
        case ftNotch:
            this->config[0][2] = 1.0 + (pow(tan(this->calcOmega() / 2.0), 2.0));
            this->config[0][1] = +2.0 * (pow(tan(this->calcOmega() / 2.0), 2.0) - 1.0);
            this->config[0][0] = 1.0 + (pow(tan(this->calcOmega() / 2.0), 2.0));
            this->config[1][2] = 1.0 - tan(this->calcOmega() / 2.0) * this->calcAlpha() + pow(tan(this->calcOmega() / 2.0), 2.0);
            this->config[1][1] = +2.0 * (pow(tan(this->calcOmega() / 2.0), 2.0) - 1.0);
            this->config[1][0] = 1.0 + tan(this->calcOmega() / 2.0) * this->calcAlpha() + pow(tan(this->calcOmega() / 2.0), 2.0);
            break;
        case ftAll:
            this->config[0][2] = 1.0 + tan(this->calcOmega() / 2.0) * this->calcAlpha() + pow(tan(this->calcOmega() / 2.0), 2.0);
            this->config[0][1] = +2.0 * (pow(tan(this->calcOmega() / 2.0), 2.0) - 1.0);
            this->config[0][0] = 1.0 - tan(this->calcOmega() / 2.0) * this->calcAlpha() + pow(tan(this->calcOmega() / 2.0), 2.0);
            this->config[1][2] = 1.0 - tan(this->calcOmega() / 2.0) * this->calcAlpha() + pow(tan(this->calcOmega() / 2.0), 2.0);
            this->config[1][1] = +2.0 * (pow(tan(this->calcOmega() / 2.0), 2.0) - 1.0);
            this->config[1][0] = 1.0 + tan(this->calcOmega() / 2.0) * this->calcAlpha() + pow(tan(this->calcOmega() / 2.0), 2.0);
            break;
        case ftEqu:
            this->config[0][2] = 1.0 - tan(this->calcOmega() / 2.0) * this->calcAlpha() /       1.0       + pow(tan(this->calcOmega() / 2.0), 2.0);
            this->config[0][1] = +2.0 * (pow(tan(this->calcOmega() / 2.0), 2.0) - 1.0);
            this->config[0][0] = 1.0 + tan(this->calcOmega() / 2.0) * this->calcAlpha() /       1.0       + pow(tan(this->calcOmega() / 2.0), 2.0);
            this->config[1][2] = 1.0 - tan(this->calcOmega() / 2.0) * this->calcAlpha() / this->calcAmp() + pow(tan(this->calcOmega() / 2.0), 2.0);
            this->config[1][1] = +2.0 * (pow(tan(this->calcOmega() / 2.0), 2.0) - 1.0);
            this->config[1][0] = 1.0 + tan(this->calcOmega() / 2.0) * this->calcAlpha() / this->calcAmp() + pow(tan(this->calcOmega() / 2.0), 2.0);
            break;
        case ftBass:
            this->config[0][2] = (1.0 - tan(this->calcOmega() / 2.0) * this->calcAlpha() * pow(this->calcAmp(), 0.5) + pow(tan(this->calcOmega() / 2.0), 2.0) * this->calcAmp());
            this->config[0][1] = +2.0 * (pow(tan(this->calcOmega() / 2.0), 2.0) * this->calcAmp() - 1.0);
            this->config[0][0] = (1.0 + tan(this->calcOmega() / 2.0) * this->calcAlpha() * pow(this->calcAmp(), 0.5) + pow(tan(this->calcOmega() / 2.0), 2.0) * this->calcAmp());
            this->config[1][2] = (1.0 - tan(this->calcOmega() / 2.0) * this->calcAlpha() *             1.0           + pow(tan(this->calcOmega() / 2.0), 2.0) *       1.0      );
            this->config[1][1] = +2.0 * (pow(tan(this->calcOmega() / 2.0), 2.0) *       1.0       - 1.0);
            this->config[1][0] = (1.0 + tan(this->calcOmega() / 2.0) * this->calcAlpha() *             1.0           + pow(tan(this->calcOmega() / 2.0), 2.0) *       1.0      );
            break;
        case ftTreble:
            this->config[0][2] = (1.0 - tan(this->calcOmega() / 2.0) * this->calcAlpha() *             1.0           + pow(tan(this->calcOmega() / 2.0), 2.0) *       1.0      ) /       1.0      ;
            this->config[0][1] = +2.0 * (pow(tan(this->calcOmega() / 2.0), 2.0) *       1.0       - 1.0) /       1.0      ;
            this->config[0][0] = (1.0 + tan(this->calcOmega() / 2.0) * this->calcAlpha() *             1.0           + pow(tan(this->calcOmega() / 2.0), 2.0) *       1.0      ) /       1.0      ;
            this->config[1][2] = (1.0 - tan(this->calcOmega() / 2.0) * this->calcAlpha() * pow(this->calcAmp(), 0.5) + pow(tan(this->calcOmega() / 2.0), 2.0) * this->calcAmp()) / this->calcAmp();
            this->config[1][1] = +2.0 * (pow(tan(this->calcOmega() / 2.0), 2.0) * this->calcAmp() - 1.0) / this->calcAmp();
            this->config[1][0] = (1.0 + tan(this->calcOmega() / 2.0) * this->calcAlpha() * pow(this->calcAmp(), 0.5) + pow(tan(this->calcOmega() / 2.0), 2.0) * this->calcAmp()) / this->calcAmp();
            break;
        default:
            this->config[0][2] = 0.0;
            this->config[0][1] = 0.0;
            this->config[0][0] = 0.0;
            this->config[1][2] = 0.0;
            this->config[1][1] = 0.0;
            this->config[1][0] = 0.0;
            break;
        };
        break;
    default:
        this->config[0][2] = 0.0;
        this->config[0][1] = 0.0;
        this->config[0][0] = 0.0;
        this->config[1][2] = 0.0;
        this->config[1][1] = 0.0;
        this->config[1][0] = 0.0;
        break;
    };

    return;
};

DOUBLE QMPBQF::process(const DOUBLE input) {
    switch (this->transform) {
    case ptLAT:
        this->signal[0][2] = this->signal[0][1];
        this->signal[0][1] = this->signal[0][0];
        this->signal[0][0] = input;
        this->signal[1][2] = this->signal[1][1];
        this->signal[1][1] = this->signal[1][0];
        this->signal[1][0] = ((this->signal[0][0] * this->config[0][0] + this->signal[0][1] * this->config[0][1] + this->signal[0][2] * this->config[0][2]) - (this->signal[1][1] * this->config[1][1] + this->signal[1][2] * this->config[1][2])) / this->config[1][0];
        break;
    case ptSVF:
        this->signal[0][2] = this->signal[0][1];
        this->signal[0][1] = this->signal[0][0];
        this->signal[0][0] = input;
        this->signal[1][2] = this->signal[1][1];
        this->signal[1][1] = this->signal[1][0];
        this->signal[1][0] = ((this->signal[0][0] * this->config[0][0] + this->signal[0][1] * this->config[0][1] + this->signal[0][2] * this->config[0][2]) - (this->signal[1][1] * this->config[1][1] + this->signal[1][2] * this->config[1][2])) / this->config[1][0];
        break;
    case ptZDF:
        this->signal[0][2] = this->signal[0][1];
        this->signal[0][1] = this->signal[0][0];
        this->signal[0][0] = input;
        this->signal[1][2] = this->signal[1][1];
        this->signal[1][1] = this->signal[1][0];
        this->signal[1][0] = ((this->signal[0][0] * this->config[0][0] + this->signal[0][1] * this->config[0][1] + this->signal[0][2] * this->config[0][2]) - (this->signal[1][1] * this->config[1][1] + this->signal[1][2] * this->config[1][2])) / this->config[1][0];
        break;
    default:
        this->signal[0][2] = 0.0;
        this->signal[0][1] = 0.0;
        this->signal[0][0] = 0.0;
        this->signal[1][2] = 0.0;
        this->signal[1][1] = 0.0;
        this->signal[1][0] = 0.0;
        break;
    }

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

VOID QMPBQF::setAmp(const DOUBLE value) {
    if (this->amp != value) {
        this->amp = value;
        this->calcConfig();
    };

    return;
};

DOUBLE QMPBQF::getFreq() {
    return this->freq;
};

VOID QMPBQF::setFreq(const DOUBLE value) {
    if (this->freq != value) {
        this->freq = value;
        this->calcConfig();
    };

    return;
};

DOUBLE QMPBQF::getRate() {
    return this->rate;
};

VOID QMPBQF::setRate(const DOUBLE value) {
    if (this->rate != value) {
        this->rate = value;
        this->calcConfig();
    };

    return;
};

DOUBLE QMPBQF::getWidth() {
    return this->width;
};

VOID QMPBQF::setWidth(const DOUBLE value) {
    if (this->width != value) {
        this->width = value;
        this->calcConfig();
    };

    return;
};
