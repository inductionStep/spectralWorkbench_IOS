//
//  image.h
//  spectralWorkbench
//
//  Created by Diego on 1/25/14.
//  Copyright (c) 2014 Public Labs. All rights reserved.
//

#ifndef __spectralWorkbench__image__
#define __spectralWorkbench__image__

#include <iostream>
#include <string>
#include <vector>
using namespace std;

struct myRGB{
    char _red;
    char _green;
    char _blue;
};

class myImage {

  public:
    static myImage* instance();
    static myImage* m_instance;

  private:
    vector< vector<myRGB> > _buffer;
    
    
  public:
    myImage();
    ~myImage();
    void clear();
    void setup(int height, int width);
    void insertColor(int red, int green, int blue, int x, int y);
};

#endif /* defined(__spectralWorkbench__image__) */
