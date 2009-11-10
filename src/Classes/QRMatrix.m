/**
 * Copyright 2009
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "QRMatrix.h"


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation QRMatrix

@synthesize height  = _height;
@synthesize width   = _width;


////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithWidth:(int)width height:(int)height {
  if (self = [super init]) {
    _width  = width;
    _height = height;

    int size = (_width * _height + 7) / 8;
    _bits = (char *)malloc(size);
    _set  = (char *)malloc(size);

    memset(_bits, 0, size);
    memset(_set, 0, size);
  }
  return self;
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  free(_bits);
  free(_set);

  [super dealloc];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setX:(int)x y:(int)y value:(BOOL)value {
  NSAssert(x >= 0 && y >= 0 && x < _width && y < _height, @"Bad coordinates");
  int index = y * _width + x;

  if (value) {
    _bits[index / 8] |= (1 << (index % 8));
  } else {
    _bits[index / 8] &= ~(1 << (index % 8));
  }

  _set[index / 8] |= (1 << (index % 8));
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)getX:(int)x y:(int)y {
  NSAssert(x >= 0 && y >= 0 && x < _width && y < _height, @"Bad coordinates");
  int index = y * _width + x;
  return (_bits[index / 8] & (1 << (index % 8))) != 0;
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)getBits:(char *)bits {
  memcpy(bits, _bits, (_width * _height + 7) / 8);
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)hasSetX:(int)x y:(int)y {
  int index = y * _width + x;
  return (_set[index / 8] & (1 << (index % 8))) != 0;
}


@end
