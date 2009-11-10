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
#import "QRMatrix.h"
#import "QREncoder.h"
#import "QRMath.h"
#import "QRPolynomial.h"
#import "QRRSBlock.h"

////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Tables and macros

#define G15 (1 << 10 | 1 << 8 | 1 << 5 | 1 << 4 | 1 << 2 | 1 << 1 | 1 << 0)
#define G15_MASK (1 << 14 | 1 << 12 | 1 << 10 | 1 << 4 | 1 << 1)
#define G18 (1 << 12 | 1 << 11 | 1 << 10 | 1 << 9 | 1 << 8 | 1 << 5 | 1 << 2 | 1 << 0)

static int PATTERN_POSITION_TABLE[][8] =
  {{0, 0, 0, 0, 0, 0, 0, 0},
  {6, 18, 0, 0, 0, 0, 0, 0},
  {6, 22, 0, 0, 0, 0, 0, 0},
  {6, 26, 0, 0, 0, 0, 0, 0},
  {6, 30, 0, 0, 0, 0, 0, 0},
  {6, 34, 0, 0, 0, 0, 0, 0},
  {6, 22, 38, 0, 0, 0, 0, 0},
  {6, 24, 42, 0, 0, 0, 0, 0},
  {6, 26, 46, 0, 0, 0, 0, 0},
  {6, 28, 50, 0, 0, 0, 0, 0},
  {6, 30, 54, 0, 0, 0, 0, 0},
  {6, 32, 58, 0, 0, 0, 0, 0},
  {6, 34, 62, 0, 0, 0, 0, 0},
  {6, 26, 46, 66, 0, 0, 0, 0},
  {6, 26, 48, 70, 0, 0, 0, 0},
  {6, 26, 50, 74, 0, 0, 0, 0},
  {6, 30, 54, 78, 0, 0, 0, 0},
  {6, 30, 56, 82, 0, 0, 0, 0},
  {6, 30, 58, 86, 0, 0, 0, 0},
  {6, 34, 62, 90, 0, 0, 0, 0},
  {6, 28, 50, 72, 94, 0, 0, 0},
  {6, 26, 50, 74, 98, 0, 0, 0},
  {6, 30, 54, 78, 102, 0, 0, 0},
  {6, 28, 54, 80, 106, 0, 0, 0},
  {6, 32, 58, 84, 110, 0, 0, 0},
  {6, 30, 58, 86, 114, 0, 0, 0},
  {6, 34, 62, 90, 118, 0, 0, 0},
  {6, 26, 50, 74, 98, 122, 0, 0},
  {6, 30, 54, 78, 102, 126, 0, 0},
  {6, 26, 52, 78, 104, 130, 0, 0},
  {6, 30, 56, 82, 108, 134, 0, 0},
  {6, 34, 60, 86, 112, 138, 0, 0},
  {6, 30, 58, 86, 114, 142, 0, 0},
  {6, 34, 62, 90, 118, 146, 0, 0},
  {6, 30, 54, 78, 102, 126, 150, 0},
  {6, 24, 50, 76, 102, 128, 154, 0},
  {6, 28, 54, 80, 106, 132, 158, 0},
  {6, 32, 58, 84, 110, 136, 162, 0},
  {6, 26, 54, 82, 110, 138, 166, 0},
  {6, 30, 58, 86, 114, 142, 170, 0}};


static int RS_BLOCK_TABLE[][7] = {
//1
{1, 26, 19, 0, 0, 0, 0},
{1, 26, 16, 0, 0, 0, 0},
{1, 26, 13, 0, 0, 0, 0},
{1, 26, 9, 0, 0, 0, 0},

//2
{1, 44, 34, 0, 0, 0, 0},
{1, 44, 28, 0, 0, 0, 0},
{1, 44, 22, 0, 0, 0, 0},
{1, 44, 16, 0, 0, 0, 0},

//3
{1, 70, 55, 0, 0, 0, 0},
{1, 70, 44, 0, 0, 0, 0},
{2, 35, 17, 0, 0, 0, 0},
{2, 35, 13, 0, 0, 0, 0},

//4
{1, 100, 80, 0, 0, 0, 0},
{2, 50, 32, 0, 0, 0, 0},
{2, 50, 24, 0, 0, 0, 0},
{4, 25, 9, 0, 0, 0, 0},

//5
{1, 134, 108, 0, 0, 0, 0},
{2, 67, 43, 0, 0, 0, 0},
{2, 33, 15, 2, 34, 16, 0},
{2, 33, 11, 2, 34, 12, 0},

//6
{2, 86, 68, 0, 0, 0, 0},
{4, 43, 27, 0, 0, 0, 0},
{4, 43, 19, 0, 0, 0, 0},
{4, 43, 15, 0, 0, 0, 0},

//7
{2, 98, 78, 0, 0, 0, 0},
{4, 49, 31, 0, 0, 0, 0},
{2, 32, 14, 4, 33, 15, 0},
{4, 39, 13, 1, 40, 14, 0},

//8
{2, 121, 97, 0, 0, 0, 0},
{2, 60, 38, 2, 61, 39, 0},
{4, 40, 18, 2, 41, 19, 0},
{4, 40, 14, 2, 41, 15, 0},

//9
{2, 146, 116, 0, 0, 0, 0},
{3, 58, 36, 2, 59, 37, 0},
{4, 36, 16, 4, 37, 17, 0},
{4, 36, 12, 4, 37, 13, 0},

//10
{2, 86, 68, 2, 87, 69, 0},
{4, 69, 43, 1, 70, 44, 0},
{6, 43, 19, 2, 44, 20, 0},
{6, 43, 15, 2, 44, 16, 0},

//11
{4, 101, 81, 0, 0, 0, 0},
{1, 80, 50, 4, 81, 51, 0},
{4, 50, 22, 4, 51, 23, 0},
{3, 36, 12, 8, 37, 13, 0},

//12
{2, 116, 92, 2, 117, 93, 0},
{6, 58, 36, 2, 59, 37, 0},
{4, 46, 20, 6, 47, 21, 0},
{7, 42, 14, 4, 43, 15, 0},

//13
{4, 133, 107, 0, 0, 0, 0},
{8, 59, 37, 1, 60, 38, 0},
{8, 44, 20, 4, 45, 21, 0},
{12, 33, 11, 4, 34, 12, 0},

//14
{3, 145, 115, 1, 146, 116, 0},
{4, 64, 40, 5, 65, 41, 0},
{11, 36, 16, 5, 37, 17, 0},
{11, 36, 12, 5, 37, 13, 0},

//15
{5, 109, 87, 1, 110, 88, 0},
{5, 65, 41, 5, 66, 42, 0},
{5, 54, 24, 7, 55, 25, 0},
{11, 36, 12, 0, 0, 0, 0},

//16
{5, 122, 98, 1, 123, 99, 0},
{7, 73, 45, 3, 74, 46, 0},
{15, 43, 19, 2, 44, 20, 0},
{3, 45, 15, 13, 46, 16, 0},

//17
{1, 135, 107, 5, 136, 108, 0},
{10, 74, 46, 1, 75, 47, 0},
{1, 50, 22, 15, 51, 23, 0},
{2, 42, 14, 17, 43, 15, 0},

//18
{5, 150, 120, 1, 151, 121, 0},
{9, 69, 43, 4, 70, 44, 0},
{17, 50, 22, 1, 51, 23, 0},
{2, 42, 14, 19, 43, 15, 0},

//19
{3, 141, 113, 4, 142, 114, 0},
{3, 70, 44, 11, 71, 45, 0},
{17, 47, 21, 4, 48, 22, 0},
{9, 39, 13, 16, 40, 14, 0},

//20
{3, 135, 107, 5, 136, 108, 0},
{3, 67, 41, 13, 68, 42, 0},
{15, 54, 24, 5, 55, 25, 0},
{15, 43, 15, 10, 44, 16, 0},

//21
{4, 144, 116, 4, 145, 117, 0},
{17, 68, 42, 0, 0, 0, 0},
{17, 50, 22, 6, 51, 23, 0},
{19, 46, 16, 6, 47, 17, 0},

//22
{2, 139, 111, 7, 140, 112, 0},
{17, 74, 46, 0, 0, 0, 0},
{7, 54, 24, 16, 55, 25, 0},
{34, 37, 13, 0, 0, 0, 0},

//23
{4, 151, 121, 5, 152, 122, 0},
{4, 75, 47, 14, 76, 48, 0},
{11, 54, 24, 14, 55, 25, 0},
{16, 45, 15, 14, 46, 16, 0},

//24
{6, 147, 117, 4, 148, 118, 0},
{6, 73, 45, 14, 74, 46, 0},
{11, 54, 24, 16, 55, 25, 0},
{30, 46, 16, 2, 47, 17, 0},

//25
{8, 132, 106, 4, 133, 107, 0},
{8, 75, 47, 13, 76, 48, 0},
{7, 54, 24, 22, 55, 25, 0},
{22, 45, 15, 13, 46, 16, 0},

//26
{10, 142, 114, 2, 143, 115, 0},
{19, 74, 46, 4, 75, 47, 0},
{28, 50, 22, 6, 51, 23, 0},
{33, 46, 16, 4, 47, 17, 0},

//27
{8, 152, 122, 4, 153, 123, 0},
{22, 73, 45, 3, 74, 46, 0},
{8, 53, 23, 26, 54, 24, 0},
{12, 45, 15, 28, 46, 16, 0},

//28
{3, 147, 117, 10, 148, 118, 0},
{3, 73, 45, 23, 74, 46, 0},
{4, 54, 24, 31, 55, 25, 0},
{11, 45, 15, 31, 46, 16, 0},

//29
{7, 146, 116, 7, 147, 117, 0},
{21, 73, 45, 7, 74, 46, 0},
{1, 53, 23, 37, 54, 24, 0},
{19, 45, 15, 26, 46, 16, 0},

//30
{5, 145, 115, 10, 146, 116, 0},
{19, 75, 47, 10, 76, 48, 0},
{15, 54, 24, 25, 55, 25, 0},
{23, 45, 15, 25, 46, 16, 0},

//31
{13, 145, 115, 3, 146, 116, 0},
{2, 74, 46, 29, 75, 47, 0},
{42, 54, 24, 1, 55, 25, 0},
{23, 45, 15, 28, 46, 16, 0},

//32
{17, 145, 115, 0, 0, 0, 0},
{10, 74, 46, 23, 75, 47, 0},
{10, 54, 24, 35, 55, 25, 0},
{19, 45, 15, 35, 46, 16, 0},

//33
{17, 145, 115, 1, 146, 116, 0},
{14, 74, 46, 21, 75, 47, 0},
{29, 54, 24, 19, 55, 25, 0},
{11, 45, 15, 46, 46, 16, 0},

//34
{13, 145, 115, 6, 146, 116, 0},
{14, 74, 46, 23, 75, 47, 0},
{44, 54, 24, 7, 55, 25, 0},
{59, 46, 16, 1, 47, 17, 0},

//35
{12, 151, 121, 7, 152, 122, 0},
{12, 75, 47, 26, 76, 48, 0},
{39, 54, 24, 14, 55, 25, 0},
{22, 45, 15, 41, 46, 16, 0},

//36
{6, 151, 121, 14, 152, 122, 0},
{6, 75, 47, 34, 76, 48, 0},
{46, 54, 24, 10, 55, 25, 0},
{2, 45, 15, 64, 46, 16, 0},

//37
{17, 152, 122, 4, 153, 123, 0},
{29, 74, 46, 14, 75, 47, 0},
{49, 54, 24, 10, 55, 25, 0},
{24, 45, 15, 46, 46, 16, 0},

//38
{4, 152, 122, 18, 153, 123, 0},
{13, 74, 46, 32, 75, 47, 0},
{48, 54, 24, 14, 55, 25, 0},
{42, 45, 15, 32, 46, 16, 0},

//39
{20, 147, 117, 4, 148, 118, 0},
{40, 75, 47, 7, 76, 48, 0},
{43, 54, 24, 22, 55, 25, 0},
{10, 45, 15, 67, 46, 16, 0},

//40
{19, 148, 118, 6, 149, 119, 0},
{18, 75, 47, 31, 76, 48, 0},
{34, 54, 24, 34, 55, 25, 0},
{20, 45, 15, 61, 46, 16, 0}
};



////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
@interface QREncoder()
- (void)encode;
- (int)lostPoint;

@end


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
@implementation QREncoder


////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithStr: (NSString*)str
             size: (int)size
  correctionLevel: (QRCorrectionLevel)correctionLevel
          pattern: (int)pattern {

  if (self = [super init]) {
    _str              = [str copy];
    _size             = size;
    _correctionLevel  = correctionLevel;
    _pattern          = pattern;

    int matrixSize = 4 * _size + 17;
    _matrix = [[QRMatrix alloc] initWithWidth:matrixSize height:matrixSize];
  }

  return self;
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  [_str release];
  [_matrix release];
  [super dealloc];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Global methods


////////////////////////////////////////////////////////////////////////////////////////////////////
+ (UIImage *)imageForMatrix:(QRMatrix *)matrix {
  int width = matrix.width;
  int height = matrix.height;
  unsigned char *bytes = (unsigned char *)malloc(width * height * 4);
  for(int y = 0; y < height; y++) {
    for(int x = 0; x < width; x++) {
      BOOL bit = [matrix getX:x y:y];
      unsigned char intensity = bit ? 0 : 255;
      for(int i = 0; i < 3; i++) {
        bytes[y * width * 4 + x * 4 + i] = intensity;
      }
      bytes[y * width * 4 + x * 4 + 3] = 255;
    }
  }
  
  //int width = 32;
  //int height = 32;
  //unsigned char *bytes = (unsigned char *)malloc(width * height);
  //memset(bytes, 255, width * height * 4);
  
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  CGContextRef c = CGBitmapContextCreate(bytes, width, height, 8, 4 * width, colorSpace, kCGImageAlphaPremultipliedLast);
  CFRelease(colorSpace);
  CGImageRef image = CGBitmapContextCreateImage(c);
  CFRelease(c);
  UIImage *image2 = [UIImage imageWithCGImage:image];
  CFRelease(image);
  return image2;
}


////////////////////////////////////////////////////////////////////////////////////////////////////
+ (UIImage *)encode:(NSString *)str {
  return [QREncoder encode:str size:4 correctionLevel:QRCorrectionLevelHigh];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
+ (UIImage *)encode:(NSString *)str size:(int)size correctionLevel:(QRCorrectionLevel)level {
  QREncoder *encoders[8];
  for(int i = 0; i < 8; i++) {
    encoders[i] = [[QREncoder alloc] initWithStr:str size:size correctionLevel:level pattern:i];
    [encoders[i] encode];
  }
  
  int minLostPoint = LONG_MAX;
  QREncoder *encoder = nil;
  for(int i = 0; i < 8; i++) {
    if (encoders[i]->_matrix != nil) {
      int lostPoint = [encoders[i] lostPoint];
      if (lostPoint < minLostPoint) {
        minLostPoint = lostPoint;
        encoder = encoders[i];
      }
    }
  }

  UIImage *image;
  if (encoder != nil) {
    image = [QREncoder imageForMatrix:encoder->_matrix];
  } else {
    image = nil;
  }

  for(int i = 0; i < 8; i++) {
    [encoders[i] release];
  }

  return image;
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setupPositionProbePatternAtRow:(int)row column:(int)col {
  for(int r = -1; r <= 7; r++) {
    if (row + r < 0 || row + r >= _matrix.height) {
      continue;
    }

    for(int c = -1; c <= 7; c++) {
      if (col + c < 0 || col + c >= _matrix.width) {
        continue;
      }

      BOOL bit = (r >= 0 && r <= 6 && (c == 0 || c == 6)) || 
        (c >= 0 && c <= 6 && (r == 0 || r == 6)) ||
        (r >= 2 && r <= 4 && c >= 2 && c <= 4);
      [_matrix setX:col + c y:row + r value:bit];
    }
  }
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setupPositionAdjustPattern {
  int *patterns = PATTERN_POSITION_TABLE[_size - 1];

  for(int  i = 0; patterns[i] != 0; i++) {
    int row = patterns[i];

    for(int j = 0; patterns[j] != 0; j++) {
      int col = patterns[j];
      if ([_matrix hasSetX:col y:row]) {
        continue;
      }

      for(int r = -2; r <= 2; r++) {
        for(int c = -2; c <= 2; c++) {
          BOOL bit = ABS(r) == 2 || ABS(c) == 2 || (r == 0 && c == 0);
          [_matrix setX:col + c y:row + r value:bit];
        }
      }
    }
  }
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setupTimingPattern {
  for(int i = 8; i < _matrix.width - 8; i++) {
    [_matrix setX:i y:6 value:i % 2 == 0];
    [_matrix setX:6 y:i value:i % 2 == 0];
  }
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (int)getBchDigit:(int)data {
  int digit = 0;
  while (data != 0) {
    digit++;
    data >>= 1;
  }
  return digit;
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (int)getBchTypeInfo:(int)data {
  int d = data << 10;

  while ([self getBchDigit:d] >= [self getBchDigit:G15]) {
    d ^= G15 << ([self getBchDigit:d] - [self getBchDigit:G15]);
  }

  return ((data << 10) | d) ^ G15_MASK;
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (int)getBchTypeNumber:(int)data {
  int d = data << 12;

  while ([self getBchDigit:d] >= [self getBchDigit:G18]) {
    d ^= (G18 << ([self getBchDigit:d] - [self getBchDigit:G18]));
  }

  return (data << 12) | d;
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (int)correctionLevelNum {
  switch (_correctionLevel) {
    case QRCorrectionLevelLow:
      return 1;
    case QRCorrectionLevelMedium:
      return 0;
    case QRCorrectionLevelQ:
      return 3;
    case QRCorrectionLevelHigh:
      return 2;
    default:
      NSAssert(NO, @"Unknown correction level");
      return 0;
  }
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setupTypeInfo {
  int data = ([self correctionLevelNum] << 3) | _pattern;
  int bits = [self getBchTypeInfo:data];
  
  for(int i = 0; i < 15; i++) {
    BOOL bit = ((bits >> i) & 1) == 1;
    
    // Vertical
    if (i < 6) {
      [_matrix setX:8 y:i value:bit];
    } else if (i < 8) {
      [_matrix setX:8 y:i + 1 value:bit];
    } else {
      [_matrix setX:8 y:_matrix.height - 15 + i value:bit];
    }
    
    // Horizontal
    if (i < 8) {
      [_matrix setX:_matrix.width - i - 1 y:8 value:bit];
    } else if (i < 9) {
      [_matrix setX:15 - i y:8 value:bit];
    } else {
      [_matrix setX:14 - i y:8 value:bit];
    }
  }
  
  // Fixed module
  [_matrix setX:8 y:_matrix.height - 8 value:YES];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setupTypeNumber {
  int bits = [self getBchTypeNumber:_size];
  for(int i = 0; i < 18; i++) {
    BOOL bit = ((bits >> i) & 1) == 1;
    [_matrix setX:i % 3 + _matrix.width - 11 y:i / 3 value:bit];
    [_matrix setX:i / 3 y:i % 3 + _matrix.width - 11 value:bit];
  }
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (int *)getRSBlockTable {
  int offset = [self correctionLevelNum];
  switch (_correctionLevel) {
    case QRCorrectionLevelLow:
      offset = 0;
      break;
    case QRCorrectionLevelMedium:
      offset = 1;
      break;
    case QRCorrectionLevelQ:
      offset = 2;
      break;
    case QRCorrectionLevelHigh:
      offset = 3;
      break;
    default:
      NSAssert(NO, @"Unknown correction level");
      offset = 0;
      break;
  }

  return RS_BLOCK_TABLE[4 * (_size - 1) + offset];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSArray *)getRSBlocks {
  NSMutableArray *blocks = [[NSMutableArray alloc] init];
  int *block = [self getRSBlockTable];
  for(int i = 0; i == 0 || block[i - 2] != 0; i += 3) {
    QRRSBlock *block2 = [[QRRSBlock alloc] initWithTotalCount:block[i + 1] dataCount:block[i + 2]];
    for(int j = 0; j < block[i]; j++) {
      [blocks addObject:block2];
    }
    [block2 release];
  }
  return [blocks autorelease];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (QRBitBuffer *)getData {
  QRBitBuffer *buffer = [[QRBitBuffer alloc] init];
  [buffer append:4 length:4];
  [buffer append:[_str length] length:8];

  for(int i = 0; i < [_str length]; i++) {
    unichar c = [_str characterAtIndex:i];
    if (c >= 256) {
      [buffer release];
      return nil;
    }
    [buffer append:c length:8];
  }
  
  NSArray *rsBlocks = [self getRSBlocks];
  int totalDataCount = 0;

  for(QRRSBlock *rsBlock in rsBlocks) {
    totalDataCount += rsBlock.dataCount;
  }

  if (buffer.numBits > totalDataCount * 8) {
    //Code overflow
    [buffer release];
    return nil;
  }

  if (buffer.numBits + 4 <= totalDataCount * 8) {
    [buffer append:0 length:4];
  }

  while (buffer.numBits % 8 != 0) {
    [buffer append:NO];
  }

  while (YES) {
    if (buffer.numBits >= totalDataCount * 8) {
      break;
    }
    [buffer append:0xEC length:8];
    if (buffer.numBits >= totalDataCount * 8) {
      break;
    }
    [buffer append:0x11 length:8];
  }

  return buffer;
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (QRPolynomial *)errorCorrectPolynomial:(int)length {
  int cs[2] = {1, 0};

  QRPolynomial *p = [[[QRPolynomial alloc] initWithCoeffs:cs length:1 shift:0] autorelease];

  for(int i = 0; i < length; i++) {
    cs[1] = [QRMath exp:i];
    QRPolynomial *p2 = [[QRPolynomial alloc] initWithCoeffs:cs length:2 shift:0];
    p = [p multiply:p2];
    [p2 release];
  }

  return p;
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (int *)computeBytes:(QRBitBuffer *)data size:(int *)resultSize {
  NSArray *rsBlocks = [self getRSBlocks];
  int offset = 0;
  int maxDCCount = 0;
  int maxECCount = 0;
  int **dcData = (int **)malloc([rsBlocks count] * sizeof(int *));
  int **ecData = (int **)malloc([rsBlocks count] * sizeof(int *));
  int *ecCounts = (int *)malloc([rsBlocks count] * sizeof(int));
  for(int r = 0; r < [rsBlocks count]; r++) {
    QRRSBlock *rsBlock = [rsBlocks objectAtIndex:r];
    int dcCount = rsBlock.dataCount;
    int ecCount = rsBlock.totalCount - dcCount;
    maxDCCount = MAX(maxDCCount, dcCount);
    maxECCount = MAX(maxECCount, ecCount);
    
    int *buffer = (int *)malloc(dcCount * sizeof(int));
    memset(buffer, 0, dcCount * sizeof(int));
    for(int i = 0; i < 8 * dcCount; i++) {
      if ([data get:i + 8 * offset])
        buffer[i / 8] |= 1 << (7 - (i % 8));
    }
    offset += dcCount;
    dcData[r] = buffer;
    
    QRPolynomial *rsPoly = [self errorCorrectPolynomial:ecCount];
    QRPolynomial *rawPoly =
      [[QRPolynomial alloc] initWithCoeffs:buffer
                      length:dcCount
                       shift:rsPoly.length - 1];
    QRPolynomial *modPoly = [rawPoly mod:rsPoly];
    
    int length = rsPoly.length - 1;
    ecCounts[r] = length;
    int *es = (int *)malloc(length * sizeof(int));
    for(int i = 0; i < length; i++) {
      int modIndex = i + modPoly.length - length;
      es[i] = modIndex >= 0 ? [modPoly get:modIndex] : 0;
    }
    ecData[r] = es;
  }
  
  int totalCodeCount = 0;
  for(QRRSBlock *rsBlock in rsBlocks)
    totalCodeCount += rsBlock.totalCount;
  
  *resultSize = totalCodeCount;
  int *data2 = (int *)malloc(totalCodeCount * sizeof(int));
  int index = 0;
  for(int i = 0; i < maxDCCount; i++) {
    for(int r = 0; r < [rsBlocks count]; r++) {
      QRRSBlock *rsBlock = [rsBlocks objectAtIndex:r];
      if (i < rsBlock.dataCount) {
        data2[index] = dcData[r][i];
        index++;
      }
    }
  }
  
  for(int i = 0; i < maxECCount; i++) {
    for(int r = 0; r < [rsBlocks count]; r++) {
      if (i < ecCounts[r]) {
        data2[index] = ecData[r][i];
        index++;
      }
    }
  }
  
  for(int i = 0; i < [rsBlocks count]; i++) {
    free(dcData[i]);
    free(ecData[i]);
  }
  free(dcData);
  free(ecData);
  free(ecCounts);
  
  return data2;
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)maskForRow:(int)i col:(int)j {
  switch (_pattern) {
    case 0:
      return (i + j) % 2 == 0;
    case 1:
      return i % 2 == 0;
    case 2:
      return j % 3 == 0;
    case 3:
      return (i + j) % 3 == 0;
    case 4:
      return ((i / 2) + (j / 3)) % 2 == 0;
    case 5:
      return (i * j) % 2 + (i * j) % 3 == 0;
    case 6:
      return ((i * j) % 2 + (i * j) % 3) % 2 == 0;
    case 7:
      return ((i * j) % 3 + (i * j) % 2) % 2 == 0;
    default:
      NSAssert(NO, @"Unknown pattern");
      return NO;
  }
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)mapData:(int *)bytes size:(int)dataSize {
  int inc = -1;
  int row = _matrix.height - 1;
  int bitIndex = 7;
  int byteIndex = 0;
  for(int col2 = _matrix.width - 1; col2 >= 1; col2 -= 2) {
    int col;
    if (col2 > 6) {
      col = col2;
    } else {
      col = col2 - 1;
    }

    while (YES) {
      for(int c = 0; c < 2; c++) {
        if (![_matrix hasSetX:col - c y:row]) {
          BOOL bit = NO;
          if (byteIndex < dataSize) {
            bit = ((bytes[byteIndex] >> bitIndex) & 1) == 1;
          }
          if ([self maskForRow:row col:col - c]) {
            bit = !bit;
          }
          [_matrix setX:col - c y:row value:bit];
          if (bitIndex == 0) {
            byteIndex++;
            bitIndex = 7;
          }
          else {
            bitIndex--;
          }
        }
      }
      
      row += inc;
      if (row < 0 || row >= _matrix.height) {
        row -= inc;
        inc = -inc;
        break;
      }
    }
  }
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)encode {
  [self setupPositionProbePatternAtRow:0 column:0];
  [self setupPositionProbePatternAtRow:_matrix.height - 7 column:0];
  [self setupPositionProbePatternAtRow:0 column:_matrix.width - 7];
  [self setupPositionAdjustPattern];
  [self setupTypeInfo];
  [self setupTimingPattern];
  if (_pattern >= 7) {
    [self setupTypeNumber];
  }
  QRBitBuffer *data = [self getData];
  if (data == nil) {
    // Code overflow
    [_matrix release];
    _matrix = nil;

  } else {
    int dataSize = 0;
    int *bytes = [self computeBytes:data size:&dataSize];
    [self mapData:bytes size:dataSize];
    free(bytes);
  }
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (int)lostPoint {
  int lostPoint = 0;
  
  //Level 1
  for(int row = 0; row < _matrix.height; row++) {
    for(int col = 0; col < _matrix.width; col++) {
      int sameCount = 0;
      BOOL bit = [_matrix getX:col y:row];
      for(int r = -1; r <= 1; r++) {
        if (row + r < 0 || row + r >= _matrix.height) {
          continue;
        }
        for(int c = -1; c <= 1; c++) {
          if (col + c < 0 || col + c >= _matrix.height) {
            continue;
          }
          if (bit == [_matrix getX:col + c y:row + r]) {
            sameCount++;
          }
        }
      }
      if (sameCount > 5) {
        lostPoint += sameCount - 2;
      }
    }
  }
  
  //Level 2
  for(int row = 0; row < _matrix.height - 1; row++) {
    for(int col = 0; col < _matrix.width - 1; col++) {
      int count = 0;

      for(int r = 0; r < 1; r++) {
        for(int c = 0; c < 1; c++) {
          if ([_matrix getX:col + c y:row + r]) {
            count++;
          }
        }
      }

      if (count == 0 || count == 4) {
        lostPoint += 3;
      }
    }
  }
  
  //Level 3
  for(int row = 0; row < _matrix.height - 6; row++) {
    for(int col = 0; col < _matrix.width; col++) {
      if ([_matrix getX:col y:row] &&
          ![_matrix getX:col y:row + 1] &&
          [_matrix getX:col y:row + 2] &&
          [_matrix getX:col y:row + 3] &&
          ![_matrix getX:col y:row + 4] &&
          [_matrix getX:col y:row + 5]) {
        lostPoint += 40;
      }
    }
  }
  
  return lostPoint * 10;
}

@end
