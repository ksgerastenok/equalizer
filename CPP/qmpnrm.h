#pragma once
#include "qmpbqf.h"
#include "qmpdcl.h"
#include "qmpdsp.h"
#include "windows.h"

using namespace std;

struct QMPNRM {
private:
	QMPBQF bqf;
	DOUBLE amp;
	DOUBLE sqr;
	DOUBLE avg;
    DOUBLE calcAmp();
    DOUBLE calcGain();
    VOID addSample(const DOUBLE value);
public:
    VOID init(const TRANSFORM transform, const FILTER filter, const BAND band, const GAIN gain);
    DOUBLE process(const DOUBLE value);
    BAND getBand();
    GAIN getGain();
    FILTER getFilter();
    DOUBLE getValue();
    DOUBLE getAmp();
    VOID setAmp(const DOUBLE value);
    DOUBLE getFreq();
    VOID setFreq(const DOUBLE value);
    DOUBLE getRate();
    VOID setRate(const DOUBLE value);
    DOUBLE getWidth();
    VOID setWidth(const DOUBLE value);
};
typedef QMPNRM* PQMPNRM;
