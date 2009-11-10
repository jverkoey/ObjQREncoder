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

#import "QREncoderTests.h"

#import "QREncoder.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation QREncoderTests

// See: http://developer.apple.com/iphone/library/documentation/Xcode/Conceptual/iphone_development/905-A-Unit-Test_Result_Macro_Reference/unit-test_results.html#//apple_ref/doc/uid/TP40007959-CH21-SW2
// for unit test macros.

//  NSData* pngRepresentation = UIImagePNGRepresentation(genImage);
//  [pngRepresentation writeToFile:@"Resources/google.com.png" atomically:YES];


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setUp {
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)tearDown {
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testEnsureTestImageExistence {
  UIImage* image = [UIImage imageWithContentsOfFile:@"Resources/google.com.png"];

  STAssertNotNil(image, @"Couldn't find the test image %@",
    [[NSFileManager defaultManager] currentDirectoryPath]);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)testURL {
  UIImage* srcImage = [UIImage imageWithContentsOfFile:@"Resources/google.com.png"];
  UIImage* genImage = [QREncoder encode:@"http://www.google.com/"];

  NSData* srcData = UIImagePNGRepresentation(srcImage);
  NSData* genData = UIImagePNGRepresentation(genImage);

  STAssertEquals([srcData hash], [genData hash], @"Generated QR doesn't match test case.");
}


@end
