//
//  SteveLib.cpp
//  Runner
//
//  Created by soliax on 2020/04/10.
//  Copyright © 2020 The Chromium Authors. All rights reserved.
//

#include <string>
#include <stdio.h>

#include "SteveLib.hpp"
#include "TemporalLib.h"

using namespace std;

extern "C" u8* hitBooks(int size) {
    static BookHitter *steve;
    if (!steve) {
        steve = bh_create();
        bh_config(steve)->Channel = 1;
    }
    
    u8* buffer = (u8*) malloc(size);
    bh_hitbooks(steve, (u8*)buffer, size);
    return buffer;
}
