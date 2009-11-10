Objective C QR Encoder
======================

This repository contains an open source Objective C QR Encoder 
licensed under the Apache Licence, Version 2.0
(http://www.apache.org/licenses/LICENSE-2.0.html).

Ported from http://github.com/whomwah/rqrcode by Bill Jacobs.

Adding the QR Encoder to your project
=====================================

The QR Encoder is compiled as a static library, and the easiest way to add it to your project is to use
Xcode's "dependent project" facilities.  Here is how:

1. Clone the ObjQR git repository: `git clone git://github.com/jverkoey/objqr.git`.  Make sure 
   you store the repository in a permanent place because Xcode will need to reference the files
   every time you compile your project.

2. Locate the "QREncoder.xcodeproj" file under "objqr/src/".  Drag QREncoder.xcodeproj and drop it onto
   the root of your Xcode project's "Groups and Files"  sidebar.  A dialog will appear -- make sure 
   "Copy items" is unchecked and "Reference Type" is "Relative to Project" before clicking "Add".

3. Now you need to link the QREncoder static library to your project.  Click the "QREncoder.xcodeproj" 
   item that has just been added to the sidebar.  Under the "Details" table, you will see a single
   item: libQREncoder.a.  Check the checkbox on the far right of libQREncoder.a.

4. Now you need to add QREncoder as a dependency of your project so that Xcode compiles it whenever
   you compile your project.  Expand the "Targets" section of the sidebar and double-click your
   application's target.  Under the "General" tab you will see a "Direct Dependencies" section. 
   Click the "+" button, select "QREncoder", and click "Add Target".

5. Finally, we need to tell your project where to find the QREncoder headers.  Open your
   "Project Settings" and go to the "Build" tab. Look for "Header Search Paths" and double-click
   it.  Add the relative path from your project's directory to the "objqr/src/Classes" directory.

6. You're ready to go.  Just #import "QREncoder/QREncoder.h" anywhere you want to use QREncoder classes
   in your project.


Example QR Output
=================

![google.com](google.com.png "google.com")
