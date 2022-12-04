#pragma once
#include "windows.h"

enum BAND {
    btQ,
    btSlope,
    btOctave,
    btSemitone
};

enum GAIN {
    gtDb,
    gtAmp
};

enum FILTER {
    ftEqu,
    ftInv,
    ftLow,
    ftBand,
    ftBass,
    ftHigh,
    ftPeak,
    ftNotch,
    ftTreble
};

struct QMPBQF {
    private:
        BAND band;
        GAIN gain;
        FILTER filter;
        DOUBLE config[2][3];
        DOUBLE signal[2][3];
        DOUBLE amp;
        DOUBLE freq;
        DOUBLE rate;
        DOUBLE width;
        DOUBLE calcOmega();
        DOUBLE calcAlpha();
        VOID calcConfig();
    public:
        VOID init(FILTER filter, BAND band, GAIN gain);
        DOUBLE process(DOUBLE input);
        BAND getBand();
        GAIN getGain();
        FILTER getFilter();
        DOUBLE getAmp();
        VOID setAmp(DOUBLE value);
        DOUBLE getFreq();
        VOID setFreq(DOUBLE value);
        DOUBLE getRate();
        VOID setRate(DOUBLE value);
        DOUBLE getWidth();
        VOID setWidth(DOUBLE value);
};
typedef QMPBQF* PQMPBQF;
