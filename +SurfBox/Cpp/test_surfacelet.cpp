//////////////////////////////////////////////////////////////////////////
//	SurfBox-C++ (c)
//////////////////////////////////////////////////////////////////////////
//
//	Yue Lu and Minh N. Do
//
//	Department of Electrical and Computer Engineering
//	Coordinated Science Laboratory
//	University of Illinois at Urbana-Champaign
//
//////////////////////////////////////////////////////////////////////////
//
//	test_surfacelet.cpp
//
//  A basic illustration of the SurfBox-C++ package.
//	
//	First created: 04-07-07
//	Last modified: 04-07-07
//
//////////////////////////////////////////////////////////////////////////

#include <time.h>
#include <iostream>
#include <sstream>
#include <math.h>
#include "SurfaceletFilterBank.h"

using namespace std;

void random_src(double *dst, int n);
void Surfacelet_basic_test(void);
void Surfacelet_adjoint_test(void);


int main(int argc, char* argv[])
{
	cout << endl << "Testing SurfBox-C ..." << endl;
    
    // A very basic illustration of the surfacelet filter bank
    cout << endl << "testing perfect reconstruction ..." << endl;
	Surfacelet_basic_test(); 

	// Test the adjoint of the transform
	// We need to implement the adjoint operator, since biorthogonal filters are used in
	// the surfacelet transform, and hence the inverse transform is not -- thought close to -- the 
	// adjoint of the forward transform. 
	cout << endl << "testing the adjoint operator ..." << endl;
	Surfacelet_adjoint_test();

	return 0;
}


//////////////////////////////////////////////////////////////////////////
//  Random number generator
//////////////////////////////////////////////////////////////////////////
//
//  Generate a sequence of n uniformly distributed random numbers ranging from 0 to 1,
//  and store them in the memory space pointed to by dst.

void random_src(double *dst, int n)
{
    // Set initial seed
    srand((unsigned)time(NULL));

    for (register int i = 0; i < n; i++)
        *(dst++) = (double)rand() / ((double)(RAND_MAX)+(double)(1));
}


//////////////////////////////////////////////////////////////////////////
//  A basic perfect reconstruction test of the surfacelet filter bank
//////////////////////////////////////////////////////////////////////////
//
//  We generate a multidimensional array, fill it with random numbers, and 
//  decompose it into several surfacelet subbands. We then reconstruct the array
//  from the subbands using the synthesis part of the surfacelet filter bank.
//  The reconstructed array should be numerically equal to the original array.

void Surfacelet_basic_test()
{
    // Create an object for surfacelet filter bank decomposition and reconstruction
	SurfaceletFilterBank surf_fb;

	// We store all the decomposition parameters here
    SurfaceletRecInfo rec_info;

	// Number of decomposition levels of the multiscale pyramid
	int Pyr_Level = 2; // can be 1, 2, 3, 4, 5, ...

	// Operation mode of the pyramid filter bank 
	enum Pyramid_Mode pyr_mode = DOWNSAMPLE_1;
	
	// Smooth function used in specifying the lowpass and highpass filters
	enum SmoothFunctionType func_type = RAISED_COSINE;

	// Some parameters used in the hourglass filter bank
	int mSize = 15;
	double beta = 2.5, lambda = 4.0;

	// The order of the checkerboard filters
	int bo = 8;

	// The number of dimensions of the input signal (2, 3, 4, ...)
	int nDims = 3; // a 3-D array

	//////////////////////////////////////////////////////////////////////////
	// IMPORTANT: change the directory string accordingly
	// It should specify the folder in which the filter coefficients are stored.
	//////////////////////////////////////////////////////////////////////////
	string dir_info = "../../filters/";
	//////////////////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////////

	try
	{
		// Now we save the above parameters into rec_info
		rec_info.SetParameters(nDims, bo, mSize, beta, lambda, Pyr_Level, pyr_mode, func_type, dir_info);
	}
	catch (...)
	{
		// filter coefficients files not found
		cout << endl << "Filter coefficients files are either not found or corrupted. Check if the given directory is correct." << endl;
		return;
	}
	
	// We also need to specify the number of directional subbands at each scale
	// This is specified by **Pyr_Level** matrices of size nDims * nDims
	// In 3-D, a sample matrix at the **i-th** scale can be
	//
	// | -1		K_i		K_i |
	// | K_i	-1		K_i | ,
	// | K_i	K_i		-1  |
	//
	// where K_i >= 0. Using this matrix, there will be 3 * 2 ^ (2 K_i) directional subbands at the i-th scale.
	// Note all the diagonal elements should be -1. It is possible (and better) to have different values 
	// of K_i at different scales, even in the same scale, at different off-diagonal locations.
	// In this way, we can adaptively choose the angular resolution of the surfacelets at different scales
	// and different directions.

	// For simplicity, in this example, we use the same K value for all scales.
	int K = 2;

	// A matrix of nDims * nDims
	int *Levels = new int [nDims * nDims];
	int iLevel, i, j, idx;
	
	for (iLevel = 0; iLevel < Pyr_Level; iLevel++)
	{
		idx = 0;
		for (i = 0; i < nDims; i++)
			for (j = 0; j < nDims; j++)
			{
				Levels[idx++] = (i == j)? -1 : K;
			}

		// store this info
		rec_info.SetNdfbLevel(iLevel, Levels);
	}

	// The input array and reconstructed array
	SurfArray InArray, RecArray;

	// The output subbands from the decomposition
	// This are a lowpass subband and a sequence of highpass directional subbands
	// The highpass arrays are indexed as follows
	//
	// OutArrays[iLevel][iDim][iDirection]
	//
	// iLevel:		scale of the pyramid (0 - Pyr_Level - 1)
	// iDim:		the dominant direction of the directional subband (0 - nDims - 1)
	// iDirection:	index into the directional subbands within a dominant direction (0 - 2 ^ (2K) - 1)
	SurfArray LowpassArray, ***OutArrays;
	OutArrays = new SurfArray** [Pyr_Level];

	// the dimension of the input array
    int pDims[100];

	// a 64 * 64 * 64 array. Try larger sizes if the computer has more memory.

	pDims[0] = 64;
    pDims[1] = 64;
    pDims[2] = 64;
    pDims[3] = 64; // try 4-D array? Change nDims to 4
	pDims[4] = 64;  // 5-D ?

    try
    {
		// total number of points in the input array
        int nTotalPoints = 1;
        for (i = 0; i < nDims; i++)
            nTotalPoints *= pDims[i];

		// Create an array filled with random numbers
		double *pInData = new double [nTotalPoints];
        random_src(pInData, nTotalPoints);

        // Allocate memory space for InArray according to the specified dimensions
		// A memory block slightly larger than nTotalPoints * sizeof(double) will be
		// allocated. The extra memory is used for padding along the last dimension.
		// In this way, we can implement an in-place version of the real-valued FFT
		// on the allocated memory space.
		// Example: a 2-D real-valued array of size 128 * 128 will be given a space
		// of 128 * 130. See the user manual of FFTW for more details.

        InArray.AllocateSpace(nDims, pDims);

		// Because of the padding, we cannot simply use memcpy to copy the data from
		// pInData to the internal memory held by InArray. Instead, the following
		// member function takes care of the padding.
        InArray.ImportRealValues(pInData);

        clock_t start = clock();
        double secs;

		// Surfacelet filter bank decomposition
		// InArray -> OutArrays and LowpassArray
		bool IsParameterValid;
        IsParameterValid = surf_fb.GetDecomposition(InArray, OutArrays, LowpassArray, rec_info);
		
		// We need to check this condition to see if the decomposition parameters are valid.
		if (!IsParameterValid)
			throw false;

        secs = (clock() - start) / (double) CLK_TCK;

		cout << endl << "Done: surfacelet decomposition. Time elapsed = " << secs << " seconds" << endl;

        start = clock();

		// Surfacelet filter bank reconstruction
        surf_fb.GetReconstruction(OutArrays, LowpassArray, RecArray, rec_info);

        secs = (clock() - start) / (double) CLK_TCK;

        cout << endl << "Done: surfacelet reconstruction. Time elapsed = " << secs << " seconds" << endl;

		// Free the memory space occupied by the subbands
		for (iLevel = 0; iLevel < Pyr_Level; iLevel++)
		{
			for (i = 0; i < nDims; i++)
			{
				delete [] OutArrays[iLevel][i];
			}

			delete [] OutArrays[iLevel];
		}

		// Export the reconstructed array
		double *pReconstruction = new double [nTotalPoints];
        RecArray.ExportRealValues(pReconstruction);

		// Check perfect reconstruction
		// The reconstructed array should equal the original array up to numerical precision.
        double err, diff = 0.0;
        for (i = 0; i < nTotalPoints; i++)
        {
            err = pInData[i] - pReconstruction[i];
            diff += err * err;
        }
		diff /= nTotalPoints;

        cout << endl << "Reconstruction MSE = " << diff << endl;

		delete [] pReconstruction;
		delete [] pInData;

    }
    catch(std::bad_alloc)
    {
        cout << endl << "Out of memory ..." << endl;
    }
	catch(bool err)
	{
		cout << endl << "Decomposition parameters are not compatible with the input array size." << endl;
	}
	catch(...)
	{
		cout << endl << "Something wrong ... " << endl;
	}

	delete [] Levels;
	delete [] OutArrays;

}



//////////////////////////////////////////////////////////////////////////
//  Testing the adjoint of the surfacelet filter bank
//////////////////////////////////////////////////////////////////////////
//
//  If we denote by T and T* the forward surfacelet transform and its adjoint, respectively, then
//  for any vectors x and y, we should have
//
//           <T x, y>_L2 = <x, T* y>_L2.
//
//  We check this identity in the following test.

void Surfacelet_adjoint_test()
{
	// Create an object for surfacelet filter bank decomposition and reconstruction
	SurfaceletFilterBank surf_fb;

	// We store all the decomposition parameters here
	SurfaceletRecInfo rec_info;

	// Number of decomposition levels of the multiscale pyramid
	int Pyr_Level = 2; // can be 1, 2, 3, 4, 5, ...

	// Operation mode of the pyramid filter bank 
	enum Pyramid_Mode pyr_mode = DOWNSAMPLE_1;

	// The number of dimensions of the input signal (2, 3, 4, ...)
	int nDims = 3; // a 3-D array

	// the dimension of the input array
	int pDims[3];

	// a 64 * 64 * 64 array. Try larger sizes if the computer has more memory.
	pDims[0] = 64;
	pDims[1] = 64;
	pDims[2] = 64;

	// Smooth function used in specifying the lowpass and highpass filters
	enum SmoothFunctionType func_type = RAISED_COSINE;
	// Some parameters used in the hourglass filter bank
	int mSize = 15;
	double beta = 2.5, lambda = 4.0;
	// The order of the checkerboard filters
	int bo = 8;

	//////////////////////////////////////////////////////////////////////////
	// IMPORTANT: change the directory string accordingly
	// It should specify the folder in which the filter coefficients are stored.
	//////////////////////////////////////////////////////////////////////////
	string dir_info = "../../filters/";
	//////////////////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////////

	try
	{
		// Now we save the above parameters into rec_info
		rec_info.SetParameters(nDims, bo, mSize, beta, lambda, Pyr_Level, pyr_mode, func_type, dir_info);
	}
	catch (...)
	{
		// filter coefficients files not found
		cout << endl << "Filter coefficients files are either not found or corrupted. Check if the given directory is correct." << endl;
		return;
	}

	// Next, we specify the number of directional subbands at each scale.
	// This is done by assigning a 3-by-3 matrix for each scale.

	// A matrix of nDims * nDims
	int Levels[9];
	int iLevel, i, j, idx;
	int K;

	for (iLevel = 0; iLevel < Pyr_Level; iLevel++)
	{
		idx = 0;

		// Example: Choose K_0 = 2, K_1 = 1, K_2 = 1, ...
		// In this way, there will be 3 * 2 ^ (2 * 2) directional subbands at the finest scale,
		// and 3 * 2 ^ (2 * 1) directional subbands at all other scales.
		K = (iLevel == 0)? 2 : 1;

		for (i = 0; i < nDims; i++)
			for (j = 0; j < nDims; j++)
			{
				Levels[idx++] = (i == j)? -1 : K;
			}

		// store this info
		rec_info.SetNdfbLevel(iLevel, Levels);
	}

	// The input array and reconstructed array
	SurfArray Array_x, Array_y;

	SurfArray LowpassArray_x, ***HighpassArrays_x = NULL;
	SurfArray LowpassArray_y, ***HighpassArrays_y = NULL;

	double *CoeffVector_x = NULL, *CoeffVector_y = NULL;
	int Length_CoeffVector;

	HighpassArrays_x = new SurfArray** [Pyr_Level];

	double ip1, ip2; // the two inner product values;

	try
	{
		Array_x.AllocateSpace(nDims, pDims);

		// Fill the array with random numbers
		Array_x.FillRandomNumbers();

		SurfArray Array_x_save;
		Array_x_save = Array_x;

		clock_t start = clock();
		double secs;

		// Surfacelet filter bank decomposition
		// InArray -> OutArrays and LowpassArray
		bool IsParameterValid;
		IsParameterValid = surf_fb.GetDecomposition(Array_x, HighpassArrays_x, LowpassArray_x, rec_info);

		// We need to check this condition to see if the decomposition parameters are valid.
		if (!IsParameterValid)
			throw false;

		secs = (clock() - start) / (double) CLK_TCK;

		cout << endl << "Done: surfacelet decomposition. Time elapsed = " << secs << " seconds" << endl;

		// Convert the coefficients to a linear vector
		CoeffVector_x = surf_fb.SurfaceletCoeff2Vec(HighpassArrays_x, LowpassArray_x, rec_info, Length_CoeffVector);
		
		// Create the y vector of the same size
		CoeffVector_y = new double [Length_CoeffVector];

		// then fill in random numbers
		random_src(CoeffVector_y, Length_CoeffVector);
	
		// Calculate the first inner product value ip1 = <T x, y>_L2
		ip1 = 0.0;
		double *p1 = CoeffVector_x, *p2 = CoeffVector_y;
		for (i = 0; i < Length_CoeffVector; i++)
			ip1 += (*(p1++)) * (*(p2++));

		delete [] CoeffVector_x;
		CoeffVector_x = NULL;

		// Restructure y into nested cell arrays
		surf_fb.SurfaceletVec2Coeff(HighpassArrays_y, LowpassArray_y, rec_info, CoeffVector_y, Length_CoeffVector, pDims);
		
		delete [] CoeffVector_y;
		CoeffVector_y = NULL;

		start = clock();

		// Adjoint of the surfacelet filter bank
		surf_fb.GetAdjoint(HighpassArrays_y, LowpassArray_y, Array_y, rec_info);
		
		secs = (clock() - start) / (double) CLK_TCK;

		cout << endl << "Done: surfacelet adjoint operator. Time elapsed = " << secs << " seconds" << endl;

		// Free the memory space occupied by the subbands
		for (iLevel = 0; iLevel < Pyr_Level; iLevel++)
		{
			for (i = 0; i < nDims; i++)
			{
				delete [] HighpassArrays_x[iLevel][i];
				delete [] HighpassArrays_y[iLevel][i];
			}

			delete [] HighpassArrays_x[iLevel];
			delete [] HighpassArrays_y[iLevel];
		}


		// Calculate the second inner product ip2 = <x, T* y>_L2
		ip2 = Array_x_save.InnerProduct(Array_y);

		cout << endl << "Ratio between the two inner product = " << ip1 / ip2 << endl;

	}
	catch(std::bad_alloc)
	{
		cout << endl << "Out of memory ..." << endl;
	}
	catch(bool err)
	{
		cout << endl << "Decomposition parameters are not compatible with the input array size." << endl;
	}
	catch(...)
	{
		cout << endl << "Something wrong ... " << endl;
	}

	if (HighpassArrays_x) delete [] HighpassArrays_x;
	if (HighpassArrays_y) delete [] HighpassArrays_y;
	if (CoeffVector_x) delete [] CoeffVector_x;
	if (CoeffVector_y) delete [] CoeffVector_y;
}

//	This software is provided "as-is", without any express or implied
//	warranty. In no event will the authors be held liable for any 
//	damages arising from the use of this software.