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

#import "QRMath.h"
#import "QRPolynomial.h"


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation QRPolynomial

@synthesize length = _length;


////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithCoeffs:(int *)coeffs length:(int)length shift:(int)shift {
  if (self = [super init]) {
    int offset;
    for(offset = 0; offset < length && coeffs[offset] == 0; offset++);
    _length = length - offset + shift;
    _coeffs = (int *)malloc(_length * sizeof(int));
    for(int i = 0; i < length - offset; i++) {
      _coeffs[i] = coeffs[i + offset];
    }
    memset(_coeffs + length - offset, 0, shift * sizeof(int));
  }
  return self;
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  free(_coeffs);

  [super dealloc];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (int)get:(int)index {
  return _coeffs[index];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (QRPolynomial *)multiply:(QRPolynomial *)p {
  int length2 = _length + p->_length - 1;
  int *cs = (int *)malloc(length2 * sizeof(int));
  memset(cs, 0, length2 * sizeof(int));
  for(int i = 0; i < _length; i++) {
    for(int j = 0; j < p->_length; j++) {
      cs[i + j] ^= [QRMath exp:[QRMath log:_coeffs[i]] +
                    [QRMath log:p->_coeffs[j]]];
    }
  }
  QRPolynomial *p2 = [[QRPolynomial alloc] initWithCoeffs:cs length:length2 shift:0];
  free(cs);
  return [p2 autorelease];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (QRPolynomial *)mod:(QRPolynomial *)p {
  if (_length < p->_length) {
    return [[self retain] autorelease];
  }
  int ratio = [QRMath log:_coeffs[0]] - [QRMath log:p->_coeffs[0]];
  int *cs = (int *)malloc(_length * sizeof(int));
  memcpy(cs, _coeffs, _length * sizeof(int));
  for(int i = 0; i < p->_length; i++) {
    cs[i] ^= [QRMath exp:[QRMath log:p->_coeffs[i]] + ratio];
  }
  QRPolynomial *p2 = [[QRPolynomial alloc] initWithCoeffs:cs length:_length shift:0];
  free(cs);
  QRPolynomial *p3 = [p2 mod:p];
  [p2 release];
  return p3;
}


@end
