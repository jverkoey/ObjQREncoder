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

#import "QRBitBuffer.h"

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation QRBitBuffer

@synthesize numBits = _numBits;


////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init {
  if (self = [super init]) {
    _size   = 32;
    _buffer = (char *)malloc(_size);
    memset(_buffer, 0, _size);
  }
  return self;
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  free(_buffer);

  [super dealloc];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)append:(BOOL)bit {
  if (_numBits == _size * 8) {
    char *newBuffer = (char *)malloc(_size * 2);
    memcpy(newBuffer, _buffer, _size);
    memset(newBuffer + _size, 0, _size);
    free(_buffer);
    _buffer = newBuffer;
    _size *= 2;
  }

  if (bit) {
    _buffer[_numBits / 8] |= 1 << (7 - (_numBits % 8));
  }

  _numBits++;
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)append:(int)value length:(int)length {
  for(int i = 0; i < length; i++) {
    [self append:((value >> (length - i - 1)) & 1) == 1];
  }
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)get:(int)index {
  return (_buffer[index / 8] & (1 << (7 - (index % 8)))) != 0;
}


@end
