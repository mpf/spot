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
//	SurfArray.h
//	
//	First created: 03-13-06
//	Last modified: 04-10-06
//
//////////////////////////////////////////////////////////////////////////


#ifndef SURF_ARRAY_HEADER
#define SURF_ARRAY_HEADER

#include "SurfMatrix.h"

//////////////////////////////////////////////////////////////////////////
//  Multidimensional numerical arrays
//////////////////////////////////////////////////////////////////////////

class SurfArray
{
public:
	SurfArray();
	~SurfArray();
	
	//  Allocate necessary memory spaces
	void AllocateSpace(int N, int* dims);
	
	// Fill the internal data buffer with data pointed to by pIn.
	void ImportRealValues(double* in);

	//	Export the internal data values.
	void ExportRealValues(double* out);

	//  Get the pointer to the data array
	double* GetPointer(int& padding);

	//  Apply forward FFT on the current array (in-place version)
	void GetInPlaceForwardFFT(int mode = 0);

	//  Apply backward FFT on the current array
	void GetInPlaceBackwardFFT(int mode = 0);

	//  Tell whether the current object is real-valued
	bool IsRealValued();

	//  Set the value domain
	void SetIsRealValued(bool RealValue);

	//  Get the number of dimension of the current array
	int GetRank();

	//  Get the logical dimensions
	void GetDims(int pDims[]);

	//  Get the number of real-valued elements
	int GetNumberOfElements();

	//  Fill the array with random numbers uniformly distributed from 0 to 1
	void FillRandomNumbers();

	//  Take the inner product between two real valued arrays
	double InnerProduct(SurfArray& Array2);

	// Get the magnitude frequency response
	void GetMagnitudeResponse();

	// Multiple each element of the array with a real number val
	void PointwiseMultiply(double val);

	// Multiply the N-D array by a 2-D slice
	void Multiply2dComplexSlice(int dim1, int dim2, SurfMatrix* pSlice);

	// Up-sampling the N-D array (in the frequency domain) separately
    void UpsampleF(SurfArray* newArray, int upRatio[]);

	//	Export the current array (in the frequency domain) with Hermitian
	//	symmetry along a specified dimension	
    double* NewHermitianSymmetryAxis(int NewAxis);

	//	Import frequency data into the current array
    void RestoreHermianSymmetryAxis(double *pIn, int PreviousAxis);

	//  Reset the current array object, free resources
    void Reset();

    // Zero-fill the current array
    void ZeroFill(void);
    
	//  Copy an array object
	SurfArray& operator = (SurfArray&);

private:
	int padding;
	int nDims;

	// dims of the array.
	// logical dimension: the size of the original array
	// real dimension: the size after padding
	int *pDims_logical, *pDims_real;

	// The place where we store the array
	double *pData;
	
	bool IsReal;
};

#endif

//	This software is provided "as-is", without any express or implied
//	warranty. In no event will the authors be held liable for any 
//	damages arising from the use of this software.