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

extern "C" void bhRunCmd() {
    printf("Steve Speaks:\n");
//    const char* IPhoneExample() {
      const char* input[] = {"temporal", "list", "1", 0};
      bh_run_command(nullptr, input, true);
      const char* iPhoneOutput = input[0];
      printf("%s", iPhoneOutput); // or some other way to send it back to the Mac.
//      return iPhoneOutput;
//    }

    /*
    static BookHitter *steve;
    if (!steve) {
        steve = bh_create();
        bh_config(steve)->Channel = 1;
    }
    
    const char* Args[] = {"temporal", "list", "1", 0};
    printf("bh_run_command: running %s...\n", Args[0]);
    int r = bh_run_command(steve, Args);
    printf("bh_run_command: %d\n", r);
    
    return;
     */
}
