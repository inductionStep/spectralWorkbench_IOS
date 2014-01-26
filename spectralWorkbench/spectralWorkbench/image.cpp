//
//  image.cpp
//  spectralWorkbench
//
//  Created by Diego on 1/25/14.
//  Copyright (c) 2014 Public Labs. All rights reserved.
//

#include <iostream>
#include <string>
#include "image.h"


using namespace std;


myImage* myImage::m_instance = NULL;

myImage* myImage::instance(){
    if(!m_instance){
        m_instance = new myImage;
    }
    return m_instance;
}

myImage::~myImage(){
	//delete m_instance;
}



void myImage::clear(){
    _buffer.clear();
}

void myImage::setup(int height, int width){
    _buffer.resize(height);
    for(int row = 0; row < _buffer.size(); row++){
        _buffer[row].resize(width);
    }
}

void myImage::insertColor(int red, int green, int blue, int x, int y){
    _buffer[y][x]._red   = red;
    _buffer[y][x]._green = green;
    _buffer[y][x]._blue  = blue;
}


