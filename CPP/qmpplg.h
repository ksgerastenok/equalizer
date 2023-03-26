#pragma once
#include "qmpdcl.h"
#include "windows.h"
#define EXPORT extern "C" __declspec(dllexport)

EXPORT PMODULE QDSPModule();
