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
//	NdDirectionalFilterBank.cpp
//	
//	First created: 04-02-06
//	Last modified: 04-11-06
//
//////////////////////////////////////////////////////////////////////////

#include "NdDirectionalFilterBank.h"
#include "math.h"
#include <sstream>
#include <iostream>
#include <fstream>
#include <cassert>
#include "fftw3.h"

using namespace std;

extern void MessageLog(const char*, const char*, const char*);

//////////////////////////////////////////////////////////////////////////
//	Constructor
//////////////////////////////////////////////////////////////////////////

NdDirectionalFilterBank::NdDirectionalFilterBank()
{
	// do nothing
}


//////////////////////////////////////////////////////////////////////////
//	Destructor
//////////////////////////////////////////////////////////////////////////

NdDirectionalFilterBank::~NdDirectionalFilterBank()
{
	// do nothing
}


//////////////////////////////////////////////////////////////////////////
//  NDFB Decomposition
//////////////////////////////////////////////////////////////////////////
//
//  PARAMETERS:
//
//  InArray
//      Input array
//
//  OutArrays
//      List of output subbands
//
//  OutputInFourierDomain
//      Specifying which domain the output subband should be in.
//
//  Levels
//      Decomposition level at each dimension
//
//  filter0, filter1
//      The two decomposition filters
//
//	center0, center1
//		The centers of the decomposition filters
//  
//  mSize
//      Diamond filter size
//
//  beta
//		For Kaiser window
//
//  lambda
//		See paper for more detail

void NdDirectionalFilterBank::GetDecomposition(SurfArray &InArray, SurfArray *OutArrays[], bool OutputInFourierDomain, 
    int Levels[], SurfMatrix &filter0, int center0[], SurfMatrix &filter1, int center1[], int mSize /* = 15 */, double beta /* = 2.5 */, double lambda /* = 4.0 */)
{
    int nDims = InArray.GetRank();
    
    assert(nDims >= 2);

    int *pDims = new int [nDims];
    InArray.GetDims(pDims);

    // Hourglass filter bank decomposition
    SurfArray *subbands = new SurfArray [nDims];
    hourglass_fb.GetDecomposition(InArray, subbands, true, mSize, beta, lambda);

	int i, j, full_dim, nSubs;
    int *pLevel = Levels;
    double *pSubbandData;

	// Note: we scale the filter coefficients (a small 2-D array)
	// by 0.5. By doing this, we avoid having to scale the
	// large N-D array by 0.5 in the downsampling stage.
	double *pf;
	int nCoeffs;
	pf = filter0.GetPointer();
	nCoeffs = filter0.nx * filter0.ny;
	for (i = 0; i < nCoeffs; i++)
	{
		*pf /= 2.0;
		pf++;
	}

	pf = filter1.GetPointer();
	nCoeffs = filter1.nx * filter1.ny;
	for (i = 0; i < nCoeffs; i++)
	{
		*pf /= 2.0;
		pf++;
	}

    for (i = 0; i < nDims; i++)
    {
        // number of output subbands
		nSubs = 1;
		for (j = 0; j < nDims; j++)
			nSubs *= ((j == i)? 1 : (int)pow(2.0, (double)pLevel[j]));

		OutArrays[i] = new SurfArray [nSubs];

		if (nSubs > 1)		
		{
			// pSubbandData will point to the newly-allocated memory space
			pSubbandData = subbands[i].NewHermitianSymmetryAxis(i);
	        
			// One of the dimensions is nearly reduced by half
			full_dim = pDims[i];
			pDims[i] = full_dim / 2 + 1;

			// release memory space
			subbands[i].Reset();

			// Iteratively resampled checkerboard filter bank decomposition
			IrcDecomposition(nDims, pDims, pSubbandData, i, full_dim, pLevel, filter0, center0, filter1, center1);

			// extract all the subbands
			BoxToCell(nDims, pDims, pSubbandData, OutArrays[i], pLevel, i, full_dim);

			delete [] pSubbandData;

			// restore the full dimension
			pDims[i] = full_dim;
		}
		else
		{
			assert(nSubs == 1);
			*OutArrays[i] = subbands[i];
		}

		pLevel += nDims;

        if (!OutputInFourierDomain)
        {
            for (j = 0; j < nSubs; j++)
                OutArrays[i][j].GetInPlaceBackwardFFT();
        }

    }
    
	// restore the filter coefficients
	pf = filter0.GetPointer();
	nCoeffs = filter0.nx * filter0.ny;
	for (i = 0; i < nCoeffs; i++)
	{
		*pf *= 2.0;
		pf++;
	}

	pf = filter1.GetPointer();
	nCoeffs = filter1.nx * filter1.ny;
	for (i = 0; i < nCoeffs; i++)
	{
		*pf *= 2.0;
		pf++;
	}


    FilterSlice0.Reset();
    FilterSlice1.Reset();
    delete [] pDims;
    delete [] subbands;

}


//////////////////////////////////////////////////////////////////////////
//  NDFB Reconstruction
//////////////////////////////////////////////////////////////////////////
//
//  PARAMETERS:
//
//  InArrays
//      List of input arrays
//
//  OutArray
//      The output array
//
//  OutputInFourierDomain
//      Specifying which domain the output subband should be in.
//
//  Levels
//      Decomposition level at each dimension
//
//  filter0, filter1
//      The two reconstruction filters
//
//	center0, center1
//		The centers of the reconstruction filters
//  
//  mSize
//      Diamond filter size
//
//  beta
//		For Kaiser window
//
//  lambda
//		See paper for more details

void NdDirectionalFilterBank::GetReconstruction(SurfArray *InArrays[], SurfArray &OutArray, bool OutputInFourierDomain, 
	int Levels[], SurfMatrix &filter0, int center0[], SurfMatrix &filter1, int center1[], int mSize /* = 15 */, double beta /* = 2::5 */, double lambda /* = 4::0 */)
{
	int nDims = InArrays[0][0].GetRank();

	assert(nDims >= 2);

	SurfArray *subbands = new SurfArray [nDims];
    int *pDims = new int [nDims];
	InArrays[0][0].GetDims(pDims);
        
    int i, j, full_dim, nSubs;
	int *pLevel = Levels;
    double *pSubbandData;

	for (i = 0; i < nDims; i++)
	{
		pDims[i] *= ((i == 0)? 1 : ((int)pow(2.0, (double)pLevel[i])));
	}

	for (i = 0; i < nDims; i++)
	{
		nSubs = 1;
		for (j = 0; j < nDims; j++)
			nSubs *= ((j == i)? 1 : ((int)pow(2.0, (double)pLevel[j])));

        for (j = 0; j < nSubs; j++)
        {
            if (InArrays[i][j].IsRealValued())
                InArrays[i][j].GetInPlaceForwardFFT();
        }

		if (nSubs > 1)
		{
			pSubbandData = CellToBox(InArrays[i], i, pLevel);
	        
			full_dim = pDims[i];
			pDims[i] = full_dim / 2 + 1;

			IrcReconstruction(nDims, pDims, pSubbandData, i, full_dim, pLevel, filter0, center0, filter1, center1);

			// restore the dimension
			pDims[i] = full_dim;

			subbands[i].AllocateSpace(nDims, pDims);
			subbands[i].SetIsRealValued(false);
			subbands[i].RestoreHermianSymmetryAxis(pSubbandData, i);

			delete [] pSubbandData;
		}
		else
		{
			assert(nSubs == 1);
			subbands[i] = *(InArrays[i]);
		}

        pLevel += nDims;
	
	}

    FilterSlice0.Reset();
    FilterSlice1.Reset();
	
	// Hourglass filter bank reconstruction
	hourglass_fb.GetReconstruction(subbands, OutArray, OutputInFourierDomain, mSize, beta, lambda);	

	// release the temporary memory
    delete [] pDims;
	delete [] subbands;
    
}


//////////////////////////////////////////////////////////////////////////
//	Read the checkerboard filter bank coefficients from files
//////////////////////////////////////////////////////////////////////////
//
//	PARAMETERS:
//
//	bo:
//		Order of the checkerboard filters
//
//	IsDecomposition:
//		Decomposition filters or reconstruction filters
//
//	filter0:
//		The imported first filter, stored in a SurfMatrix object
//
//	center0:
//		The center of the first filter
//
//	filter1:
//		The imported second filter, stored in a SurfMatrix object
//
//	center1:
//		The center of the second filter
//
//	dir_info:
//		A string containing the directory of the filter files
//
//	NOTE:
//
//	Each coefficient file are named as "cbd_coeffs_bo_XX.surf", where
//	XX is the bo number. Within each file, the coefficient info is stored as
//
//	dim[0] dim[1] center0[0] center0[1] coeffs | dim[0] dim[1] center1[0] center1[1] coeffs | dim[0] dim[1] center0[0] center0[1] coeffs | dim[0] dim[1] center1[0] center1[1] coeffs
//	**        Decompsition filter 0         **   **       Reconstruction filter 0        **   **       Decompsition filter 0          **   **       Reconstruction filter 0        **


void NdDirectionalFilterBank::GetCheckerboardFilters(int bo, bool IsDecomposition, 
	SurfMatrix &filter0, int center0[], SurfMatrix& filter1, int center1[], string& dir_info)
{
	// bo is an even number and between 4 and 18
	assert((bo >= 4) && (bo <= 18) && (bo % 2 == 0));

	// Get the file name for the filter coefficients
	stringstream convert;
	convert << bo;
	string filter_filename = dir_info + "cbd_coeffs_bo_" + convert.str() + ".surf";

	int dims[2], center[2];

	try
	{
		ifstream coeff_file;
		coeff_file.open(filter_filename.c_str(), ios::in | ios::binary);
		
		if (!coeff_file.is_open())
			throw 1;
			
		
		if (!IsDecomposition)
		{
			coeff_file.read((char *)dims, 2 * sizeof(int));
			coeff_file.read((char *)center, 2 * sizeof(int));
			coeff_file.seekg(dims[0] * dims[1] * sizeof(double), ios_base::cur);
			
			coeff_file.read((char *)dims, 2 * sizeof(int));
			coeff_file.read((char *)center, 2 * sizeof(int));
			coeff_file.seekg(dims[0] * dims[1] * sizeof(double), ios_base::cur);
		}

		coeff_file.read((char *)dims, 2 * sizeof(int));
		coeff_file.read((char *)center0, 2 * sizeof(int));
		filter0.AllocateSpace(dims[0], dims[1]);
		coeff_file.read((char *)filter0.GetPointer(), dims[0] * dims[1] * sizeof(double));

		coeff_file.read((char *)dims, 2 * sizeof(int));
		coeff_file.read((char *)center1, 2 * sizeof(int));
		filter1.AllocateSpace(dims[0], dims[1]);
		coeff_file.read((char *)filter1.GetPointer(), dims[0] * dims[1] * sizeof(double));

		coeff_file.close();

        //// modify the center values to be zero-based
        //center0[0] -= 1;
        //center0[1] -= 1;
        //center1[0] -= 1;
        //center1[1] -= 1;
	}
	catch (std::bad_alloc)
	{
		MessageLog("NdDirectionalFilterBank", "GetCheckerboardFilters", "Out of memory!");
		throw;
	}
	catch (...)
	{
		MessageLog("NdDirectionalFilterBank", "GetCheckerboardFilters", "Filter coefficients file is corrupted!");
		throw 1;
	}
}


//////////////////////////////////////////////////////////////////////////
//	Iteratively resampled checkerboard filter bank decomposition
//////////////////////////////////////////////////////////////////////////
//
//	PARAMETERS:
//
//	nDims:
//		Number of dimensions
//
//	pDims:
//		An array specifying the dimension of the input (complex-valued) array
//
//	pData:
//		Pointer to the input array
//
//	dim_axis:
//		The dimension along which we utilize the Hermitian symmetry
//
//	levels:
//		Levels of 2-D decomposition along each pair of dimensions
//
//	filter0, filter1:
//		The two decomposition filters
//
//	center0, center1:
//		The centers of the decomposition filters

void NdDirectionalFilterBank::IrcDecomposition(int nDims, int pDims[], double *pData, 
	int dim_axis, int full_dim, int levels[], SurfMatrix &filter0, int center0[], SurfMatrix &filter1, int center1[])
{	
	assert(levels[dim_axis] == -1);

    int m, iLevel, nSubbands = 1;

	try
	{
		for (m = nDims - 1; m >= 0; m--)
		{
			if (m == dim_axis) continue;

			for (iLevel = 1; iLevel <= levels[m]; iLevel++)
			{
				// Get the 2-D filter slices
				GetIrcFilterSlices(full_dim, pDims[m], iLevel, filter0, center0, FilterSlice0);
				GetIrcFilterSlices(full_dim, pDims[m], iLevel, filter1, center1, FilterSlice1);
				
				FilterDownsampleF(nDims, pDims, pData, dim_axis, m, iLevel);
			}
		}
	}
	catch(...)
	{
		// Filter coefficient file not found.
		throw 1;
	}
}


//////////////////////////////////////////////////////////////////////////
//	Iteratively resampled checkerboard filter bank reconstruction
//////////////////////////////////////////////////////////////////////////
//
//	PARAMETERS:
//
//	nDims:
//		Number of dimensions
//
//	pDims:
//		An array specifying the dimension of the input (complex-valued) array
//
//	pData:
//		Pointer to the input array
//
//	dim_axis:
//		The dimension along which we utilize the Hermitian symmetry
//
//	levels:
//		Levels of 2-D reconstruction along each pair of dimensions
//
//	filter0, filter1:
//		The two reconstruction filters
//
//	center0, center1:
//		The centers of the reconstruction filters

void NdDirectionalFilterBank::IrcReconstruction(int nDims, int pDims[], double *pData, 
	int dim_axis, int full_dim, int levels[], SurfMatrix &filter0, int center0[], SurfMatrix &filter1, int center1[])
{

	assert(levels[dim_axis] == -1);

	int m, iLevel, nSubbands = 1;

	for (m = 0; m < nDims; m++)
	{
		if (m == dim_axis) continue;

		for (iLevel = levels[m]; iLevel >= 1; iLevel--)
		{
			// Get the 2-D filter slices
			GetIrcFilterSlices(full_dim, pDims[m], iLevel, filter0, center0, FilterSlice0);
			GetIrcFilterSlices(full_dim, pDims[m], iLevel, filter1, center1, FilterSlice1);

			FilterUpsampleF(nDims, pDims, pData, dim_axis, m, iLevel);

		}
	}
}


//////////////////////////////////////////////////////////////////////////
//	Obtain the 2-D slice containing the frequency values of the irc filters
//////////////////////////////////////////////////////////////////////////
//	
//	PARAMETERS:
//	
//	dim_K
//		The major dimension
//	
//	dim_M
//		The minor dimension
//
//	nLevel
//		The pyramid decomposition level
//
//	filter
//		A 2-D matrix containing the filter coefficients
//
//	center
//		The center location of the 2-D filter
//
//	FilterSlice
//		The resulting 2-D slice
//
//	Note:
//	
//	FilterSlice will be a matrix of dimensions dim_M * (2 * dim_K);

void NdDirectionalFilterBank::GetIrcFilterSlices(int dim_K, int dim_M, int nLevel, SurfMatrix &filter, 
	int center[], SurfMatrix &FilterSlice)
{
	
	int nChannels = (int)pow(2.0,  (double)(nLevel - 1));
	
	assert((nLevel >= 1) && (dim_M % nChannels == 0));

	int nBlock = dim_M / nChannels;
	
	try
	{
		// complex-valued array of dimensions dim_M * dim_K
		if (FilterSlice.nx * FilterSlice.ny == dim_M * 2 * dim_K)
        {
            FilterSlice.nx = dim_M;
            FilterSlice.ny = 2 * dim_K;
        }
        else
            FilterSlice.AllocateSpace(dim_M, 2 * dim_K);

		FilterSlice.ZeroFill();

		int new_center[2];
		int shifting_factor;
		int ChannelIndex;
		

		SurfMatrix SmallFilterSlice;
		SmallFilterSlice.AllocateSpace(dim_M / nChannels, 2 * dim_K);
		fftw_plan planFFT;

		for (ChannelIndex = 0; ChannelIndex < nChannels; ChannelIndex++)
		{
			shifting_factor = nChannels - 1 - 2 * ChannelIndex;

			new_center[0] = center[0];
			if (shifting_factor >= 0)
				new_center[1] = center[1] + shifting_factor * center[0];
			else
				new_center[1] = dim_K - filter.ny + center[1] + shifting_factor * center[0];

			SmallFilterSlice.FillSubMatrixF(filter, shifting_factor >= 0);

            // make sure the resampled (sheared) filter can still fit in
            assert(filter.ny + (filter.nx - 1) * shifting_factor <= dim_K);

			// Note: the matrix is complex valued, so we need to double the shifting factor
			SmallFilterSlice.ResampleRow(2 * shifting_factor);

			SmallFilterSlice.CircularShift(- new_center[0], -2 * new_center[1]);

			// Take the FFT of the filter slice
			// IMPORTANT: subject to change in scaling factors
			
			planFFT = fftw_plan_dft_2d(SmallFilterSlice.nx, SmallFilterSlice.ny / 2, (fftw_complex*)SmallFilterSlice.GetPointer(),
				(fftw_complex*)SmallFilterSlice.GetPointer(), FFTW_FORWARD, FFTW_ESTIMATE);

			fftw_execute(planFFT);

			fftw_destroy_plan(planFFT);

    		FilterSlice.FillSubMatrix(SmallFilterSlice, ChannelIndex * nBlock, 0);
		}
	}
	catch (std::bad_alloc)
	{
		MessageLog("NdDirectionalFilterBank", "GetIrcFilterSlices", "Out of memory!");
		throw;
	}
}


//////////////////////////////////////////////////////////////////////////
//  Extract an N-D array into a list of sub-arrays
//////////////////////////////////////////////////////////////////////////
//
//  PARAMETERS:
//
//  nDims:
//      Rank of the input array
//
//  pDims:
//      Dimension of the input array
//
//  pInData:
//      Input array
//
//  pSubbands:
//      Output arrays
//
//  levels
//      Specifying how each dimension is divided.
//
//  dim_axis
//      The axis on which the input array utilizes the Hermitian symmetry
//
//	full_dim
//		The original dimension along dim_axis

void NdDirectionalFilterBank::BoxToCell(int nDims, int pDims[], double *pInData, SurfArray pSubbands[], int levels[], int dim_axis, int full_dim)
{
    // We only work on multidimensional arrays
    assert((nDims >= 2) && (dim_axis >= 0) && (dim_axis < nDims) && (levels[dim_axis] == -1));
    
    register int n, m, j, i;
    
    // level = x ==> 2 ^ x subarrays
    levels[dim_axis] = 0;
    for (n = 0; n < nDims; n++)
    {
        levels[n] = (int)pow(2.0,  (double)levels[n]);
        // 2 ^ level must divide the corresponding dimension
        if ((pDims[n] % levels[n]) != 0)
            assert(false);
    }

    // Total number of output subbands
    int nSubbands = 1;
    for (n = 0; n < nDims; n++)
    {
        nSubbands *= levels[n];
    }

    double **pOutData, **pOutDataFixed;
    int *pSkip, *pNewDims, *pIndices;
    try
    {
        // pointers to each output subband array
        pOutData = new double * [nSubbands];
        pOutDataFixed = new double * [nSubbands];
        pSkip = new int [nDims];

        // dimension of the smaller output arrays
        pNewDims = new int [nDims];
        for (n = 0; n < nDims; n++)
        {
            pNewDims[n] = pDims[n] / levels[n];
        }   

        pIndices = new int [nDims];

        int nSubbandPoints = 2;
        for (n = 0; n < nDims; n++)
            nSubbandPoints *= pNewDims[n];

        // Allocate subband arrays
        for (n = 0; n < nSubbands; n++)
        {
            pOutData[n] = pOutDataFixed[n] = new double [nSubbandPoints];
        }
    }
    catch (std::bad_alloc)
    {
    	MessageLog("NdDirectionalFilterBank", "BoxToCell", "Out of memory!");
        throw;
    }

    // calculate skip distance    
    pSkip[nDims - 1] = 1;
    for (n = nDims - 2; n >= 0; n--)
        pSkip[n] = pSkip[n + 1] * levels[n + 1];

    // number of 2-D slices
    int nSlices = 1;
    for (n = 0; n <= nDims - 3; n++)
        nSlices *= pDims[n];

    int nDimLast = levels[nDims - 1];
    int nDimSecondLast0 = levels[nDims - 2];
    int nDimSecondLast1 = pNewDims[nDims - 2];
    
    // Initialize pIndices;
    memset(pIndices, 0, nDims * sizeof(int));
    double **ptrStartPosition;
    int nCopy = 2 * pNewDims[nDims - 1];

	double *pInFixed = pInData;
    
    for (i = 0; i < nSlices; i++)
    {
        ptrStartPosition = pOutData;
        for (j = 0; j <= nDims - 3; j++)
            ptrStartPosition += (pIndices[j] / pNewDims[j]) * pSkip[j];
        
        for (j = 0; j < nDimSecondLast0; j++)
        {
            for (m = 0; m < nDimSecondLast1; m++)
            {
                for (n = 0; n < nDimLast; n++)
                {
                    memcpy(ptrStartPosition[n], pInData, nCopy * sizeof(double));
                    ptrStartPosition[n] += nCopy;
                    pInData += nCopy;
                }
            }
            ptrStartPosition += pSkip[nDims - 2];
        }

        // Update pIndices
        for (j = nDims - 3; j >= 0; j--)
        {
            if ( (++pIndices[j]) < pDims[j])
                break;
            else
                pIndices[j] = 0;
        }
    }

	pNewDims[dim_axis] = full_dim;

    // Create SurfArray-typed subbands
    for (n = 0; n < nSubbands; n++)
    {
        pSubbands[n].AllocateSpace(nDims, pNewDims);
		pSubbands[n].SetIsRealValued(false);
        pSubbands[n].RestoreHermianSymmetryAxis(pOutDataFixed[n], dim_axis);
        // clear some memory
        delete [] pOutDataFixed[n];
    }

    // restore levels
    for (n = 0; n < nDims; n++)
        levels[n] = (int)(log((double)levels[n]) / log(2.0));
    levels[dim_axis] = -1;
    
    // release temporary memory space
    delete [] pIndices;
    delete [] pNewDims;
    delete [] pOutData;
    delete [] pOutDataFixed;
    delete [] pSkip;
}


//////////////////////////////////////////////////////////////////////////
//  Combine a list of small arrays into a larger one
//////////////////////////////////////////////////////////////////////////
//
//  PARAMETERS:
//
//  pSubbands
//      A list of smaller array of the same dimensions
//
//  dim_axis
//      The new dimension along which the big array will utilize the Hermitian symmetry
//
//  levels
//      Specifying how each dimension is divided
//
//  RETUEN
//      A pointer to the allocated memory space for the big array

double *NdDirectionalFilterBank::CellToBox(SurfArray pSubbands[], int dim_axis, int levels[])
{
    int nDims = pSubbands[0].GetRank();
    assert((nDims >= 2) && (dim_axis >= 0) && (dim_axis < nDims) && (levels[dim_axis] == -1));

    register int n, m, j, i;

    // level = x ==> 2 ^ x sub-arrays
    levels[dim_axis] = 0;
    for (n = 0; n < nDims; n++)
    {
        levels[n] = (int)pow(2.0,  (double)levels[n]);
    }

    // Total number of output subbands
    int nSubbands = 1;
    for (n = 0; n < nDims; n++)
    {
        nSubbands *= levels[n];
    }

    double **pSubbandData, **pSubbandDataFixed, *pDataBox, *pData;
    int *pSkip, *pDims, *pLargeDims, *pIndices;
    try
    {
        // pointers to each output subband array
        pSubbandData = new double * [nSubbands];
        pSubbandDataFixed = new double * [nSubbands];
        pSkip = new int [nDims];
        pDims = new int [nDims];
        pLargeDims = new int [nDims];

        // dimension of the smaller output arrays
        pSubbands[0].GetDims(pDims);
        pDims[dim_axis] = pDims[dim_axis] / 2 + 1;

        int nTotalPoints = 2;
        for (n = 0; n < nDims; n++)
        {
            pLargeDims[n] = pDims[n] * levels[n];
            nTotalPoints *= pLargeDims[n];
        }

        pIndices = new int [nDims];

        // Allocate subband arrays
        for (n = 0; n < nSubbands; n++)
        {
            // NOTE: memory space allocated here
            pSubbandData[n] = pSubbandDataFixed[n] = pSubbands[n].NewHermitianSymmetryAxis(dim_axis);
        }

        pData = pDataBox = new double [nTotalPoints];
    }
    catch (std::bad_alloc)
    {
        MessageLog("NdDirectionalFilterBank", "BoxToCell", "Out of memory!");
        throw;
    }

    // calculate skip distance    
    pSkip[nDims - 1] = 1;
    for (n = nDims - 2; n >= 0; n--)
        pSkip[n] = pSkip[n + 1] * levels[n + 1];

    // number of 2-D slices
    int nSlices = 1;
    for (n = 0; n <= nDims - 3; n++)
        nSlices *= pLargeDims[n];

    int nDimLast = levels[nDims - 1];
    int nDimSecondLast0 = levels[nDims - 2];
    int nDimSecondLast1 = pDims[nDims - 2];

    // Initialize pIndices;
    memset(pIndices, 0, nDims * sizeof(int));
    double **ptrStartPosition;
    int nCopy = 2 * pDims[nDims - 1];

    for (i = 0; i < nSlices; i++)
    {
        ptrStartPosition = pSubbandData;
        for (j = 0; j <= nDims - 3; j++)
            ptrStartPosition += (pIndices[j] / pDims[j]) * pSkip[j];

        for (j = 0; j < nDimSecondLast0; j++)
        {
            for (m = 0; m < nDimSecondLast1; m++)
            {
                for (n = 0; n < nDimLast; n++)
                {
                    memcpy(pData, ptrStartPosition[n], nCopy * sizeof(double));
                    ptrStartPosition[n] += nCopy;
                    pData += nCopy;
                }
            }
            ptrStartPosition += pSkip[nDims - 2];
        }

        // Update pIndices
        for (j = nDims - 3; j >= 0; j--)
        {
            if ( (++pIndices[j]) < pLargeDims[j])
                break;
            else
                pIndices[j] = 0;
        }
    }

    // restore levels
    for (n = 0; n < nDims; n++)
        levels[n] = (int)(log((double)levels[n]) / log(2.0));
    levels[dim_axis] = -1;

    // release temporary memory space
    for (n = 0; n < nSubbands; n++)
        delete [] pSubbandDataFixed[n];

    delete [] pIndices;
    delete [] pLargeDims;
    delete [] pDims;
    delete [] pSubbandData;
    delete [] pSubbandDataFixed;
    delete [] pSkip;

    return pDataBox;
}


//////////////////////////////////////////////////////////////////////////
//	Filtering followed by downsampling
//////////////////////////////////////////////////////////////////////////
//
//	PARAMETERS:
//
//	nDims
//		Number of dimensions of the input data
//
//	pDims
//		Dimensions of the input data
//
//	pData
//		pointer to the input data
//
//	K
//		The major dimension
//
//	M
//		The minor dimension
//
//	Level
//		The level of multiscale pyramid

void NdDirectionalFilterBank::FilterDownsampleF(int nDims, int pDims[], double *pData, int K, int M, int Level)
{
    // Some validity checks
    assert((nDims >= 2) && (Level >= 1) && (K >= 0) && (K < nDims) && (M >= 0) && (M < nDims) && (K != M));
    assert((FilterSlice0.nx == pDims[M]) && (FilterSlice0.ny / 4 + 1 == pDims[K]));

    int nChannels = (int)pow(2.0, (double)Level);
    int nRepeat = nChannels / 2;
    
    // We will divide this dimension into nChannel pieces
    assert(pDims[M] %  nChannels == 0);

    // Record the downsampling dimension
    int downsample_dim = M;

    // We always make M < K
    if (M > K)
    {
        // Note: we are transposing a complex-valued matrix
        FilterSlice0.Transpose(false);
        FilterSlice1.Transpose(false);

        // Swap the two dimensions
        int tmp;
        tmp = K;
        K = M;
        M = tmp;
    }

    int dimA, dimB, dimC, dimD, dimE;
    register int s, m, n, k, j, i;

    dimA = 1;
    for (m = 0; m < M; m++)
        dimA *= pDims[m];

    dimB = pDims[M];

    dimC = 1;
    for (m = M + 1; m < K; m++)
        dimC *= pDims[m];

    dimD = pDims[K];

    dimE = 1;
    for (m = K + 1; m < nDims; m++)
        dimE *= pDims[m];

    double *pFilter0_base, *pFilter1_base, *pFilter0_up, *pFilter0_down, *pFilter1_up, *pFilter1_down;
    pFilter0_base = FilterSlice0.GetPointer();
    pFilter1_base = FilterSlice1.GetPointer();

    double f0_up_real, f0_up_imag, f0_down_real, f0_down_imag;
    double f1_up_real, f1_up_imag, f1_down_real, f1_down_imag;
    
    double *pArray_up, *pArray_down;
    double a_up_real, a_up_imag, a_down_real, a_down_imag; 

    int filter_block_skip, filter_line_skip, filter_line_retreat;
    int array_block_skip;

    // There are two cases:
    // (1) downsample_dim == M
    // (2) downsample_dim == K
    if (downsample_dim == M)
    {
        // preparation
        dimB /= nChannels;
        filter_block_skip = dimB * FilterSlice0.ny;
        filter_line_retreat = 2 * dimD;
        filter_line_skip = FilterSlice0.ny;
        

        array_block_skip = dimB * 2;
        for (i = M + 1; i < nDims; i++)
            array_block_skip *= pDims[i];

        pArray_up = pData;
        pArray_down = pArray_up + array_block_skip;

        for (i = 0; i < dimA; i++)
        {
            pFilter0_up = pFilter0_base;
            pFilter0_down = pFilter0_up + filter_block_skip;
            pFilter1_up = pFilter1_base;
            pFilter1_down = pFilter1_up + filter_block_skip;

            for (j = 0; j < nRepeat; j++)
            {
                for (k = 0; k < dimB; k++)
                {
                    for (m = 0; m < dimC; m++)
                    {
                        for (n = 0; n < dimD; n++)
                        {
                            f0_up_real = *(pFilter0_up++);      f0_up_imag = *(pFilter0_up++);
                            f0_down_real = *(pFilter0_down++);  f0_down_imag = *(pFilter0_down++);
                            f1_up_real = *(pFilter1_up++);      f1_up_imag = *(pFilter1_up++);
                            f1_down_real = *(pFilter1_down++);  f1_down_imag = *(pFilter1_down++);

                            for (s = 0; s < dimE; s++)
                            {
                                a_up_real = *(pArray_up++);
                                a_up_imag = *(pArray_up++);
                                a_down_real = *(pArray_down++);
                                a_down_imag = *(pArray_down++);

                                *(pArray_up - 2) = a_up_real * f0_up_real - a_up_imag * f0_up_imag
                                    + a_down_real * f0_down_real - a_down_imag * f0_down_imag;
                                *(pArray_up - 1) = a_up_real * f0_up_imag + a_up_imag * f0_up_real
                                    + a_down_real * f0_down_imag + a_down_imag * f0_down_real;

                                *(pArray_down - 2) = a_up_real * f1_up_real - a_up_imag * f1_up_imag
                                    + a_down_real * f1_down_real - a_down_imag * f1_down_imag;
                                *(pArray_down - 1) = a_up_real * f1_up_imag + a_up_imag * f1_up_real
                                    + a_down_real * f1_down_imag + a_down_imag * f1_down_real;
                            } // s = 0 : dime
                        } // n = 0 : dimD

                        pFilter0_up -= filter_line_retreat;
                        pFilter0_down -= filter_line_retreat;
                        pFilter1_up -= filter_line_retreat;
                        pFilter1_down -= filter_line_retreat;
                    }   // m = 0 : dimC

                    pFilter0_up += filter_line_skip;
                    pFilter0_down += filter_line_skip;
                    pFilter1_up += filter_line_skip;
                    pFilter1_down += filter_line_skip;
                }   // k = 0 : dimB

                pFilter0_up = pFilter0_down;
                pFilter0_down = pFilter0_up + filter_block_skip;
                pFilter1_up = pFilter1_down;
                pFilter1_down = pFilter1_up + filter_block_skip;

                pArray_up = pArray_down;
                pArray_down = pArray_up + array_block_skip;
            }   // j = 0 : nRepeat
        }   // i = 0 : dimA
    }   // if downsample_dim == M
    else
    {
        // preparation
        filter_block_skip = FilterSlice0.ny / nChannels;
        filter_line_skip = FilterSlice0.ny;
        dimD /= nChannels;

        array_block_skip = dimD * 2;
        for (i = K + 1; i < nDims; i++)
            array_block_skip *= pDims[i];

        pArray_up = pData;
        pArray_down = pArray_up + array_block_skip;

		        
        for (i = 0; i < dimA; i++)
        {
            pFilter0_up = pFilter0_base;
            pFilter0_down = pFilter0_up + filter_block_skip;
            pFilter1_up = pFilter1_base;
            pFilter1_down = pFilter1_up + filter_block_skip;

            for (j = 0; j < dimB; j++)
            {
                for (k = 0; k < dimC; k++)
                {
                    for (m = 0; m < nRepeat; m++)
                    {
                        for (n = 0; n < dimD; n++)
                        {
                            f0_up_real = *(pFilter0_up++);      f0_up_imag = *(pFilter0_up++);
                            f0_down_real = *(pFilter0_down++);  f0_down_imag = *(pFilter0_down++);
                            f1_up_real = *(pFilter1_up++);      f1_up_imag = *(pFilter1_up++);
                            f1_down_real = *(pFilter1_down++);  f1_down_imag = *(pFilter1_down++);

                            for (s = 0; s < dimE; s++)
                            {
                                a_up_real = *(pArray_up++);
                                a_up_imag = *(pArray_up++);
                                a_down_real = *(pArray_down++);
                                a_down_imag = *(pArray_down++);

                                *(pArray_up - 2) = a_up_real * f0_up_real - a_up_imag * f0_up_imag
                                    + a_down_real * f0_down_real - a_down_imag * f0_down_imag;
                                *(pArray_up - 1) = a_up_real * f0_up_imag + a_up_imag * f0_up_real
                                    + a_down_real * f0_down_imag + a_down_imag * f0_down_real;

                                *(pArray_down - 2) = a_up_real * f1_up_real - a_up_imag * f1_up_imag
                                    + a_down_real * f1_down_real - a_down_imag * f1_down_imag;
                                *(pArray_down - 1) = a_up_real * f1_up_imag + a_up_imag * f1_up_real
                                    + a_down_real * f1_down_imag + a_down_imag * f1_down_real;
                            } // s = 0 : dimE
                        }   // n = 0 : dimD
                        
						pFilter0_up = pFilter0_down;
						pFilter0_down = pFilter0_up + filter_block_skip;
						pFilter1_up = pFilter1_down;
						pFilter1_down = pFilter1_up + filter_block_skip;

                        pArray_up = pArray_down;
                        pArray_down = pArray_up + array_block_skip;
                    }   // m = 0 : nRepeat


                    pFilter0_up -= filter_line_skip;
                    pFilter0_down -= filter_line_skip;
                    pFilter1_up -= filter_line_skip;
                    pFilter1_down -= filter_line_skip;

                }   // k = 0 : dimC
				
				pFilter0_up += filter_line_skip;
				pFilter0_down = pFilter0_up + filter_block_skip;
				pFilter1_up += filter_line_skip;
				pFilter1_down = pFilter1_up + filter_block_skip;

            } // j = 0 : dimB

        }   // i = 0 : dimA
    }
}


//////////////////////////////////////////////////////////////////////////
//	Filtering followed by upsampling
//////////////////////////////////////////////////////////////////////////
//
//	PARAMETERS:
//
//	nDims
//		Number of dimensions of the input data
//
//	pDims
//		Dimensions of the input data
//
//	pData
//		pointer to the input data
//
//	K
//		The major dimension
//
//	M
//		The minor dimension
//
//	Level
//		The level of multiscale pyramid

void NdDirectionalFilterBank::FilterUpsampleF(int nDims, int pDims[], double *pData, int K, int M, int Level)
{
    // Some validity checks
    assert((nDims >= 2) && (Level >= 1) && (K >= 0) && (K < nDims) && (M >= 0) && (M < nDims) && (K != M));
    assert((FilterSlice0.nx == pDims[M]) && (FilterSlice0.ny / 4 + 1 == pDims[K]));

    int nChannels = (int)pow(2.0, (double)Level);
    int nRepeat = nChannels / 2;

    // We will divide this dimension into nChannel pieces
    assert(pDims[M] %  nChannels == 0);

    // Record the upsampling dimension
    int upsample_dim = M;

    // We always make M < K
    if (M > K)
    {
        // Note: we are transposing a complex-valued matrix
        FilterSlice0.Transpose(false);
        FilterSlice1.Transpose(false);

        // Swap the two dimensions
        int tmp;
        tmp = K;
        K = M;
        M = tmp;
    }

    int dimA, dimB, dimC, dimD, dimE;
    register int s, m, n, k, j, i;

    dimA = 1;
    for (m = 0; m < M; m++)
        dimA *= pDims[m];

    dimB = pDims[M];

    dimC = 1;
    for (m = M + 1; m < K; m++)
        dimC *= pDims[m];

    dimD = pDims[K];

    dimE = 1;
    for (m = K + 1; m < nDims; m++)
        dimE *= pDims[m];

    double *pFilter0_base, *pFilter1_base, *pFilter0_up, *pFilter0_down, *pFilter1_up, *pFilter1_down;
    pFilter0_base = FilterSlice0.GetPointer();
    pFilter1_base = FilterSlice1.GetPointer();

    double f0_up_real, f0_up_imag, f0_down_real, f0_down_imag;
    double f1_up_real, f1_up_imag, f1_down_real, f1_down_imag;

    double *pArray_up, *pArray_down;
    double a_up_real, a_up_imag, a_down_real, a_down_imag; 

    int filter_block_skip, filter_line_skip, filter_line_retreat;
    int array_block_skip;

    // There are two cases:
    // (1) downsample_dim == M
    // (2) downsample_dim == K
    if (upsample_dim == M)
    {
        // preparation
        dimB /= nChannels;
        filter_block_skip = dimB * FilterSlice0.ny;
        filter_line_retreat = 2 * dimD;
        filter_line_skip = FilterSlice0.ny;


        array_block_skip = dimB * 2;
        for (i = M + 1; i < nDims; i++)
            array_block_skip *= pDims[i];

        pArray_up = pData;
        pArray_down = pArray_up + array_block_skip;

        for (i = 0; i < dimA; i++)
        {
            pFilter0_up = pFilter0_base;
            pFilter0_down = pFilter0_up + filter_block_skip;
            pFilter1_up = pFilter1_base;
            pFilter1_down = pFilter1_up + filter_block_skip;

            for (j = 0; j < nRepeat; j++)
            {
                for (k = 0; k < dimB; k++)
                {
                    for (m = 0; m < dimC; m++)
                    {
                        for (n = 0; n < dimD; n++)
                        {
                            f0_up_real = *(pFilter0_up++);      f0_up_imag = *(pFilter0_up++);
                            f0_down_real = *(pFilter0_down++);  f0_down_imag = *(pFilter0_down++);
                            f1_up_real = *(pFilter1_up++);      f1_up_imag = *(pFilter1_up++);
                            f1_down_real = *(pFilter1_down++);  f1_down_imag = *(pFilter1_down++);

                            for (s = 0; s < dimE; s++)
                            {
                                a_up_real = *(pArray_up++);
                                a_up_imag = *(pArray_up++);
                                a_down_real = *(pArray_down++);
                                a_down_imag = *(pArray_down++);

                                *(pArray_up - 2) = a_up_real * f0_up_real - a_up_imag * f0_up_imag
                                    + a_down_real * f1_up_real - a_down_imag * f1_up_imag;
                                *(pArray_up - 1) = a_up_real * f0_up_imag + a_up_imag * f0_up_real
                                    + a_down_real * f1_up_imag + a_down_imag * f1_up_real;

                                *(pArray_down - 2) = a_up_real * f0_down_real - a_up_imag * f0_down_imag
                                    + a_down_real * f1_down_real - a_down_imag * f1_down_imag;
                                *(pArray_down - 1) = a_up_real * f0_down_imag + a_up_imag * f0_down_real
                                    + a_down_real * f1_down_imag + a_down_imag * f1_down_real;
                            } // s = 0 : dime
                        } // n = 0 : dimD

                        pFilter0_up -= filter_line_retreat;
                        pFilter0_down -= filter_line_retreat;
                        pFilter1_up -= filter_line_retreat;
                        pFilter1_down -= filter_line_retreat;
                    }   // m = 0 : dimC

                    pFilter0_up += filter_line_skip;
                    pFilter0_down += filter_line_skip;
                    pFilter1_up += filter_line_skip;
                    pFilter1_down += filter_line_skip;
                }   // k = 0 : dimB

                pFilter0_up = pFilter0_down;
                pFilter0_down = pFilter0_up + filter_block_skip;
                pFilter1_up = pFilter1_down;
                pFilter1_down = pFilter1_up + filter_block_skip;

                pArray_up = pArray_down;
                pArray_down = pArray_up + array_block_skip;
            }   // j = 0 : nRepeat
        }   // i = 0 : dimA
    }   // if downsample_dim == M
    else
    {
        // preparation
        filter_block_skip = FilterSlice0.ny / nChannels;
        filter_line_skip = FilterSlice0.ny;
        dimD /= nChannels;

        array_block_skip = dimD * 2;
        for (i = K + 1; i < nDims; i++)
            array_block_skip *= pDims[i];

        pArray_up = pData;
        pArray_down = pArray_up + array_block_skip;

        for (i = 0; i < dimA; i++)
        {
            pFilter0_up = pFilter0_base;
            pFilter0_down = pFilter0_up + filter_block_skip;
            pFilter1_up = pFilter1_base;
            pFilter1_down = pFilter1_up + filter_block_skip;

            for (j = 0; j < dimB; j++)
            {
                for (k = 0; k < dimC; k++)
                {
                    for (m = 0; m < nRepeat; m++)
                    {
                        for (n = 0; n < dimD; n++)
                        {
                            f0_up_real = *(pFilter0_up++);      f0_up_imag = *(pFilter0_up++);
                            f0_down_real = *(pFilter0_down++);  f0_down_imag = *(pFilter0_down++);
                            f1_up_real = *(pFilter1_up++);      f1_up_imag = *(pFilter1_up++);
                            f1_down_real = *(pFilter1_down++);  f1_down_imag = *(pFilter1_down++);

                            for (s = 0; s < dimE; s++)
                            {
                                a_up_real = *(pArray_up++);
                                a_up_imag = *(pArray_up++);
                                a_down_real = *(pArray_down++);
                                a_down_imag = *(pArray_down++);

                                *(pArray_up - 2) = a_up_real * f0_up_real - a_up_imag * f0_up_imag
                                    + a_down_real * f1_up_real - a_down_imag * f1_up_imag;
                                *(pArray_up - 1) = a_up_real * f0_up_imag + a_up_imag * f0_up_real
                                    + a_down_real * f1_up_imag + a_down_imag * f1_up_real;

                                *(pArray_down - 2) = a_up_real * f0_down_real - a_up_imag * f0_down_imag
                                    + a_down_real * f1_down_real - a_down_imag * f1_down_imag;
                                *(pArray_down - 1) = a_up_real * f0_down_imag + a_up_imag * f0_down_real
                                    + a_down_real * f1_down_imag + a_down_imag * f1_down_real;
                            } // s = 0 : dimE
                        }   // n = 0 : dimD

                        pFilter0_up = pFilter0_down;
                        pFilter0_down = pFilter0_up + filter_block_skip;
                        pFilter1_up = pFilter1_down;
                        pFilter1_down = pFilter1_up + filter_block_skip;

                        pArray_up = pArray_down;
                        pArray_down = pArray_up + array_block_skip;
                    }   // m = 0 : nRepeat


                    pFilter0_up -= filter_line_skip;
                    pFilter0_down -= filter_line_skip;
                    pFilter1_up -= filter_line_skip;
                    pFilter1_down -= filter_line_skip;

                }   // k = 0 : dimC
				pFilter0_up += filter_line_skip;
				pFilter0_down = pFilter0_up + filter_block_skip;
				pFilter1_up += filter_line_skip;
				pFilter1_down = pFilter1_up + filter_block_skip;
            } // j = 0 : dimB

        }   // i = 0 : dimA
    }
}

//	This software is provided "as-is", without any express or implied
//	warranty. In no event will the authors be held liable for any 
//	damages arising from the use of this software.