#pragma once
#include "windows.h"
#include <array>

using namespace std;

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
    DOUBLE calcAmp();
    DOUBLE calcOmega();
    DOUBLE calcAlpha();
    VOID calcConfig();
public:
    VOID init(const TRANSFORM transform, const FILTER filter, const BAND band, const GAIN gain);
    DOUBLE process(const DOUBLE input);
    BAND getBand();
    GAIN getGain();
    FILTER getFilter();
    DOUBLE getAmp();
    VOID setAmp(const DOUBLE value);
    DOUBLE getFreq();
    VOID setFreq(const DOUBLE value);
    DOUBLE getRate();
    VOID setRate(const DOUBLE value);
    DOUBLE getWidth();
    VOID setWidth(const DOUBLE value);
};
typedef QMPBQF* PQMPBQF;
