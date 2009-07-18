//////////////////////////////////////////////////////////////////////////
//
//	SurfBox (c) Ver: December 2008
//	
//	A set of C++ and Matlab routines implementing the surfacelet transform
//	
//	in arbitrary N-dimensions (N >= 2)
//
//////////////////////////////////////////////////////////////////////////
//
//	Yue M. Lu and Minh N. Do
//
//	Department of Electrical and Computer Engineering
//	Coordinated Science Laboratory
//	University of Illinois at Urbana-Champaign
//
//////////////////////////////////////////////////////////////////////////
//
//	This software is provided "as-is", without any express or implied
//	warranty. In no event will the authors be held liable for any 
//	damages arising from the use of this software.
//
//////////////////////////////////////////////////////////////////////////

Version: December 2008

What's new:
1. Added mexcompile.m which automates the compilation and installation of the mex files.

2. Updated demo_VideoDenoising.m


Contents:

Demo/

Several Matlab scripts illustrating various properties of the surfacelet transform.

demo_Filters2D.m - showing the frequency and spatial domain basis images of several 2-D surfacelets

demo_Zoneplate.m - showing how surfacelets look like in 3-D.

demo_VideoDenoising - Applying the 3-D surfacelet transform to video denoising.


Cpp/

C++ files implementing the surfacelet filter bank

Start with test_surfacelet.cpp for an introduction on how to use the code.

Project files for Visual C++ 6.0 and Visual C++ 7.1 are included.


Matlab/

Matlab files implementing the surfacelet filter bank

Start with test_surfacelet.m for an introduction.


Mex/

C++ mex files giving Matlab access to the much faster C++ implementation.


Filters/

Pre-computed filter coefficients for the checkerboard filters.


For Installation:

Customize and run mexcompile.m found in the root directory of the SurfBox package. This will compile and install the necessary mex files.


Comments and suggestions are welcome and should be addressed to

Yue M. Lu (yue.lu@epfl.ch).

First created: April 2006
Last modified: December 2008