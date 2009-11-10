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

//
// Ported from http://github.com/whomwah/rqrcode
// by Bill Jacobs.
//

#import "QRCorrectionLevel.h"

@class QRMatrix;

////////////////////////////////////////////////////////////////////////////////////////////////////
@interface QREncoder : NSObject {
  NSString*         _str;
  QRCorrectionLevel _correctionLevel;
  int               _size;
  int               _pattern;
  QRMatrix*         _matrix;
}

+ (UIImage *)encode:(NSString *)str;
+ (UIImage *)encode:(NSString *)str size:(int)size correctionLevel:(QRCorrectionLevel)level;

@end
