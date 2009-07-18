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
//	HourglassFilterBank.cpp
//	
//	First created: 02-28-06
//	Last modified: 03-18-06
//
//////////////////////////////////////////////////////////////////////////

#include "HourglassFilterBank.h"
#include "math.h"
#include "fftw3.h"
#include <cassert>
#include <exception>
using namespace std;

extern void MessageLog(const char*, const char*, const char*);

// A small number used in calculating the modified Bessel function
extern const double EPSILON = 1e-12;
extern const double PI = 3.14159265358979323846;

//////////////////////////////////////////////////////////////////////////
//	Constructor
//////////////////////////////////////////////////////////////////////////

HourglassFilterBank::HourglassFilterBank(void)
{

}


//////////////////////////////////////////////////////////////////////////
//	Destructor
//////////////////////////////////////////////////////////////////////////

HourglassFilterBank::~HourglassFilterBank(void)
{
	// do nothing here
}


//////////////////////////////////////////////////////////////////////////
//	Hourglass Filter Bank Decomposition
//////////////////////////////////////////////////////////////////////////
//
//	PARAMETERS:
//
//	InArray
//		Input data array (can be either real-valued original data or the corresponding Fourier Transform
// 
//	OutArrays
//		nDims output data array, where nDims is the number of dimensions of the input array
// 
//	OutputInFourierDomain
//		If true, leave output in the frequency domain
// 
//	mSize
//		size of the diamond mapping kernel
//
//	beta
//		for Kaiser window
//
//	lambda
//		see paper for more details

void HourglassFilterBank::GetDecomposition(SurfArray& InArray, SurfArray OutArrays[], bool OutputInFourierDomain,
		int mSize /* = 15 */, double beta /* = 2.5 */, double lambda /* = 4.0 */)
{
	int nDims = InArray.GetRank();
    // We only work on problems of dimensions of 2 and above
	assert(nDims >= 2);

    // Convert the input array to the Fourier domain if it is necessary.
	if (InArray.IsRealValued()) 
		InArray.GetInPlaceForwardFFT();
    
    int *pDims = NULL;
	SurfMatrix *pDiamondMapping = NULL;
	SurfMatrix **pHourglassFilters = NULL;
	double **pOut = NULL;

	// IMPORTANT
	// to keep up with the MATLAB version
	lambda /= 2.0;

	// Allocate memory space
	try
	{
		pDims = new int [nDims];

        // Get the array size
        InArray.GetDims(pDims);

		pDiamondMapping = new SurfMatrix;
		pDiamondMapping->AllocateSpace(2 * mSize - 1, 2 * mSize - 1);
		pHourglassFilters = new SurfMatrix* [nDims * (nDims - 1)];
		pOut = new double* [nDims];

        // allocate memory space for output arrays
        for (int i = 0; i < nDims; i++)
            OutArrays[i].AllocateSpace(nDims, pDims);
	}
	catch (std::bad_alloc)
	{
		MessageLog("HourglassFilterBank", "GetDecomposition", "Insufficient Memory!");
		if (pDims) delete [] pDims;
		if (pDiamondMapping) delete pDiamondMapping;
		if (pHourglassFilters) delete [] pHourglassFilters;
		throw;
	}
    
	
    // Check if input parameters are valid
    int k, MinLength = pDims[0] + 1;
    for (k = 0; k < nDims; k++)
        if (MinLength > pDims[k])
            MinLength = pDims[k];

	// must be large enough to hold the diamond mapping kernel
    assert(MinLength >= (2 * mSize - 1));
    
	// Get the 2-D diamond and hourglass filters
	GetDiamondMapping(mSize, beta, pDiamondMapping);
	GetHourglassFilters(nDims, pDims, pDiamondMapping, pHourglassFilters, lambda);

	// Filtering
	int padding;
	double *pIn = InArray.GetPointer(padding);
	for (k = 0; k < nDims; k++)
	{
		pOut[k] = OutArrays[nDims - 1 - k].GetPointer(padding);
		OutArrays[nDims - 1 - k].SetIsRealValued(false);
	}
	DecompositionFiltering(nDims, pDims, pIn, pOut, pHourglassFilters);
    	
	// If necessary, convert the output back to the spatial domain
	if (!OutputInFourierDomain)
	{
		for (k = 0; k < nDims; k++)
			OutArrays[k].GetInPlaceBackwardFFT();
	}


	delete [] pDims;
	delete pDiamondMapping;
    for (k = 0; k < nDims * (nDims - 1); k++)
        delete pHourglassFilters[k];
	delete [] pHourglassFilters;
	delete [] pOut;

	return;
}


//////////////////////////////////////////////////////////////////////////
//	Hourglass Filter Bank Reconstruction
//////////////////////////////////////////////////////////////////////////
//
//	PARAMETERS:
//
//	InArrays
//		nDims input data arrays (can be either real-valued original data or the corresponding Fourier Transform
//
//	OutArray
//		the output data array
//
//	OutputInFourierDomain
//		if true, leave output in the frequency domain
//
//	mSize
//		size of the diamond mapping kernel
// 
//	beta
//		for Kaiser window
// 
//	lambda
//		see paper for more details

void HourglassFilterBank::GetReconstruction(SurfArray InArrays[], SurfArray& OutArray, bool OutputInFourierDomain,
			int mSize /* = 15 */, double beta /* = 2.5 */, double lambda /* = 4.0 */)
{
	int nDims = InArrays[0].GetRank();
	// We only work on problems of dimensions of 2 and above
	assert(nDims >= 2);

	// Convert the input array to the Fourier domain if it is necessary.
	int k;
	for (k = 0; k < nDims; k++)
		if (InArrays[k].IsRealValued()) 
			InArrays[k].GetInPlaceForwardFFT();

	int *pDims = NULL;
	SurfMatrix *pDiamondMapping = NULL;
	SurfMatrix **pHourglassFilters = NULL;
	double **pIn = NULL;

	// IMPORTANT
	// to keep up with the MATLAB version
	lambda /= 2.0;

	// Allocate memory space
	try
	{
		pDims = new int [nDims];

        // Get the array size
        InArrays[0].GetDims(pDims);

		pDiamondMapping = new SurfMatrix;
		pDiamondMapping->AllocateSpace(2 * mSize - 1, 2 * mSize - 1);
		pHourglassFilters = new SurfMatrix* [nDims * (nDims - 1)];
		pIn = new double* [nDims];

        OutArray.AllocateSpace(nDims, pDims);
	}
	catch (std::bad_alloc)
	{
		MessageLog("HourglassFilterBank", "GetDecomposition", "Insufficient Memory!");
		if (pDims) delete [] pDims;
		if (pDiamondMapping) delete pDiamondMapping;
		if (pHourglassFilters) delete [] pHourglassFilters;
		throw;
	}

	
	// Check if input parameters are valid
	int MinLength = pDims[0] + 1;
	for (k = 0; k < nDims; k++)
		if (MinLength > pDims[k])
			MinLength = pDims[k];

	// must be large enough to hold the diamond mapping kernel
	assert(MinLength >= (2 * mSize - 1));

	// Get the 2-D diamond and hourglass filters
	GetDiamondMapping(mSize, beta, pDiamondMapping);
	GetHourglassFilters(nDims, pDims, pDiamondMapping, pHourglassFilters, lambda);

	// Filtering
	int padding;
	double *pOut = OutArray.GetPointer(padding);
	OutArray.SetIsRealValued(false);
	for (k = 0; k < nDims; k++)
		pIn[k] = InArrays[nDims - 1 - k].GetPointer(padding);
	ReconstructionFiltering(nDims, pDims, pIn, pOut, pHourglassFilters);
	
	// If necessary, convert the output back to the spatial domain
	if (!OutputInFourierDomain)
	{
		OutArray.GetInPlaceBackwardFFT();
	}


	delete [] pDims;
	delete pDiamondMapping;
    for (k = 0; k < nDims * (nDims - 1); k++)
        delete pHourglassFilters[k];
	delete [] pHourglassFilters;
	delete [] pIn;

	return;
}


//////////////////////////////////////////////////////////////////////////
//	Filtering operation for the decomposition step.
//////////////////////////////////////////////////////////////////////////
//
//	PARAMETERS:
//
//	nDims
//		Dimension of the input signal, e.g., 2-D, 3-D, etc.
// 
//	pDims
//		Actual array dimensions, e.g., 320 * 240 * 256, etc.
//
//	pDataIn
//		Pointer to the input data.
//      Note: Input data are in the Fourier domain, and the last dimension is
//      almost cut in half. See SurfArray.h for more details.
// 
//	pDataOut
//		Pointers to the N output array.
// 
//	pHourglass
//		Pointer to the hourglass filter coefficients at different 2-D planes
//
//	Explanation: (tricky!)
// 
//	For the case of N dimensional signals, we need a total of (n^2 - n) different 2-D planes.
//	For example, (3,2), (3, 1), (2, 3), (2, 1), (1, 3), (1, 2)
//	They are stored in the memory pointed to by pHourglass in the above order. 
//	Within each plane, the hourglass direction aligns with the second (i.e. continuous) dimension .

void HourglassFilterBank::DecompositionFiltering(int nDims, int* pDims, 
		double *pDataIn, double *pDataOut[], SurfMatrix *pHourglass[])
{
	int *pIndices = NULL;
    double *pFilterValue = NULL;
    double **pHourglassFilters = NULL;

	try
	{
		pIndices = new int [nDims];
		pFilterValue = new double [nDims];
		pHourglassFilters = new double * [nDims * (nDims - 1)];
	}
	catch (std::bad_alloc)
	{
		MessageLog("HourglassFilterBank", "DecompositionFiltering", "Out of memory!");
		if (pIndices) delete [] pIndices;
		if (pFilterValue) delete [] pFilterValue;
	}
		
	register int m, k; // These two have the priority to get the register
	register int i; 
	register int j;
	int iSlice, nSlices, nDimLast, nDimSecondLast;

    for (k = 0; k < nDims * (nDims - 1); k++)
        pHourglassFilters[k] = pHourglass[k]->GetPointer();

	// Initialize array indices
	for (k = 0; k < nDims; k++)
		pIndices[k] = 0;

	// number of 2-D slices
	nSlices = 1;
	for (k = 0; k <= nDims - 3; k++)
		nSlices *= pDims[k];

	// Number of complex numbers along the last dimension.
	// Note: we utilize the conjugate symmetry in the Fourier transform of real signals,
	// so the data size is nearly reduced by half.
	nDimLast = pDims[nDims - 1] / 2 + 1;
	nDimSecondLast = pDims[nDims - 2];

	double val_Real, val_Imag;

	double denominator, FilterValue;
    int idxHourglass;

    // Start the computation ...
	for (iSlice = 0; iSlice < nSlices; iSlice++)
	{
		for (j = 0; j < nDimSecondLast; j++)
		{
			pIndices[nDims - 2] = j;

			for (i = 0; i < nDimLast; i++)
			{
				pIndices[nDims - 1] = i;
				
				denominator = 0.0;

				idxHourglass = 0;
                
				// Fill in pFilterValue;
				for (k = nDims - 1; k >= 0; k--)
				{
					FilterValue = 1.0;

					for (m = nDims - 1; m >= 0; m--)
					{
						if (k == m) continue;

                        FilterValue *= *(pHourglassFilters[idxHourglass++] 
                                + pIndices[k] + pIndices[m] * pDims[k]);
                                                
					}

					pFilterValue[nDims - 1 - k] = FilterValue;

					denominator += FilterValue * FilterValue;
				}

				denominator = sqrt(denominator / (double)nDims);

				for (k = 0; k < nDims; k++)
					pFilterValue[k] /= denominator;

				val_Real = *(pDataIn++);
				val_Imag = *(pDataIn++);

				for (k = 0; k < nDims; k++)
				{
					// Input and Output data are complex-valued, while the filter is real-valued.
                    *(pDataOut[k]++) = val_Real * (FilterValue = pFilterValue[k]);
					*(pDataOut[k]++) = val_Imag * FilterValue;
				}

			}

		}

		// Update pIndices
		for (k = nDims - 3; k >= 0; k--)
		{
			if ( (++pIndices[k]) < pDims[k])
				break;
			else
				pIndices[k] = 0;
						
		}

	}

	delete [] pHourglassFilters;
	delete [] pFilterValue;
	delete [] pIndices;

    return;

}


//////////////////////////////////////////////////////////////////////////
//	Filtering operation for the reconstruction step.
//////////////////////////////////////////////////////////////////////////
//
//	PARAMETERS:
//
//	nDims
//		Dimension of the input signal, e.g., 2-D, 3-D, etc.
// 
//	pDims
//		Actual array dimensions, e.g., 320 * 240 * 256, etc.
//
//	pDataIn
//		Pointers to the N input data.
//      Note: Input data are in the Fourier domain, and the last dimension is
//      almost cut in half. See SurfArray.h for more details.
// 
//	pDataOut
//		Pointer to the output array.
// 
//	pHourglass
//		Pointer to the hourglass filter coefficients at different 2-D planes
//
//	Explanation: (tricky!)
//
//	See DecompositionFilter for more details.

void HourglassFilterBank::ReconstructionFiltering(int nDims, int* pDims, 
        double *pDataIn[], double *pDataOut, SurfMatrix *pHourglass[])
{
	int *pIndices = NULL;
	double *pFilterValue = NULL;
	double **pHourglassFilters = NULL;

	try
	{
		pIndices = new int [nDims];
		pFilterValue = new double [nDims];
		pHourglassFilters = new double * [nDims * (nDims - 1)];
	}
	catch (std::bad_alloc)
	{
		MessageLog("HourglassFilterBank", "DecompositionFiltering", "Out of memory!");
		if (pIndices) delete [] pIndices;
		if (pFilterValue) delete [] pFilterValue;
	}
    register int m, k; // These two have the priority to get the register
    register int i; 
    register int j;
    int iSlice, nSlices, nDimLast, nDimSecondLast;

    for (k = 0; k < nDims * (nDims - 1); k++)
        pHourglassFilters[k] = pHourglass[k]->GetPointer();

    // Initialize array indices
    for (k = 0; k < nDims; k++)
        pIndices[k] = 0;

    // number of 2-D slices
    nSlices = 1;
    for (k = 0; k <= nDims - 3; k++)
        nSlices *= pDims[k];

    // Number of complex numbers along the last dimension.
    // Note: we utilize the conjugate symmetry in the Fourier transform of real signals,
    // so the data size is nearly reduced by half.
    nDimLast = pDims[nDims - 1] / 2 + 1;
    nDimSecondLast = pDims[nDims - 2];

    double denominator, FilterValue, SumReal, SumImag;
    int idxHourglass;

    // Start the computation ...
    for (iSlice = 0; iSlice < nSlices; iSlice++)
    {
        for (j = 0; j < nDimSecondLast; j++)
        {
            pIndices[nDims - 2] = j;

            for (i = 0; i < nDimLast; i++)
            {
                pIndices[nDims - 1] = i;

                denominator = 0.0;

                idxHourglass = 0;

                // Fill in pFilterValue;
                for (k = nDims - 1; k >= 0; k--)
                {
                    FilterValue = 1.0;

                    for (m = nDims - 1; m >= 0; m--)
                    {
                        if (k == m) continue;

                        FilterValue *= *(pHourglassFilters[idxHourglass++] 
                            + pIndices[k] + pIndices[m] * pDims[k]);

                    }

                    pFilterValue[nDims - 1 - k] = FilterValue;

                    denominator += FilterValue * FilterValue;
                }

                denominator = sqrt(denominator * double(nDims));

                for (k = 0; k < nDims; k++)
                    pFilterValue[k] /= denominator;

                SumReal = SumImag = 0.0;

                for (k = 0; k < nDims; k++)
                {
                    // Input and Output data are complex-valued, while the filter is real-valued.
                    SumReal += *(pDataIn[k]++) * (FilterValue = pFilterValue[k]);
                    SumImag += *(pDataIn[k]++) * (FilterValue);
                }

                *(pDataOut++) = SumReal;
                *(pDataOut++) = SumImag;

            }

        }

        // Update pIndices
        for (k = nDims - 3; k >= 0; k--)
        {
            if ( (++pIndices[k]) < pDims[k])
                break;
            else
                pIndices[k] = 0;

        }

    }

	delete [] pHourglassFilters;
	delete [] pFilterValue;
	delete [] pIndices;

    return;

}


//////////////////////////////////////////////////////////////////////////
//	Get the hourglass filters along all possible 2-D planes
//////////////////////////////////////////////////////////////////////////
//
//	PARAMETERS:
//
//	nDims
//		Dimension of the input signal, e.g., 2-D, 3-D, etc.
// 
//	pDims
//		Actual array dimensions, e.g., 320 * 240 * 256, etc.
//
//	pMappingMatrix
//		A matrix containing the diamond mapping kernel
//
//	pHourglassFilters
//		The resulting hourglass filters along different 2-D planes
//
//	lambda
//		See paper for more details

void HourglassFilterBank::GetHourglassFilters(int nDims, int *pDims, SurfMatrix *pMappingMatrix, 
            SurfMatrix *pHourglassFilters[], double lambda)
{
    register int k, m;
	register int i, j;
	SurfArray *pDiamond = NULL;
	SurfMatrix *pHourglass;
	int Dims2D[2];
	double *pMapping, *pDiamondFilter;
	int padding;

	assert(pMappingMatrix->nx == pMappingMatrix->ny);

	int DiamondSize = pMappingMatrix->nx;
	
	for (i = 0; i < nDims * (nDims - 1); i++)
		pHourglassFilters[i] = NULL;

	try
	{
		int idx = 0;
		for (i = nDims - 1; i >= 0; i--)
			for (j = nDims - 1; j >= 0; j--)
			{
				if (i == j) continue;
				
				pDiamond = new SurfArray;
				Dims2D[0] = pDims[j];
				Dims2D[1] = pDims[i];
				pDiamond->AllocateSpace(2, Dims2D);

				// Import values
				assert((Dims2D[0] >= DiamondSize) && (Dims2D[1] >= DiamondSize));
				assert(Dims2D[1] % 2 == 0);

				pDiamondFilter = pDiamond->GetPointer(padding);
				pMapping = pMappingMatrix->GetPointer();
				
				for (k = 0; k < DiamondSize; k++)
				{
					for (m = 0; m < DiamondSize; m++)
						*(pDiamondFilter++) = *(pMapping++);
					memset(pDiamondFilter, 0, (Dims2D[1] - DiamondSize) * sizeof(double));
					pDiamondFilter += (Dims2D[1] - DiamondSize + padding);

				}
				memset(pDiamondFilter, 0, (Dims2D[1] + padding) * (Dims2D[0] - DiamondSize) * sizeof(double));
				// Get its Fourier transform
				pDiamond->GetInPlaceForwardFFT();
				pDiamond->GetMagnitudeResponse();

				pHourglassFilters[idx++] = pHourglass = new SurfMatrix;
				pHourglass->AllocateSpace(Dims2D[0], Dims2D[1]);
				pDiamond->ExportRealValues(pHourglass->GetPointer());

				// Delete the diamond filter
				delete pDiamond;
				pDiamond = NULL;

				// Get the hourglass filter by shifting the diamond filter
				pHourglass->CircularShift(0, Dims2D[1] / 2);
                
                // Raise the matrix values to the power of lambda
                (*pHourglass) ^ lambda;
                
	
			}
	}
	catch (std::bad_alloc)
	{
		MessageLog("HourglassFilterBank", "GetHourglassFilters", "Out of memory!");
		for (i = 0; i < nDims * (nDims - 1); i++)
			if (pHourglassFilters[i]) delete pHourglassFilters[i];

		if (pDiamond) delete pDiamond;
		
		throw;
	}
	
}


//////////////////////////////////////////////////////////////////////////
//	Diamond mapping used in the hourglass filter bank
//////////////////////////////////////////////////////////////////////////
//
//	PARAMETERS:
//
//	nOrder
//		The order of the diamond mapping kernel
//
//	beta
//		For Kaiser window
//
//  pMappingMatrix
//		A matrix containing the resulting diamond mapping kernel

void HourglassFilterBank::GetDiamondMapping(int nOrder, double beta, SurfMatrix* pMappingMatrix)
{
	// nOrder must be an odd number greater than or equal to 3
	assert((nOrder >= 3) && ((nOrder / 2) * 2) != nOrder);
	
	double *pMapping = pMappingMatrix->GetPointer();

	double *pWin = new double [nOrder];
	int i, center;
	
    GetKaiserWindow(nOrder, beta, pWin);
	// Modulate the Kaiser window
	center = (nOrder - 1) / 2;
	for (i = 0; i < nOrder; i++)
	{
		pWin[i] *= Sinc((i - center) / 2.0);
	}

	int x1, x2, idx;
	double val;
	for (x1 = - (nOrder - 1); x1 <= nOrder - 1; x1++)
		for (x2 = -(nOrder - 1); x2 <= nOrder - 1; x2++)
		{
			idx = x1 + x2 + center;
			if ((idx < 0) || (idx >= nOrder))
				val = 0.0;
			else
				val = pWin[idx];

			idx = x2 - x1 + center;
			if ((idx < 0) || (idx >= nOrder))
				val = 0.0;
			else
				val *= pWin[idx];

			idx = (2 * nOrder - 1) * (x2 + nOrder - 1) + (x1 + nOrder - 1);
			pMapping[idx] = val;
		}
	
	delete [] pWin;

	return;
}


//////////////////////////////////////////////////////////////////////////
//	Get the Kaiser smoothing window
//////////////////////////////////////////////////////////////////////////
//
//	PARAMETERS:
//
//	nOrder
//		The order of the diamond mapping
//
//	beta
//		For Kaiser window
//
//	pWin
//		Pointer to the Kaiser window

void HourglassFilterBank::GetKaiserWindow(int nOrder, double beta, double* pWin)
{
	// nOrder should be an odd integer greater than or equal to 3.
	// We will not check these conditions here.

	double denominator = CalculateI0(beta);
	int i, center;
	double val;


	center = (nOrder - 1) / 2;
	for (i = 0; i <= center; i++)
	{
		val = 2 * i / (double)(nOrder - 1) - 1;
		pWin[i] = CalculateI0(beta * sqrt(1 - val * val)) / denominator;
	}

	// Utilize the symmetry
	for (i = 1; i <= center; i++)
	{
		pWin[center + i] = pWin[center - i];
	}
}


//////////////////////////////////////////////////////////////////////////
//	Calculate the 0th-order modified Bessel function I_0
//////////////////////////////////////////////////////////////////////////

double HourglassFilterBank::CalculateI0(double x)
{
	// y = sum_{k=0}^\infty ((x/2)^k / k!)^2
	
	double y = 1.0, z = 1.0, t;
	int k = 1;
	
	x = fabs(x) / 2.0;

	do 
	{
		z *= x / (k++);
		t = z * z;
		y += t;
	} while(t > EPSILON);

	return y;
}


//////////////////////////////////////////////////////////////////////////
//	y = sinc(x) = sin(\pi x) / (\pi x)
//////////////////////////////////////////////////////////////////////////

double HourglassFilterBank::Sinc(double x)
{
	double y;
	if (fabs(x) <= EPSILON)
	{
		y = 1.0;
	}
	else
	{
		y = sin(PI * x) / (PI * x);
	}

	return y;
}


//	This software is provided "as-is", without any express or implied
//	warranty. In no event will the authors be held liable for any 
//	damages arising from the use of this software.