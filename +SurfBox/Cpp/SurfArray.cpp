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
//	SurfArray.cpp
//	
//	First created: 03-13-06
//	Last modified: 04-10-06
//
//////////////////////////////////////////////////////////////////////////

#include <cassert>
#include "SurfArray.h"
#include "fftw3.h"
#include <math.h>
#include <time.h>

extern void MessageLog(const char*, const char*, const char*);


//////////////////////////////////////////////////////////////////////////
//  Class constructor
//////////////////////////////////////////////////////////////////////////

SurfArray::SurfArray(void)
{
	// Initialize the data structures
    pData = NULL;
	pDims_logical = pDims_real = NULL;

    nDims = 0;

	// Default: the array constains real-valued data;
	IsReal = true;
}


//////////////////////////////////////////////////////////////////////////
//  Class destructor
//////////////////////////////////////////////////////////////////////////

SurfArray::~SurfArray(void)
{
	// pData is allocated by fftw, so it should be de-allocated by fftw too.
    if (pData) fftw_free(pData);

	if (pDims_real) delete [] pDims_real;

	if (pDims_logical) delete [] pDims_logical;
}


//////////////////////////////////////////////////////////////////////////
//  Reset the current array object, free resources
//////////////////////////////////////////////////////////////////////////

void SurfArray::Reset()
{
    if (pData) fftw_free(pData);

    if (pDims_real) delete [] pDims_real;

    if (pDims_logical) delete [] pDims_logical;

    pData = NULL;
    pDims_logical = pDims_real = NULL;

    // Default: the array constains real-valued data;
    IsReal = true;

    nDims = 0;
}


//////////////////////////////////////////////////////////////////////////
//  Get the pointer to the data array
//////////////////////////////////////////////////////////////////////////
//
// PARAMETERS:
//
// rPadding: 
//      return the internal padding value

double* SurfArray::GetPointer(int& rPadding)
{
	rPadding = padding;

	return pData;
}


//////////////////////////////////////////////////////////////////////////
//  Tell whether the current object is real-valued
//////////////////////////////////////////////////////////////////////////

bool SurfArray::IsRealValued()
{
	return IsReal;
}


//////////////////////////////////////////////////////////////////////////
//  Set the value domain
//////////////////////////////////////////////////////////////////////////

void SurfArray::SetIsRealValued(bool RealValue)
{
	IsReal = RealValue;
}


//////////////////////////////////////////////////////////////////////////
//  Get the number of dimension of the current array
//////////////////////////////////////////////////////////////////////////

int SurfArray::GetRank()
{
	return nDims;
}


//////////////////////////////////////////////////////////////////////////
//  Get the logical dimensions
//////////////////////////////////////////////////////////////////////////

void SurfArray::GetDims(int pDims[])
{
	for (register int i = 0; i < nDims; i++)
	{
		pDims[i] =  pDims_logical[i];
	}
}


//////////////////////////////////////////////////////////////////////////
//	Get the number of real-valued elements in the array
//////////////////////////////////////////////////////////////////////////

int SurfArray::GetNumberOfElements()
{
	int nElements = 1;
	for (register int i = 0; i < nDims; i++)
		nElements *= pDims_logical[i];

	return nElements;
}


//////////////////////////////////////////////////////////////////////////
//  Allocate necessary memory spaces
//////////////////////////////////////////////////////////////////////////
//
//  PARAMETERS:
//
//  N:
//      dimension of the array
//
//  dims:
//      an array of length N indicating the size of the array along each dimension

void SurfArray::AllocateSpace(int N, int* dims)
{
	nDims = N;

	// tricky: we use integer division here
	padding = 2 * (dims[nDims - 1] / 2 + 1) - dims[nDims - 1];

	int nPoints, i;

    // total number of data points
	nPoints = 1;
	for (i = 0; i <= nDims - 2; i++)
	{
		nPoints *= dims[i];
	}
	nPoints *= (dims[nDims - 1] + padding);
	
	// Allocate memory
	try
	{
		pDims_real = new int [nDims];
		pDims_logical = new int [nDims];
		// This thing is what we are really worrying about, considering its size ...
		pData = (double *)fftw_malloc(sizeof(double) * nPoints);

		if (!pData)
			throw 1;
	}
	catch (...)
	{
		MessageLog("SurfArray", "AllocateSpace", "Insufficient memory!");
		
		if (pDims_real)
		{
			delete [] pDims_real;
			pDims_real = NULL;
		}
		if (pDims_logical)
		{
			delete [] pDims_logical;
			pDims_logical = NULL;
		}
		if (pData) 
		{
			fftw_free(pData);
			pData = NULL;
		}	

		throw;
	}	

	// Note: we adopt the "row-major" convension in addressing 
	// multidimensional arrays.
	for (i = 0; i < nDims; i++)
	{
		pDims_real[i] = pDims_logical[i] = dims[i];
	}
	pDims_real[nDims - 1] += padding;

}


//////////////////////////////////////////////////////////////////////////
//  Apply forward FFT on the current array (in-place version)
//////////////////////////////////////////////////////////////////////////
//
//  NOTE:
//
//  We assume the input array is real-valued, so the output of FFT has Hermitian symmetry.
//  We only keep nearly half of the FFT samples, along the last (continuous) dimension.
//
//  PARAMETERS:
//
//  mode:
//      0: do not normalize
//      1: normalize by 1 / sqrt(n_total_points)

void SurfArray::GetInPlaceForwardFFT(int mode /* = 0 */)
{
	assert((pData != NULL) && (pDims_real != NULL) && (pDims_logical != NULL));
	
	assert(IsReal);

	fftw_plan planFFT;
	planFFT = fftw_plan_dft_r2c(nDims, pDims_logical, pData, (fftw_complex *)pData, FFTW_ESTIMATE);
	
	fftw_execute(planFFT);
	
	fftw_destroy_plan(planFFT);

	IsReal = false;

    double *ptr;
    int nPoints;
    double normalizer;

    switch(mode)
    {
    case 0:
        // do nothing
    	break;
    
    case 1:
        register int i;
        normalizer = 1.0;
        nPoints = 1;
        for (i = 0; i < nDims; i++)
        {
            normalizer /= pDims_logical[i];
            nPoints *= pDims_real[i];
        }
        normalizer = sqrt(normalizer);
        ptr = pData;
        for (i = 0; i < nPoints; i++)
            *(ptr++) *= normalizer;    
        
        break;

    default:
        // this should not happen
        assert(false);
        break;
    }

	return;
}


//////////////////////////////////////////////////////////////////////////
//  Apply backward FFT on the current array
//////////////////////////////////////////////////////////////////////////
//
//  PARAMETERS:
//
//  mode:
//      0: normalize by 1 / n_total_points
//      1: normalize by 1 / sqrt(n_total_points)
//      2: do not normalize

void SurfArray::GetInPlaceBackwardFFT(int mode /* = 0 */)
{
	assert((pData != NULL) && (pDims_real != NULL) && (pDims_logical != NULL));
	
	assert(!IsReal);
		
	fftw_plan planFFT;
	planFFT = fftw_plan_dft_c2r(nDims, pDims_logical, (fftw_complex *)pData, pData, FFTW_ESTIMATE);

	fftw_execute(planFFT);

	fftw_destroy_plan(planFFT);

	IsReal = true;

    if ((mode == 0) || (mode == 1))
    {     
        // Normalize the FFT result;
        register int i;
        double normalizer = 1.0;
        int nPoints = 1;
        for (i = 0; i < nDims; i++)
        {
            normalizer /= pDims_logical[i];
            nPoints *= pDims_real[i];
        }

        if (mode == 1)
            normalizer = sqrt(normalizer);

        double *ptr = pData;
        for (i = 0; i < nPoints; i++)
            *(ptr++) *= normalizer;    
    }
    else if ( mode != 2)
    {
        assert(false);
    }

	return;
}


//////////////////////////////////////////////////////////////////////////
//  Copy an array object
//////////////////////////////////////////////////////////////////////////
//
//  NOTE:
//
//  The array being copied to will allocate its own memory space.

SurfArray& SurfArray::operator = (SurfArray& Src)
{
    // free the current resource if there is any ...
    Reset();

    int *pDims;
    int N;
    try
    {
        N = Src.nDims;
        pDims = new int [N];
        Src.GetDims(pDims);
        AllocateSpace(N, pDims);
    }
    catch (std::bad_alloc)
    {
        MessageLog("SurfArray", "Operator =", "Out of memory");
        throw;
    }

    int i, n_total_points = 1;
    for (i = 0; i < N; i++)
        n_total_points *= pDims_real[i];

    // copy data values
    int padding;
    memcpy(pData, Src.GetPointer(padding), n_total_points * sizeof(double));

    // copy array status
    IsReal = Src.IsRealValued();

    delete [] pDims;
    return *this;
}


//////////////////////////////////////////////////////////////////////////
// Fill the internal data buffer with data pointed to by pIn.
// Appropriate padding will be taken care of.
//////////////////////////////////////////////////////////////////////////

void SurfArray::ImportRealValues(double* pIn)
{
	assert(IsReal);
	
	register int i, j;
	int nRows, lengthRow;

	nRows = 1;
	for (i = 0; i <= nDims - 2; i++)
	{
		nRows *= pDims_logical[i];
	}

	double *pVal = pData;
	lengthRow = pDims_logical[nDims - 1];

	for (i = 0; i < nRows; i++)
	{
		for (j = 0; j < lengthRow; j++)
			*(pVal++) = *(pIn++);

		pVal += padding;
	}
}


//////////////////////////////////////////////////////////////////////////
//	Multiple each element of the array with a real number val
//////////////////////////////////////////////////////////////////////////
//
//  PARAMETERS:
//
//  val: a scaler number

void SurfArray::PointwiseMultiply(double val)
{
	register int i;
	int n_total = 1;
	double *dst = pData;

	for (i = 0; i < nDims; i++)
		n_total *= pDims_real[i];

	for (i = 0; i < n_total; i++)
	{
		*dst *= val;
		dst++;
	}
}



//////////////////////////////////////////////////////////////////////////
//	Take the inner product between two real-valued arrays
//////////////////////////////////////////////////////////////////////////
//
//  PARAMETERS:
//
//  Array2: the second array which should have the same size as the current one.
//


double SurfArray::InnerProduct(SurfArray& Array2)
{
	// make sure the two arrays have the same size.
	assert(nDims == Array2.GetRank());

	int *pDims2 = new int [nDims];

	Array2.GetDims(pDims2);

	int match = 1;
	register int i, j;

	for (i = 0; i < nDims; i++)
	{
		if (pDims_logical[i] != pDims2[i])
		{
			match = 0;
			break;
		}
	}

	delete [] pDims2;

	assert(match);
		
	int nRows, lengthRow;

	nRows = 1;
	for (i = 0; i < nDims - 1; i++)
	{
		nRows *= pDims_logical[i];
	}

	double *pV1 = pData;
	double *pV2 = Array2.GetPointer(i);

	lengthRow = pDims_logical[nDims - 1];

	double s = 0.0;

	for (i = 0; i < nRows; i++)
	{
		for (j = 0; j < lengthRow; j++)
			s += (*(pV1++)) * (*(pV2++));

		pV1 += padding;
		pV2 += padding;
	}

	return s;
}



//////////////////////////////////////////////////////////////////////////
//	Export the internal data values.
//////////////////////////////////////////////////////////////////////////
//
//	Appropriate padding will be taken care of.

void SurfArray::ExportRealValues(double* pOut)
{
	assert(IsReal);
	
	register int i, j;
	int nRows, lengthRow;
		
	nRows = 1;
	for (i = 0; i < nDims - 1; i++)
	{
		nRows *= pDims_logical[i];
	}

	double *pVal = pData;
	lengthRow = pDims_logical[nDims - 1];
	
	for (i = 0; i < nRows; i++)
	{
		for (j = 0; j < lengthRow; j++)
			*(pOut++) = *(pVal++);

		pVal += padding;
	}
}


//////////////////////////////////////////////////////////////////////////
//	Fill the array with random numbers uniformly distributed from 0 to 1
//////////////////////////////////////////////////////////////////////////

void SurfArray::FillRandomNumbers()
{
	register int i;
	int n_Total = 1;
	
	for (i = 0; i < nDims; i++)
		n_Total *= pDims_real[i];

	srand((unsigned)time(NULL));

	double *dst = pData;
	for (i = 0; i < n_Total; i++)
		*(dst++) = (double)rand() / ((double)(RAND_MAX)+(double)(1));

}



//////////////////////////////////////////////////////////////////////////
//	Get the magnitude frequency response
//////////////////////////////////////////////////////////////////////////

void SurfArray::GetMagnitudeResponse()
{
	// The array must be in the Fourier domain
	assert(!IsReal);

	register int i, j;
	int nRows, lengthRow;

	// Total number of rows
	nRows = 1;
	for (i = 0; i < nDims - 1; i++)
	{
		nRows *= pDims_logical[i];
	}

	double *pMagnitude = pData, *pMagMirror;
	double *pReal = pData, *pImag = pData + 1;
	lengthRow = pDims_real[nDims - 1] / 2;

	for (i = 0; i < nRows; i++)
	{
		for (j = 0; j < lengthRow; j++)
		{
			*(pMagnitude++) = sqrt((*pReal) * (*pReal) + (*pImag) * (*pImag));
			pReal += 2;
			pImag += 2;
		}
	
		// tricky!
		// verify the following by trying two cases
		// (1) pDims_logicalp[nDims - 1] is even
		// (2) pDims_logicalp[nDims - 1] is odd
		pMagMirror = pMagnitude - padding;
		for (j = 0; j < lengthRow - padding; j++)
			*(pMagnitude++) = *(pMagMirror--);

		pMagnitude += padding;
		
	}

	IsReal = true;
}


//////////////////////////////////////////////////////////////////////////
//  Fill the current array with zeros
//////////////////////////////////////////////////////////////////////////

void SurfArray::ZeroFill()
{
    if (pData)
    {
        int i, n_total_numbers = 1;
        for (i = 0; i < nDims; i++)
            n_total_numbers *= pDims_real[i];

        memset(pData, 0, n_total_numbers * sizeof(double));
    }
}

//////////////////////////////////////////////////////////////////////////
//	Repeat the current array along each of its dimensions
//////////////////////////////////////////////////////////////////////////
//
//	WARNING:
//		
//	This routine has not be tested.

void RepeatArray(int N, int pDims[], int repRatio[], double *src, double *dst, int padding, double *pBuffer)
{
    double *pVal, *pVal_mirror;
    register int i;
    int nMirror;
    if (N == 1)
    {
        if (repRatio[0] == 1)
            memcpy(dst, src, (pDims[0] + padding) * sizeof(double));
        else
        {
            memcpy(pBuffer, src, (pDims[0] + padding) * sizeof(double));
            pVal = pBuffer + pDims[0] + padding;
            pVal_mirror = pVal - padding * 2;
            nMirror = (pDims[0] - padding) / 2;
            for (i = 0; i < nMirror; i++)
            {
                *(pVal++) = *(pVal_mirror++);
                *(pVal++) = -*pVal_mirror;
                pVal_mirror -= 2;
            }

            int targetLen = pDims[0] * repRatio[0];
            if (targetLen % 2)
                targetLen += 1;
            else
                targetLen += 2;

            int bufferLen = pDims[0] * 2;
            while (targetLen > 0)
            {
                memcpy(dst, pBuffer, bufferLen * sizeof(double));
                dst += bufferLen;
                targetLen -= bufferLen;
            }
        }
    }
    else
    {
        int shift_src = 1, shift_dst = 1;
        for (i = 1; i < N; i++)
        {
            shift_src *= pDims[i];
            shift_dst *= (pDims[i] * repRatio[i]);
        }

        for (i = 0; i < pDims[0]; i++)
        {
            RepeatArray(N - 1, pDims + 1, repRatio + 1, src + shift_src * i, dst + shift_dst * i, padding, pBuffer);
        }

        shift_dst *= pDims[0];

        for (i = 0; i < repRatio[0]; i++)
            memcpy(dst + shift_dst * (i + 1), dst, shift_dst * sizeof(double));
    }
}


//////////////////////////////////////////////////////////////////////////
//	Upsample the current array (in the frequency domain)
//////////////////////////////////////////////////////////////////////////
// 
//	PARAMETERS:
//
//	newArray
//		pointer to the upsampled array
// 
//	upRatio
//		upsampling ratio along each dimension
//
//	WARNING:
//		This routine has not been tested.

void SurfArray::UpsampleF(SurfArray* newArray, int upRatio[])
{
    // The original array must be in the frequency domain
    assert(!IsReal);

    int *pDimsNew;
    double *pBuffer;
    try
    {
        pDimsNew = new int [nDims];
        pBuffer = new double [pDims_logical[nDims - 1] * 2];
    }
    catch (std::bad_alloc)
    {
    	MessageLog("SurfArray", "UpsampleF", "Out of memory!");
        if (pDimsNew) delete [] pDimsNew;
        throw;
    }

    newArray->GetDims(pDimsNew);
    int i, checkDims = 0, padding;
    for (i = 0; i < nDims; i++)
        checkDims += abs(pDims_logical[i] * upRatio[i] - pDimsNew[i]);

    assert(checkDims == 0);

    // newArray must be in the Fourier domain
    newArray->SetIsRealValued(false);

    double *dst;
    dst = newArray->GetPointer(padding);
    // Similar to "repmat" in MATLAB.
    RepeatArray(nDims, pDims_logical, upRatio, pData, dst, padding, pBuffer);
    
    delete [] pBuffer;
    delete [] pDimsNew;
   
}


//////////////////////////////////////////////////////////////////////////
//	Multiply the current array with a 2-D slice along a certian signal plane
//////////////////////////////////////////////////////////////////////////

void SurfArray::Multiply2dComplexSlice(int dim1, int dim2, SurfMatrix* pSlice)
{
	// Not implemented yet.
	// This function is not used in the current Surfacelet implementation
	assert(false);
}


//////////////////////////////////////////////////////////////////////////
//	Export the current array (in the frequency domain) with Hermitian
//	symmetry along a specified dimension
//////////////////////////////////////////////////////////////////////////
//
//	PARAMETERS:
//
//	NewAxis
//		The new axis along which the Hermitian symmetry is utilized

double* SurfArray::NewHermitianSymmetryAxis(int NewAxis)
{
    // we are currently utilizing the symmetry along the last dimension
	// so the NewAxis must be different from that.
    assert((NewAxis <= nDims - 1) && (NewAxis >= 0));
    assert(!IsReal);
	assert(pDims_logical[NewAxis] > 2);
    
    double *pOut;
    int *pNewDims, *pIndices, *pMemoryDistance;
    int n_total_points = 1;
    register int n, m, j, i;

    try
    {
        pNewDims = new int [nDims];
        pIndices = new int [nDims];
        pMemoryDistance = new int [nDims-1];
        for (i = 0; i < nDims; i++)
            pNewDims[i] = pDims_logical[i];
        pNewDims[NewAxis] = pNewDims[NewAxis] / 2 + 1;

        for (i = 0; i < nDims; i++)
            n_total_points *= pNewDims[i];
        // 1 complex = 2 double
		n_total_points *= 2;        

        pOut = new double [n_total_points];
        
    }
    catch (std::bad_alloc)
    {
    	MessageLog("SurfArray", "NewHermitianSymmetryAxis", "Out of memory!");
        throw;
    }

    if (NewAxis == nDims - 1)
    {
        memcpy(pOut, pData, n_total_points * sizeof(double));
        delete [] pMemoryDistance;    
        delete [] pIndices;
        delete [] pNewDims;
        // IMPORTANT
        return pOut;
    }

    int dimA = 1;
    for (n = 0; n < NewAxis; n++)
        dimA *= pDims_logical[n];

    int dimB = pNewDims[NewAxis];

    int dimC = 1;
    for (n = NewAxis + 1; n < nDims - 1; n++)
        dimC *= pDims_logical[n];

    int dimD = pDims_logical[nDims - 1] - (pDims_logical[nDims - 1] / 2 + 1);

	// Initialize the indices
    for (n = 0; n < nDims; n++)
        pIndices[n] = 0;
    
    pMemoryDistance[nDims - 2] = pDims_real[nDims-1];
    for (n = nDims - 3; n >= 0; n--)
        pMemoryDistance[n] = pMemoryDistance[n+1] * pDims_real[n+1];


    double *dst, *src, *src_symm;
    dst = pOut;
    src = pData;

    int skip = pDims_real[nDims - 1];
    int skip_symm, offset;
	int src_skip = pMemoryDistance[NewAxis] * (pDims_logical[NewAxis]-dimB);
	offset = 2 * pDims_logical[nDims - 1] - pDims_real[nDims - 1];

    for (i = 0; i < dimA; i++)
	{
        for (j = 0; j < dimB; j++)
            for (m = 0; m < dimC; m++)
            {
                memcpy(dst, src, skip * sizeof(double));
                dst += skip;
                src += skip;
                
                // update src_symm
                skip_symm = 0;
                for (n = 0; n < nDims - 1; n++)
					if (pIndices[n])
						skip_symm += (pDims_logical[n] - pIndices[n]) * pMemoryDistance[n];
                
				skip_symm += offset;

                src_symm = pData + skip_symm;

                for (n = 0; n < dimD; n++)
                {
                    *(dst++) = *(src_symm++);
                    *(dst++) = -*(src_symm++);
                    src_symm -= 4;
                }

                // update indices
                // Update pIndices
                for (n = nDims - 2; n >= 0; n--)
                {
                    if ( (++pIndices[n]) < pNewDims[n])
                        break;
                    else
                        pIndices[n] = 0;

                }
            }
		src += src_skip;
	}
        
    delete [] pMemoryDistance;    
    delete [] pIndices;
    delete [] pNewDims;

    return pOut;
}


//////////////////////////////////////////////////////////////////////////
//	Import frequency data into the current array
//////////////////////////////////////////////////////////////////////////
//
//	PARAMETERS:
//	
//	pIn
//		The pointer to the outsize memory space
//
//	Previous
//		The axis along which the original data utilize the Hermitian symmetry

void SurfArray::RestoreHermianSymmetryAxis(double *pIn, int PreviousAxis)
{
	// we are currently utilizing the symmetry along the last dimension
	assert((PreviousAxis <= nDims - 1) && (PreviousAxis >= 0));
	assert(!IsReal);

    int *pPrevioisDims, *pIndices, *pMemoryDistance;
	int n_total_points = 1;
	register int n, m, j, i;

    int nTotalPoints = 1;
    if (PreviousAxis == nDims - 1)
    {
        for (n = 0; n < nDims; n++)
            nTotalPoints *= pDims_real[n];

        memcpy(pData, pIn, nTotalPoints * sizeof(double));

        // IMPORTANT
        return;
    }
   
	try
	{
		pPrevioisDims = new int [nDims];
		pIndices = new int [nDims];
		pMemoryDistance = new int [nDims-1];
		for (i = 0; i < nDims; i++)
			pPrevioisDims[i] = pDims_logical[i];
		pPrevioisDims[PreviousAxis] = pPrevioisDims[PreviousAxis] / 2 + 1;
	}
	catch (std::bad_alloc)
	{
		MessageLog("SurfArray", "NewHermitianSymmetryAxis", "Out of memory!");
		throw;
	}

	int dimA = 1;
	for (n = 0; n < PreviousAxis; n++)
		dimA *= pDims_logical[n];

	int dimB = pPrevioisDims[PreviousAxis];
	int dimB2 = pDims_logical[PreviousAxis] - dimB;

	int dimC = 1;
	for (n = PreviousAxis + 1; n < nDims - 1; n++)
		dimC *= pDims_logical[n];

	int dimD = pDims_real[nDims - 1] / 2;

	// Initialize the indices
	for (n = 0; n < nDims; n++)
		pIndices[n] = 0;

	pMemoryDistance[nDims - 2] = pPrevioisDims[nDims-1] * 2;
	for (n = nDims - 3; n >= 0; n--)
		pMemoryDistance[n] = pMemoryDistance[n+1] * pPrevioisDims[n+1];


	double *dst, *src, *src_symm;
	dst = pData;
	src = pIn;

	int skip = pDims_real[nDims - 1];
	int skip_symm, offset;
	offset = 2 * pDims_logical[nDims - 1] - 2;

	for (i = 0; i < dimA; i++)
	{
		for (j = 0; j < dimB; j++)
		{
			for (m = 0; m < dimC; m++)
			{
				memcpy(dst, src, skip*sizeof(double));
				dst += skip;
				src += pMemoryDistance[nDims - 2];
			}
		}

		pIndices[PreviousAxis] = dimB;

		for (j = 0; j < dimB2; j++)
		{
			for (m = 0; m < dimC; m++)
			{
				
				// update src_symm
				skip_symm = 0;
				for (n = 0; n < nDims - 1; n++)
					if (pIndices[n])
						skip_symm += (pDims_logical[n] - pIndices[n]) * pMemoryDistance[n];

				src_symm = pIn + skip_symm;
				*(dst++) = *src_symm;
				*(dst++) = -*(src_symm+ 1);

				src_symm += offset;

				for (n = 1; n < dimD; n++)
				{
					*(dst++) = *(src_symm++);
					*(dst++) = -*(src_symm++);
					src_symm -= 4;
				}

				// Update pIndices
				for (n = nDims - 2; n >= 0; n--)
				{
					if ( (++pIndices[n]) < pDims_logical[n])
						break;
					else
						pIndices[n] = 0;

				}
			}
		}
	}

	delete [] pMemoryDistance;    
	delete [] pIndices;
	delete [] pPrevioisDims;
}


//	This software is provided "as-is", without any express or implied
//	warranty. In no event will the authors be held liable for any 
//	damages arising from the use of this software.

