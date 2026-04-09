#pragma once
#include "windows.h"
#include "array"
#include "cmath"
#include "numbers"

using namespace std;

enum BAND;
enum GAIN;
enum FILTER;
enum TRANSFORM;

struct QMPBQF;
typedef QMPBQF* PQMPBQF;

enum BAND {
    btQ,
    btSlope,
    btOctave
};

enum GAIN {
    gtDb,
    gtAmp
};

enum FILTER {
    ftLow,
    ftHigh,
    ftPeak,
    ftBand,
    ftNotch,
    ftAll,
    ftEqu,
    ftBass,
    ftTreble
};

enum TRANSFORM {
    ptLAT,
    ptSVF,
    ptZDF
};

struct QMPBQF {
private:
    GAIN gain;
    BAND band;
    FILTER filter;
    TRANSFORM transform;
    array<array<DOUBLE, 3>, 2> config;
    array<array<DOUBLE, 3>, 2> signal;
    DOUBLE amp;
    DOUBLE freq;
    DOUBLE rate;
    DOUBLE width;

    DOUBLE calcOmega() {
        return 2.0 * numbers::pi * this->freq / this->rate;
    };

    DOUBLE calcAlpha() {
        switch (this->band) {
        case btQ:
            return (1.0 / this->width);
            break;
        case btSlope:
            return pow(pow(this->getValue(), 0.5) * (1.0 / this->getValue() + 1.0) * (1.0 / this->width - 1.0) + 2.0, 0.5);
            break;
        case btOctave:
            return 2.0 * sinh((numbers::ln2 / 2.0) * this->width / (sin(this->calcOmega()) / this->calcOmega()));
            break;
        default:
            return 0.0;
            break;
        };
    };

    VOID calcConfig() {
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
                this->config[0][2] = 1.0 - (sin(this->calcOmega()) / 2.0) * this->calcAlpha() * pow(this->getValue(), 0.5);
                this->config[0][1] = -2.0 * (cos(this->calcOmega()));
                this->config[0][0] = 1.0 + (sin(this->calcOmega()) / 2.0) * this->calcAlpha() * pow(this->getValue(), 0.5);
                this->config[1][2] = 1.0 - (sin(this->calcOmega()) / 2.0) * this->calcAlpha() / pow(this->getValue(), 0.5);
                this->config[1][1] = -2.0 * (cos(this->calcOmega()));
                this->config[1][0] = 1.0 + (sin(this->calcOmega()) / 2.0) * this->calcAlpha() / pow(this->getValue(), 0.5);
                break;
            case ftBass:
                this->config[0][2] = 1.0 * pow(this->getValue(), 0.5) * ((pow(this->getValue(), 0.5) + 1.0) - (pow(this->getValue(), 0.5) - 1.0) * cos(this->calcOmega()) - 2.0 * pow(this->getValue(), 0.25) * (sin(this->calcOmega()) / 2.0) * this->calcAlpha());
                this->config[0][1] = +2.0 * pow(this->getValue(), 0.5) * ((pow(this->getValue(), 0.5) - 1.0) - (pow(this->getValue(), 0.5) + 1.0) * cos(this->calcOmega()));
                this->config[0][0] = 1.0 * pow(this->getValue(), 0.5) * ((pow(this->getValue(), 0.5) + 1.0) - (pow(this->getValue(), 0.5) - 1.0) * cos(this->calcOmega()) + 2.0 * pow(this->getValue(), 0.25) * (sin(this->calcOmega()) / 2.0) * this->calcAlpha());
                this->config[1][2] = 1.0 * 1.0 * ((pow(this->getValue(), 0.5) + 1.0) + (pow(this->getValue(), 0.5) - 1.0) * cos(this->calcOmega()) - 2.0 * pow(this->getValue(), 0.25) * (sin(this->calcOmega()) / 2.0) * this->calcAlpha());
                this->config[1][1] = -2.0 * 1.0 * ((pow(this->getValue(), 0.5) - 1.0) + (pow(this->getValue(), 0.5) + 1.0) * cos(this->calcOmega()));
                this->config[1][0] = 1.0 * 1.0 * ((pow(this->getValue(), 0.5) + 1.0) + (pow(this->getValue(), 0.5) - 1.0) * cos(this->calcOmega()) + 2.0 * pow(this->getValue(), 0.25) * (sin(this->calcOmega()) / 2.0) * this->calcAlpha());
                break;
            case ftTreble:
                this->config[0][2] = 1.0 * pow(this->getValue(), 0.5) * ((pow(this->getValue(), 0.5) + 1.0) + (pow(this->getValue(), 0.5) - 1.0) * cos(this->calcOmega()) - 2.0 * pow(this->getValue(), 0.25) * (sin(this->calcOmega()) / 2.0) * this->calcAlpha());
                this->config[0][1] = -2.0 * pow(this->getValue(), 0.5) * ((pow(this->getValue(), 0.5) - 1.0) + (pow(this->getValue(), 0.5) + 1.0) * cos(this->calcOmega()));
                this->config[0][0] = 1.0 * pow(this->getValue(), 0.5) * ((pow(this->getValue(), 0.5) + 1.0) + (pow(this->getValue(), 0.5) - 1.0) * cos(this->calcOmega()) + 2.0 * pow(this->getValue(), 0.25) * (sin(this->calcOmega()) / 2.0) * this->calcAlpha());
                this->config[1][2] = 1.0 * 1.0 * ((pow(this->getValue(), 0.5) + 1.0) - (pow(this->getValue(), 0.5) - 1.0) * cos(this->calcOmega()) - 2.0 * pow(this->getValue(), 0.25) * (sin(this->calcOmega()) / 2.0) * this->calcAlpha());
                this->config[1][1] = +2.0 * 1.0 * ((pow(this->getValue(), 0.5) - 1.0) - (pow(this->getValue(), 0.5) + 1.0) * cos(this->calcOmega()));
                this->config[1][0] = 1.0 * 1.0 * ((pow(this->getValue(), 0.5) + 1.0) - (pow(this->getValue(), 0.5) - 1.0) * cos(this->calcOmega()) + 2.0 * pow(this->getValue(), 0.25) * (sin(this->calcOmega()) / 2.0) * this->calcAlpha());
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
                this->config[0][2] = 1.0 - tan(this->calcOmega() / 2.0) * this->calcAlpha() * this->getValue() + pow(tan(this->calcOmega() / 2.0), 2.0);
                this->config[0][1] = +2.0 * (pow(tan(this->calcOmega() / 2.0), 2.0) - 1.0);
                this->config[0][0] = 1.0 + tan(this->calcOmega() / 2.0) * this->calcAlpha() * this->getValue() + pow(tan(this->calcOmega() / 2.0), 2.0);
                this->config[1][2] = 1.0 - tan(this->calcOmega() / 2.0) * this->calcAlpha() * 1.0 + pow(tan(this->calcOmega() / 2.0), 2.0);
                this->config[1][1] = +2.0 * (pow(tan(this->calcOmega() / 2.0), 2.0) - 1.0);
                this->config[1][0] = 1.0 + tan(this->calcOmega() / 2.0) * this->calcAlpha() * 1.0 + pow(tan(this->calcOmega() / 2.0), 2.0);
                break;
            case ftBass:
                this->config[0][2] = (1.0 - tan(this->calcOmega() / 2.0) * this->calcAlpha() * 1.0 + pow(tan(this->calcOmega() / 2.0), 2.0)) / 1.0;
                this->config[0][1] = +2.0 * (pow(tan(this->calcOmega() / 2.0), 2.0) - 1.0) / 1.0;
                this->config[0][0] = (1.0 + tan(this->calcOmega() / 2.0) * this->calcAlpha() * 1.0 + pow(tan(this->calcOmega() / 2.0), 2.0)) / 1.0;
                this->config[1][2] = (this->getValue() - tan(this->calcOmega() / 2.0) * this->calcAlpha() * pow(this->getValue(), 0.5) + pow(tan(this->calcOmega() / 2.0), 2.0)) / this->getValue();
                this->config[1][1] = +2.0 * (pow(tan(this->calcOmega() / 2.0), 2.0) - this->getValue()) / this->getValue();
                this->config[1][0] = (this->getValue() + tan(this->calcOmega() / 2.0) * this->calcAlpha() * pow(this->getValue(), 0.5) + pow(tan(this->calcOmega() / 2.0), 2.0)) / this->getValue();
                break;
            case ftTreble:
                this->config[0][2] = (this->getValue() - tan(this->calcOmega() / 2.0) * this->calcAlpha() * pow(this->getValue(), 0.5) + pow(tan(this->calcOmega() / 2.0), 2.0));
                this->config[0][1] = +2.0 * (pow(tan(this->calcOmega() / 2.0), 2.0) - this->getValue());
                this->config[0][0] = (this->getValue() + tan(this->calcOmega() / 2.0) * this->calcAlpha() * pow(this->getValue(), 0.5) + pow(tan(this->calcOmega() / 2.0), 2.0));
                this->config[1][2] = (1.0 - tan(this->calcOmega() / 2.0) * this->calcAlpha() * 1.0 + pow(tan(this->calcOmega() / 2.0), 2.0));
                this->config[1][1] = +2.0 * (pow(tan(this->calcOmega() / 2.0), 2.0) - 1.0);
                this->config[1][0] = (1.0 + tan(this->calcOmega() / 2.0) * this->calcAlpha() * 1.0 + pow(tan(this->calcOmega() / 2.0), 2.0));
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
                this->config[0][2] = 1.0 - tan(this->calcOmega() / 2.0) * this->calcAlpha() / 1.0 + pow(tan(this->calcOmega() / 2.0), 2.0);
                this->config[0][1] = +2.0 * (pow(tan(this->calcOmega() / 2.0), 2.0) - 1.0);
                this->config[0][0] = 1.0 + tan(this->calcOmega() / 2.0) * this->calcAlpha() / 1.0 + pow(tan(this->calcOmega() / 2.0), 2.0);
                this->config[1][2] = 1.0 - tan(this->calcOmega() / 2.0) * this->calcAlpha() / this->getValue() + pow(tan(this->calcOmega() / 2.0), 2.0);
                this->config[1][1] = +2.0 * (pow(tan(this->calcOmega() / 2.0), 2.0) - 1.0);
                this->config[1][0] = 1.0 + tan(this->calcOmega() / 2.0) * this->calcAlpha() / this->getValue() + pow(tan(this->calcOmega() / 2.0), 2.0);
                break;
            case ftBass:
                this->config[0][2] = (1.0 - tan(this->calcOmega() / 2.0) * this->calcAlpha() * pow(this->getValue(), 0.5) + pow(tan(this->calcOmega() / 2.0), 2.0) * this->getValue());
                this->config[0][1] = +2.0 * (pow(tan(this->calcOmega() / 2.0), 2.0) * this->getValue() - 1.0);
                this->config[0][0] = (1.0 + tan(this->calcOmega() / 2.0) * this->calcAlpha() * pow(this->getValue(), 0.5) + pow(tan(this->calcOmega() / 2.0), 2.0) * this->getValue());
                this->config[1][2] = (1.0 - tan(this->calcOmega() / 2.0) * this->calcAlpha() * 1.0 + pow(tan(this->calcOmega() / 2.0), 2.0) * 1.0);
                this->config[1][1] = +2.0 * (pow(tan(this->calcOmega() / 2.0), 2.0) * 1.0 - 1.0);
                this->config[1][0] = (1.0 + tan(this->calcOmega() / 2.0) * this->calcAlpha() * 1.0 + pow(tan(this->calcOmega() / 2.0), 2.0) * 1.0);
                break;
            case ftTreble:
                this->config[0][2] = (1.0 - tan(this->calcOmega() / 2.0) * this->calcAlpha() * 1.0 + pow(tan(this->calcOmega() / 2.0), 2.0) * 1.0) / 1.0;
                this->config[0][1] = +2.0 * (pow(tan(this->calcOmega() / 2.0), 2.0) * 1.0 - 1.0) / 1.0;
                this->config[0][0] = (1.0 + tan(this->calcOmega() / 2.0) * this->calcAlpha() * 1.0 + pow(tan(this->calcOmega() / 2.0), 2.0) * 1.0) / 1.0;
                this->config[1][2] = (1.0 - tan(this->calcOmega() / 2.0) * this->calcAlpha() * pow(this->getValue(), 0.5) + pow(tan(this->calcOmega() / 2.0), 2.0) * this->getValue()) / this->getValue();
                this->config[1][1] = +2.0 * (pow(tan(this->calcOmega() / 2.0), 2.0) * this->getValue() - 1.0) / this->getValue();
                this->config[1][0] = (1.0 + tan(this->calcOmega() / 2.0) * this->calcAlpha() * pow(this->getValue(), 0.5) + pow(tan(this->calcOmega() / 2.0), 2.0) * this->getValue()) / this->getValue();
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
public:
    VOID init(TRANSFORM transform, FILTER filter, BAND band, GAIN gain) {
        this->band = band;
        this->gain = gain;
        this->filter = filter;
        this->transform = transform;

        return;
    };

    DOUBLE process(DOUBLE input) {
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

    BAND getBand() {
        return this->band;
    };

    GAIN getGain() {
        return this->gain;
    };

    FILTER getFilter() {
        return this->filter;
    };

    DOUBLE getValue() {
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

    DOUBLE getAmp() {
        return this->amp;
    };

    VOID setAmp(DOUBLE value) {
        if (this->amp != value) {
            this->amp = value;
            this->calcConfig();
        };

        return;
    };

    DOUBLE getFreq() {
        return this->freq;
    };

    VOID setFreq(DOUBLE value) {
        if (this->freq != value) {
            this->freq = value;
            this->calcConfig();
        };

        return;
    };

    DOUBLE getRate() {
        return this->rate;
    };

    VOID setRate(DOUBLE value) {
        if (this->rate != value) {
            this->rate = value;
            this->calcConfig();
        };

        return;
    };

    DOUBLE getWidth() {
        return this->width;
    };

    VOID setWidth(DOUBLE value) {
        if (this->width != value) {
            this->width = value;
            this->calcConfig();
        };

        return;
    };
};
