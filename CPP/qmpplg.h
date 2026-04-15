#pragma once
#include "qmpdcl.h"
#include "qmpdsp.h"
#include "qmpbqf.h"
#include "qmpnrm.h"
#include "windows.h"
#include "array"
#include "cmath"

#define EXPORT extern "C" __declspec(dllexport)

using namespace std;

EXPORT PMODULE QDSPModule();

EXPORT PMODULE QDSPModule() {
    PMODULE result = new MODULE();

    result->plugin = [](INT which) {
        switch (which) {
            case 0: {
                PPLUGIN result = new PLUGIN();

                static INFO info;
                static QMPDSP dsp;
                static array<QMPNRM, 5> nrm;
                static array<array<QMPBQF, 10>, 5> equ;

                result->description = L"Quinnware Equalizer v3.51";

                result->init = [](INT flags) {
                    for (INT k = 0; k != equ.size(); k += 1) {
                        for (INT i = 0; i != equ[k].size(); i += 1) {
                            equ[k][i].init(ptLAT, ftEqu, btOctave, gtDb);
                        };
                    };
                    for (INT k = 0; k != nrm.size(); k += 1) {
                        nrm[k].init(ptLAT, ftBand, btOctave, gtDb);
                    };

                    return 1;
                };

                result->quit = [](INT flags) {
                    return;
                };

                result->modify = [](PDATA data, PINT latency, INT flags) {
                    if (info.enabled) {
                        dsp.init(data);
                        for (INT k = 0; k != data->channels; k += 1) {
                            for (INT i = 0; i != equ[k].size(); i += 1) {
                                equ[k][i].setAmp((info.preamp + info.bands[i]) / 10.0);
                                equ[k][i].setFreq(20.0 * pow(2.0, 1.0 * (i + 0.5)));
                                equ[k][i].setWidth(1.0);
                                equ[k][i].setRate(data->rates);
                            };
                            nrm[k].setAmp(20.0);
                            nrm[k].setFreq(320.0);
                            nrm[k].setWidth(8.0);
                            nrm[k].setRate(data->rates);
                            for (INT x = 0; x != data->samples; x += 1) {
                                DOUBLE v = dsp.getData(k, x);
                                for (INT i = 0; i != equ[k].size(); i += 1) {
                                    v = equ[k][i].process(v);
                                };
                                v = nrm[k].process(v);
                                dsp.setData(k, x, v);
                            };
                        };
                    };

                    return 1;
                };

                result->update = [](PINFO pinfo, INT flags) {
                    info = *pinfo;

                    return 1;
                };

                return result;
            };
            break;
            case 1: {
                PPLUGIN result = new PLUGIN();

                static INFO info;
                static QMPDSP dsp;
                static array<QMPNRM, 5> nrm;
                static array<array<QMPBQF, 3>, 5> enh;

                result->description = L"Quinnware Enhancer v3.51";
                
                result->init = [](INT flags) {
                    for (INT k = 0; k != enh.size(); k += 1) {
                        enh[k][0].init(ptLAT, ftBass, btSlope, gtDb);
                        enh[k][1].init(ptLAT, ftBass, btSlope, gtDb);
                        enh[k][2].init(ptLAT, ftTreble, btSlope, gtDb);
                    };
                    for (INT k = 0; k != nrm.size(); k += 1) {
                        nrm[k].init(ptLAT, ftBand, btOctave, gtDb);
                    };

                    return 1;
                };

                result->quit = [](INT flags) {
                    return;
                };
            
                result->modify = [](PDATA data, PINT latency, INT flags) {
                    if (info.enabled) {
                        dsp.init(data);
                        for (INT k = 0; k != data->channels; k += 1) {
                            enh[k][0].setAmp(3.5);
                            enh[k][0].setFreq(150.0);
                            enh[k][0].setWidth(1.0);
                            enh[k][0].setRate(data->rates);
                            enh[k][1].setAmp(5.0);
                            enh[k][1].setFreq(50.0);
                            enh[k][1].setWidth(1.0);
                            enh[k][1].setRate(data->rates);
                            enh[k][2].setAmp(12.0);
                            enh[k][2].setFreq(2500.0);
                            enh[k][2].setWidth(1.0);
                            enh[k][2].setRate(data->rates);
                            nrm[k].setAmp(20.0);
                            nrm[k].setFreq(320.0);
                            nrm[k].setWidth(8.0);
                            nrm[k].setRate(data->rates);
                            for (INT x = 0; x != data->samples; x += 1) {
                                DOUBLE v = dsp.getData(k, x);
                                for (INT i = 0; i != enh[k].size(); i += 1) {
                                    v = enh[k][i].process(v);
                                };
                                v = nrm[k].process(v);
                                dsp.setData(k, x, v);
                            };
                        };
                    };

                    return 1;
                };
            
                result->update = [](PINFO pinfo, INT flags) {
                    info = *pinfo;

                    return 1;
                };

                return result;
            };
            break;
            default: {
                PPLUGIN result = NULL;

                return result;
            };
            break;
        };
    };

    return result;
};
