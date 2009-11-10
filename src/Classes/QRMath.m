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


////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation QRMath

static int LOG_TABLE[256];
static int EXP_TABLE[256];


////////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)initialize {
  for(int i = 0; i < 8; i++) {
    EXP_TABLE[i] = 1 << i;
  }

  for(int i = 8; i < 256; i++) {
    EXP_TABLE[i] = EXP_TABLE[i - 4] ^
      EXP_TABLE[i - 5] ^
      EXP_TABLE[i - 6] ^
      EXP_TABLE[i - 8];
  }

  for(int i = 0; i < 255; i++) {
    LOG_TABLE[EXP_TABLE[i]] = i;
  }
}


////////////////////////////////////////////////////////////////////////////////////////////////////
+ (int)exp:(int)val {
  val %= 255;
  if (val < 0) {
    val += 255;
  }
  return EXP_TABLE[val];
}


////////////////////////////////////////////////////////////////////////////////////////////////////
+ (int)log:(int)val {
  return LOG_TABLE[val];
}


@end
