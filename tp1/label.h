#ifndef __LABEL__
#define __LABEL__

#include <iostream>
#include <stdint.h>
#include "types.h"

using namespace std;

class Label{
public:
    Label(Type ty, uint16_t add) { t=ty; address=add;}
    ~Label() {}

    Type t;
    uint16_t address;

};

#endif
