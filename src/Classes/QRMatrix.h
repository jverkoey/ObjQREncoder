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

////////////////////////////////////////////////////////////////////////////////////////////////////
@interface QRMatrix : NSObject {
  char* _bits;
  char* _set;
  int   _width;
  int   _height;
}

@property (nonatomic, readonly) int width;
@property (nonatomic, readonly) int height;

- (id)initWithWidth:(int)width height:(int)height;

- (void)setX:(int)x y:(int)y value:(BOOL)value;
- (BOOL)getX:(int)x y:(int)y;
- (void)getBits:(char *)bits;
- (BOOL)hasSetX:(int)x y:(int)y;

@end
