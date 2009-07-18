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
//	PyramidFilterBank.cpp
//	
//	First created: 03-27-06
//	Last modified: 04-10-06
//
//////////////////////////////////////////////////////////////////////////

#include "PyramidFilterBank.h"
#include <cassert>
#include "math.h"

extern const double PI;

extern void MessageLog(const char*, const char*, const char*);


//////////////////////////////////////////////////////////////////////////
//  Class constructor
//////////////////////////////////////////////////////////////////////////

PyramidFilterBank::PyramidFilterBank()
{
	// do nothing
}


//////////////////////////////////////////////////////////////////////////
// Class destructor
//////////////////////////////////////////////////////////////////////////

PyramidFilterBank::~PyramidFilterBank()
{
	// do nothing
}


//////////////////////////////////////////////////////////////////////////
// Multidimensional multiscale pyramid decomposition
//////////////////////////////////////////////////////////////////////////
//
// PARAMETERS:
//
// InArray:     
//      Input array 
//
// OutArrays:    
//      Output arrays. OutArrays[0] will be the highpass subband at the finest scale
//      and OutArrays[Level] will be the lowpass subband at the coarsest scale.
//
// Level:   
//      # of decompositions
//
// OutputInFourierDomain: 
//      If true, all output arrays will be in the Fourier domain.
//
// pyr_mode: 
//      choose from 1, 1.5 or 2, corresponding to different redundancy ratios
//
// func_type:
//      used to specify which smooth function to use.

void PyramidFilterBank::GetDecomposition(SurfArray &InArray, SurfArray OutArrays[], 
      int Level, bool OutputInFourierDomain, enum Pyramid_Mode pyr_mode, enum SmoothFunctionType func_type)
{
	double *w_array = NULL, *tbw_array = NULL, *D_array = NULL;

	assert(Level > 0);

    // allocate some temporary memory space
	try
	{
		// cut-off frequencies
        w_array = new double [Level];
        
        // Transition Band Widths
		tbw_array = new double [Level];

        // Down sampling ratios
		D_array = new double [Level];
	
        // Obtain the parameters for each level
		GetPyramidParameters(pyr_mode, Level, w_array, tbw_array, D_array);

        // the input array must be converted to the Fourier domain
		if (InArray.IsRealValued())
			InArray.GetInPlaceForwardFFT();

		SurfArray *pLowpass, *pIn = &InArray;

		register int i;

		for (i = 0; i < Level; i++)
		{
			if (i == Level - 1)
                pLowpass = &OutArrays[Level];
            else
                pLowpass = new SurfArray;
			
			DecompositionOneStep(*pIn, *pLowpass, OutArrays[i], w_array[i], tbw_array[i], D_array[i], func_type);
			
			
            // IMPORTANT!
            if (i != 0) delete pIn;

            // iteration
			pIn = pLowpass;
		}

        // go back to spatial domain if asked to ...
		if (!OutputInFourierDomain)
		{
			for (i = 0; i <= Level; i++)
				OutArrays[i].GetInPlaceBackwardFFT();
		}
	}
	catch (std::bad_alloc)
	{
		MessageLog("PyramidFilterBank", "GetDecomposition", "Out of memory!");
		if (w_array) delete [] w_array;
		if (tbw_array) delete [] tbw_array;
		if (D_array) delete [] D_array;
	}

	delete [] w_array;
	delete [] tbw_array;
	delete [] D_array;
}


//////////////////////////////////////////////////////////////////////////
// Multidimensional multiscale pyramid reconstruction
//////////////////////////////////////////////////////////////////////////
//
// PARAMETERS:
//
// InArrays:     
//      Input arrays 
//
// OutArray:    
//      The reconstructed array
//
// Level:   
//      # of decompositions
//
// OutputInFourierDomain: 
//      If true, all output arrays will be in the Fourier domain.
//
// pyr_mode: 
//      choose from 1, 1.5 or 2, corresponding to different redundancy ratios
//
// func_type:
//      used to specify which smooth function to use.

void PyramidFilterBank::GetReconstruction(SurfArray InArrays[], SurfArray &OutArray, int Level, 
			bool OutputInFourierDomain, enum Pyramid_Mode pyr_mode, enum SmoothFunctionType func_type)
{
	double *w_array = NULL, *tbw_array = NULL, *D_array = NULL;

	assert(Level > 0);

    // allocate some temporary memory space
	try
	{
        // cut-off frequencies
        w_array = new double [Level];

        // Transition Band Widths
        tbw_array = new double [Level];

        // Down sampling ratios
        D_array = new double [Level];

        // Obtain the parameters for each level	
		GetPyramidParameters(pyr_mode, Level, w_array, tbw_array, D_array);
		
		register int i;

        // the input arrays must be in the Fourier domain
		for (i = 0; i <= Level; i++)
		{
			if (InArrays[i].IsRealValued())
				InArrays[i].GetInPlaceForwardFFT();
		}


		SurfArray *pLowpass, *pRec;
		
		pLowpass = &InArrays[Level];
		for (i = Level - 1; i >= 0; i--)
		{
			if (i == 0)
                pRec = &OutArray;
            else
                pRec = new SurfArray;
			ReconstructionOneStep(*pLowpass, InArrays[i], *pRec, w_array[i], tbw_array[i], D_array[i], func_type);
			
			if (i < Level - 1) delete pLowpass;
			pLowpass = pRec;
		}

		if (!OutputInFourierDomain)
		{
			OutArray.GetInPlaceBackwardFFT();
		}

	}
	catch (std::bad_alloc)
	{
		MessageLog("PyramidFilterBank", "GetDecomposition", "Out of memory!");
		if (w_array) delete [] w_array;
		if (tbw_array) delete [] tbw_array;
		if (D_array) delete [] D_array;
	}

	delete [] w_array;
	delete [] tbw_array;
	delete [] D_array;
}


//////////////////////////////////////////////////////////////////////////
//  Obtain the parameters for pyramid decomposition at different levels
//////////////////////////////////////////////////////////////////////////
//
// PARAMETERS:
//
// pyr_mode:
//      Different mode for pyramid decomposition. Choose from 1, 1.5, 2, which correspond to 
//      different redundancy ratios
// 
// Level:
//      # of decomposition levels
//
// w_array:
//      An array used to store the cut-off frequencies at different levels
//
// tbw_array:
//      An array used to store the transition bandwidths at different levels
//
// D_array:
//      An array used to store the downsampling ratios at different levels

void PyramidFilterBank::GetPyramidParameters(enum Pyramid_Mode pyr_mode, int Level, 
	double w_array[], double tbw_array[], double D_array[])
{
	register int i;

	switch(pyr_mode)
	{
	case DOWNSAMPLE_1:

		w_array[0] = 0.5;
		tbw_array[0] = 1 / 6.0;
		D_array[0] = 1;
		for (i = 1; i < Level; i++)
		{
			w_array[i] = 0.25;
			tbw_array[i] = 1 / 12.0;
			D_array[i] = 2.0;
		}

		break;

	case DOWNSAMPLE_15:

		w_array[0] = 0.5;
		tbw_array[0] = 1 / 7.0;
		D_array[0] = 1.5;
		for (i = 1; i < Level; i++)
		{
			w_array[i] = 3 / 8.0;
			tbw_array[i] = 1 / 9.0;
			D_array[i] = 2.0;
		}

		break;

	case DOWNSAMPLE_2:

		for (i = 0; i < Level; i++)
		{
			w_array[i] = 1 / 3.0;
			tbw_array[i] = 1 / 7.0;
			D_array[i] = 2.0;
		}

		break;
	default:
		// This should not happen.
		assert(false);
		break;
	}
}


//////////////////////////////////////////////////////////////////////////
// One level of decomposition in the multidimensional multiscale pyramid
//////////////////////////////////////////////////////////////////////////
//
// Parameters: 
//
// InArray:       
//      The input array in the Fourier domain
//
// LowpassArray:  
//      The resulting lowpass array. NOTE: memory space will be allocated.
//
// HighpassArray: 
//      The resulting highpass array. NOTE: memory space will be allocated.
//
// w:
//      The passband width (in fractions of PI)
//
// tbw:
//      Transition bandwidth
//
// D:
//      Downsampling ratio
//
// func_type:
//      Specify which smooth kernel to use.

void PyramidFilterBank::DecompositionOneStep(SurfArray &InArray, SurfArray &LowpassArray, 
     SurfArray &HighpassArray, double w, double tbw, double D, enum SmoothFunctionType func_type)
{
	int *pDims, *pDims_sml, *pIndices, *pSkip, *pSkip_sml, *pPassbandFrequences;
    double **pPassbandValues;
    
    int N;
    register int i;
    register int j;

    // dimension of the problem
    N = InArray.GetRank();

    // allocate some memory space
    try
    {        
        // dimension of the input array
        pDims = new int [N];

        // dimension of the downsampled lowpass array
        pDims_sml = new int [N];

        InArray.GetDims(pDims);
        for (i = 0; i < N; i++)
        {
            pDims_sml[i] = (int)(pDims[i] / D);
            // just to make sure D "divides" the original dimension
            if (fabs(pDims_sml[i] - pDims[i] / D) > 1e-10)
                assert(false);
        }

        // Allocate space for the output arrays
        LowpassArray.AllocateSpace(N, pDims_sml);
        LowpassArray.ZeroFill();
        LowpassArray.SetIsRealValued(false);
        HighpassArray = InArray; // Note: this also allocates the memory space

        // indices 
        pIndices = new int [N];

        // memory jump distance for the larger array
        pSkip = new int [N];

        // memory jump distance for the smaller array
        pSkip_sml = new int [N];

        // Passband cutoff frequencies
        pPassbandFrequences = new int [N];
    
        pPassbandValues = new double* [N];
        for (i = 0; i < N - 1; i++)
            pPassbandValues[i] = new double [pDims[i]];

        pPassbandValues[N - 1] = new double [pDims[N - 1] / 2 + 1];
    
    }    
    catch (std::bad_alloc)
    {
        MessageLog("PyramidFilterBank", "DecompositionOneStep", "Out of memory!");
        throw;
    }

    // Calculate the 1-D passband values
    for (i = 0; i < N; i++)
    {
        CalculateFilterValues1D(pPassbandValues[i], pDims[i], w, tbw, (i != N - 1), func_type);
        pPassbandFrequences[i] = (int)(ceil(pDims[i] / 2.0 * (w + tbw)));
    }

    // Calculate memory jump values (tricky)
    for (j = 0; j < N - 1; j++)
    {
        pSkip_sml[j] = pSkip[j] = 1;
        for (i = j + 1; i < N; i++)
        {
            pSkip[j] *= ((i == N - 1)?  (2 * (pDims[N - 1] / 2 + 1)) : pDims[i]);
            pSkip_sml[j] *= ((i == N - 1)?  (2 * (pDims_sml[N - 1] / 2 + 1)) : pDims_sml[i]);
        }

        assert(pDims[j] - 2 * pPassbandFrequences[j] >= 0);
        assert(pDims_sml[j] - 2 * pPassbandFrequences[j] >= 0);

        pSkip[j] *= (pDims[j] - 2 * pPassbandFrequences[j]);
        pSkip_sml[j] *= pDims_sml[j] - 2 * pPassbandFrequences[j];

    }
    pSkip[N - 1] = 2 * (pDims[N - 1] / 2 + 1 - pPassbandFrequences[N - 1]);
    pSkip_sml[N - 1] = 2 * (pDims_sml[N - 1] / 2 + 1 - pPassbandFrequences[N - 1]);
    

    int nRows, nLastDimension;
 
    // number of rows
    nRows = 1;
    for (i = 0; i < N - 1; i++)
        nRows *= pDims[i];
    // number of elements along the last (continuous) dimension
    nLastDimension = pDims[N - 1] / 2 + 1;
   
    // pointers to the data array
    double *pLP, *pHP, *pIn;
    int padding;
    pLP = LowpassArray.GetPointer(padding);
    pHP = HighpassArray.GetPointer(padding);
    pIn = InArray.GetPointer(padding);

    double LP_filter_value, HP_filter_value, filter_value;
    double scaling_factor;
    
    // IMPORTANT: subject to change
    // should be paired with the scaling_factor used in the reconstruction
    scaling_factor = 1.0 / pow(D, N / 2.0);

    // initialize the indices array
    for (i = 0; i < N; i++)
        pIndices[i] = 0;

    int passband_last = pPassbandFrequences[N - 1];
    double *pFilterLast;

    double *pBaseHP = pHP, *pBaseLP = pLP, *pBaseIn = pIn;

    // start computation
    for (j = 0; j < nRows; j++)
    {
        filter_value = 1.0;
        for (i = 0; i < N - 1; i++)
            filter_value *= pPassbandValues[i][pIndices[i]];
        
        pFilterLast = pPassbandValues[N - 1];
        for (i = 0; i < passband_last; i++)
        {
            LP_filter_value = filter_value * *(pFilterLast++);
            HP_filter_value = sqrt(1 - LP_filter_value * LP_filter_value);
            LP_filter_value *= scaling_factor;
            *(pLP++) = (*pIn) * LP_filter_value;
            *(pHP++) = *(pIn++) * HP_filter_value;
            *(pLP++) = (*pIn) * LP_filter_value;
            *(pHP++) = *(pIn++) * HP_filter_value;
        }
        
        pLP += pSkip_sml[N - 1];
        pHP += pSkip[N - 1];
        pIn += pSkip[N - 1];
        
        for (i = N - 2; i >= 0; i--)
        {
            if ( (++pIndices[i]) < pDims[i])
            {
                if (pIndices[i] == pPassbandFrequences[i])
                {
                    pIndices[i] = pDims[i] - pPassbandFrequences[i];
                    pIn += pSkip[i];
                    pHP += pSkip[i];
                    pLP += pSkip_sml[i];

                    //IMPORTANT
                    j += pSkip[i] / (2 * (pDims[N - 1] / 2 + 1));
                }

                break;
            }
            else
                pIndices[i] = 0;

        }
    }


    // free memory spaces
    for (i = 0; i < N; i++)
        delete [] pPassbandValues[i];
    delete [] pPassbandValues;
    delete [] pPassbandFrequences;
    delete [] pSkip_sml;
    delete [] pSkip;
    delete [] pIndices;
    delete [] pDims;
    delete [] pDims_sml;
}


//////////////////////////////////////////////////////////////////////////
//	One level of reconstruction in the multidimensional multiscale pyramid
//////////////////////////////////////////////////////////////////////////
//
//	Parameters: 
//
//	LowpassArray:  
//		The input lowpass array.
//
//	HighpassArray: 
//      The input highpass array.
//
//	OutArray:      
//      The reconstructed array in the Fourier domain. Note: memory space will be allocated here.
//
//	w:
//      The passband width (in fractions of PI)
//
//	tbw:
//      Transition bandwidth
//
//	D:
//      Downsampling ratio
//
//	func_type:
//      Specify which smooth kernel to use.

void PyramidFilterBank::ReconstructionOneStep(SurfArray &LowpassArray, SurfArray &HighpassArray, 
     SurfArray &OutArray, double w, double tbw, double D, enum SmoothFunctionType func_type)
{
    int *pDims, *pDims_sml, *pIndices, *pSkip, *pSkip_sml, *pPassbandFrequences;
    double **pPassbandValues;

    int N;
    register int i;
    register int j;

    // dimension of the problem
    N = LowpassArray.GetRank();

    // allocate some memory space
    try
    {        
        // dimension of the output array
        pDims = new int [N];

        // dimension of the downsampled lowpass array
        pDims_sml = new int [N];

        HighpassArray.GetDims(pDims);
        LowpassArray.GetDims(pDims_sml);
        for (i = 0; i < N; i++)
        {
            // just to make sure D "divides" the original dimension
            if (fabs(pDims_sml[i] - pDims[i] / D) > 1e-10)
                assert(false);
        }

        // Allocate space for the output arrays
        OutArray = HighpassArray; // Note: this also allocates the memory space

        // indices 
        pIndices = new int [N];

        // memory jump distance for the larger array
        pSkip = new int [N];

        // memory jump distance for the smaller array
        pSkip_sml = new int [N];

        // Passband cutoff frequencies
        pPassbandFrequences = new int [N];

        pPassbandValues = new double* [N];
        for (i = 0; i < N - 1; i++)
            pPassbandValues[i] = new double [pDims[i]];

        pPassbandValues[N - 1] = new double [pDims[N - 1] / 2 + 1];

    }    
    catch (std::bad_alloc)
    {
        MessageLog("PyramidFilterBank", "DecompositionOneStep", "Out of memory!");
        throw;
    }

    // Calculate the 1-D passband values
    for (i = 0; i < N; i++)
    {
        CalculateFilterValues1D(pPassbandValues[i], pDims[i], w, tbw, (i != N - 1), func_type);
        pPassbandFrequences[i] = (int)(ceil(pDims[i] / 2.0 * (w + tbw)));
    }

    // Calculate memory jump values
    for (j = 0; j < N - 1; j++)
    {
        pSkip_sml[j] = pSkip[j] = 1;
        for (i = j + 1; i < N; i++)
        {
            pSkip[j] *= ((i == N - 1)?  (2 * (pDims[N - 1] / 2 + 1)) : pDims[i]);
            pSkip_sml[j] *= ((i == N - 1)?  (2 * (pDims_sml[N - 1] / 2 + 1)) : pDims_sml[i]);
        }

        assert(pDims[j] - 2 * pPassbandFrequences[j] >= 0);
        assert(pDims_sml[j] - 2 * pPassbandFrequences[j] >= 0);

        pSkip[j] *= (pDims[j] - 2 * pPassbandFrequences[j]);
        pSkip_sml[j] *= pDims_sml[j] - 2 * pPassbandFrequences[j];
    }
    pSkip[N - 1] = 2 * (pDims[N - 1] / 2 + 1 - pPassbandFrequences[N - 1]);
    pSkip_sml[N - 1] = 2 * (pDims_sml[N - 1] / 2 + 1 - pPassbandFrequences[N - 1]);

    int nRows, nLastDimension;

    // number of rows
    nRows = 1;
    for (i = 0; i < N - 1; i++)
        nRows *= pDims[i];
    // number of elements along the last (continuous) dimension
    nLastDimension = pDims[N - 1] / 2 + 1;

    // pointers to the data array
    double *pLP, *pHP, *pOut;
    int padding;
    pLP = LowpassArray.GetPointer(padding);
    pHP = HighpassArray.GetPointer(padding);
    pOut = OutArray.GetPointer(padding);

    double LP_filter_value, HP_filter_value, filter_value;
    double scaling_factor;

    // IMPORTANT: subject to change
    // should be paired with the scaling_factor used in the reconstruction
    scaling_factor = pow(D, N / 2.0);

    // initialize the indices array
    for (i = 0; i < N; i++)
        pIndices[i] = 0;

    int passband_last = pPassbandFrequences[N - 1];
    double *pFilterLast;

    // start computation
    for (j = 0; j < nRows; j++)
    {
        filter_value = 1.0;
        for (i = 0; i < N - 1; i++)
            filter_value *= pPassbandValues[i][pIndices[i]];

        pFilterLast = pPassbandValues[N - 1];
        for (i = 0; i < passband_last; i++)
        {
            LP_filter_value = filter_value * *(pFilterLast++);
            HP_filter_value = sqrt(1 - LP_filter_value * LP_filter_value);
            LP_filter_value *= scaling_factor;
            *pOut = *(pLP++) * LP_filter_value;
            *(pOut++) += *(pHP++)* HP_filter_value;
            *pOut = *(pLP++) * LP_filter_value;
            *(pOut++) += *(pHP++) * HP_filter_value;
        }
        
        pLP += pSkip_sml[N - 1];
        pHP += pSkip[N - 1];
        pOut += pSkip[N - 1];

        for (i = N - 2; i >= 0; i--)
        {
            if ( (++pIndices[i]) < pDims[i])
            {
                if (pIndices[i] == pPassbandFrequences[i])
                {
                    pIndices[i] = pDims[i] - pPassbandFrequences[i];
                    pOut += pSkip[i];
                    pHP += pSkip[i];
                    pLP += pSkip_sml[i];

                    //IMPORTANT
                    j += pSkip[i] / (2 * (pDims[N - 1] / 2 + 1));
                }

                break;
            }
            else
                pIndices[i] = 0;

        }
    }


    // free memory spaces
    for (i = 0; i < N; i++)
        delete [] pPassbandValues[i];
    delete [] pPassbandValues;
    delete [] pPassbandFrequences;
    delete [] pSkip_sml;
    delete [] pSkip;
    delete [] pIndices;
    delete [] pDims;
    delete [] pDims_sml;
}


//////////////////////////////////////////////////////////////////////////
//	raised cosine
//////////////////////////////////////////////////////////////////////////

inline
double PyramidFilterBank::rcos(double x)
{
	if (x < 0.0)
		return 0.0;
	else 
	{
		if (x > 1.0)
			return 1.0;
		else
			return  0.5 * (1.0 - cos(PI * x));
	}
}


//////////////////////////////////////////////////////////////////////////
//	Meyer filter from the VK book
//////////////////////////////////////////////////////////////////////////

inline
double PyramidFilterBank::Meyer_vkbook(double x)
{
	if (x < 0.0)
		return 0.0;
	else 
	{
		if (x > 1.0)
			return 1.0;
		else
		{
			double y = x * x;
			return  3.0 * y - 2.0 * x * y;
		}
	}
}


//////////////////////////////////////////////////////////////////////////
//	Calculate the 1-D lowpass filters
//////////////////////////////////////////////////////////////////////////
//
//	PARAMETERS:
//
//	pValues:
//      an array to be filled with filter values
//
//	dim:
//      length of the signal along this specific dimension
//
//	w:
//      passband frequency (in fractions of PI)
//
//	tbw:
//      transition bandwidth (in fractions of PI)
//
//	UseSymmExt: 
//      Whether to extend the filter values symmetrically
//
//	func_type:  
//      specify which smooth function to use

void PyramidFilterBank::CalculateFilterValues1D(double *pValues, int dim, double w, 
      double tbw, bool UseSymmExt, enum SmoothFunctionType func_type)
{
    register int i;
    int half_dim;
    double pointA, pointB;

    // roughly from 0 to PI
    half_dim = dim / 2 + 1;
    
    // from 0 to pointA: pure passband
    pointA = floor(dim / 2.0 * (w - tbw));
    
    // from pointA to pointB: transition band
    // beyond pointB: stopband
    pointB = ceil(dim / 2.0 * (w + tbw));

    assert((pointB > pointA) && (pointA > 0) && (pointB < half_dim)) ;

    switch(func_type)
    {
    case MEYER_VKBOOK:

        for (i = 0; i < half_dim; i++)
            *(pValues++) = sqrt(Meyer_vkbook((pointB - i) / (pointB - pointA)));
    	break;

    case RAISED_COSINE:

        for (i = 0; i < half_dim; i++)
            *(pValues++) = sqrt(rcos((pointB - i) / (pointB - pointA)));
        break;

    default:
        assert(false);
        break;
    }

    // Hermitian symmetry
    if (UseSymmExt)
    {
        double *pMirror;
        pMirror = pValues - ((dim % 2)? 1 : 2);
        for (i = 0; i < dim - half_dim; i++)
            *(pValues++) = *(pMirror--);
    }
}

//	This software is provided "as-is", without any express or implied
//	warranty. In no event will the authors be held liable for any 
//	damages arising from the use of this software.