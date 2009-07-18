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
//	mexSurfaceletDec.cpp
//	
//	First created: 04-15-06
//	Last modified: 04-16-06
//
//////////////////////////////////////////////////////////////////////////

#include "mex.h"
#include <math.h>
#include "../Cpp/SurfaceletFilterBank.h"

// Used to accommodate the different array indexing conventions used in Matlab and C++

void FlipDims(int N, int dims[])
{
    int tmp;
    for (int i = 0; i < N / 2; i++)
    {
        tmp = dims[i];
        dims[i] = dims[N - 1 - i];
        dims[N - 1 - i] = tmp;
    }
}

void FlipDims2D(int nDims, int *dst, int *src)
{
    for (int i = 0; i < nDims; i++)
        for (int j = 0; j < nDims; j++)
        {
            dst[i * nDims + j] = src[(nDims - 1- j) * nDims + nDims - 1 - i];
        }
}

//	Subs = mexSurfaceletDec(X, pyr_mode, Lev_array, dec_filters, rec_filters, mSize, beta, lambda)

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    // Parse input
    if (nrhs != 8)
        mexErrMsgTxt("8 input arguments are required!");

    if (nlhs > 1)
        mexErrMsgTxt("Too many output parameters!");

	// Input array X    
    // Check data type of input argument.
    if (!(mxIsDouble(prhs[0])))
    {
        mexErrMsgTxt("Input array must be of type double.");
    }

	// Check array size, only 32 bit array sizes are supported.
    mwSize nDims_Matlab = mxGetNumberOfDimensions(prhs[0]);
	const mwSize *pDims_Matlab;
    pDims_Matlab = mxGetDimensions(prhs[0]);

	for (mwIndex k = 0; k < nDims_Matlab; k++)
		if ((double) pDims_Matlab[k] >= pow(2.0, 32.0) - 1.0)
			mexErrMsgTxt("The dimension of the input array along each axis must be smaller than 2^32 - 1.");
		

    double *pX;
    pX = mxGetPr(prhs[0]);

    if (mxGetPi(prhs[0]))
    {
        mexErrMsgTxt("Input X must be real-valued!");
    }

	
    int nDims = (int) nDims_Matlab;

	// Pyr_mode
	Pyramid_Mode mode;
	switch((int)(*mxGetPr(prhs[1])))
	{
	case 1:
		mode = DOWNSAMPLE_1;
		break; 
	case 15:
		mode = DOWNSAMPLE_15;
		break;
	case 2:
		mode = DOWNSAMPLE_2;
	    break;
	default:
	    mexErrMsgTxt("Pyramid mode must be one from 1, 15 and 2");
		break;
	}
	
	// mSize
    int mSize = (int)(*mxGetPr(prhs[5]));
    if (mSize <= 0)
        mexErrMsgTxt("mSize must be larger than or equal to 1.");

    // beta
    double beta = *mxGetPr(prhs[6]);

    // lambda
    double lambda = *mxGetPr(prhs[7]);

    int Pyr_Level = ((int) mxGetM(prhs[2])) * ((int) mxGetN(prhs[2]));

	SurfaceletRecInfo rec_info;
	rec_info.SetParameters(nDims, mSize, beta, lambda, Pyr_Level, mode, RAISED_COSINE);

	// Set the NDFB levels
	int *pLevels = new int [nDims * nDims];
    int *pNdirectionalSubbands = new int [nDims * Pyr_Level];
    int nSubbands;
	int iLevel, i, j, k;
	for (iLevel = 0; iLevel < Pyr_Level; iLevel++)
	{
		if (!mxIsClass(mxGetCell(prhs[2], iLevel), "int32"))
			mexErrMsgTxt("The lev_array cell array must contain interger valued matrices");
		
		FlipDims2D(nDims, pLevels, (int*)mxGetPr(mxGetCell(prhs[2], iLevel)));

        for (i = 0; i < nDims; i++)
        {
            nSubbands = 1;
            for (j = 0; j < nDims; j++)
            {
                if (i != j)
                {
                    nSubbands *= (int)pow(2.0, pLevels[i * nDims + j]);    
                }

            }
            pNdirectionalSubbands[iLevel * nDims + i] = nSubbands;
        }
		rec_info.SetNdfbLevel(iLevel, pLevels);
	}

    // Get the filters
	int filter_dims[8], filter_centers[8];
	double *pFilterData[4];
	int idx;
	mxArray *pFilterArray, *pCenter;

	for (i = 0; i < 2; i++)
		for (j = 0; j < 2; j++)
		{
			pFilterArray = mxGetCell(prhs[3 + i], j * 2);
			pCenter = mxGetCell(prhs[3 + i], j * 2 + 1);
			
			idx = i * 4 + j * 2;
			filter_dims[idx] = (int) mxGetN(pFilterArray);
			filter_dims[idx + 1] = (int) mxGetM(pFilterArray);

			filter_centers[idx] = (int)(*(mxGetPr(pCenter) + 1)) - 1;
			filter_centers[idx + 1] = (int)(*mxGetPr(pCenter)) - 1;

			pFilterData[idx / 2] = mxGetPr(pFilterArray);
		}

    // set the checkerboard filters
	rec_info.SetFilters(pFilterData[0], filter_dims, filter_centers, pFilterData[1], filter_dims + 2,
		filter_centers + 2, pFilterData[2], filter_dims + 4, filter_centers + 4,  pFilterData[3], 
		filter_dims + 6, filter_centers + 6);
	

    
	mwSize *pDims_Matlab_Output = new mwSize [nDims];

    int *pDims = new int [nDims];

    // adapt to the column-major and row-major conventions
    for (i = 0; i < nDims; i++)
        pDims[i] = (int) pDims_Matlab[nDims - 1 - i];


    SurfArray InArray, LowpassArray;
    InArray.AllocateSpace(nDims, pDims);
    InArray.ImportRealValues(pX);

    SurfArray ***pHighpassArrays = new SurfArray ** [Pyr_Level];

	SurfaceletFilterBank surf_fb;

    bool IsValid;
    
    IsValid = surf_fb.GetDecomposition(InArray, pHighpassArrays, LowpassArray, rec_info);

    if (IsValid)
    {
        // free the memory space
        InArray.Reset();

        // Create output arguments
        mxArray *pArrayLevel, *pArrayDimension, *pArrayDirectional;

        plhs[0] = mxCreateCellMatrix(Pyr_Level + 1, 1);

        // Save the lowpass array
        LowpassArray.GetDims(pDims);
        FlipDims(nDims, pDims);

		for (k = 0; k < nDims; k++)
			pDims_Matlab_Output[k] = (mwSize) pDims[k];

        pArrayLevel = mxCreateNumericArray(nDims, pDims_Matlab_Output, mxDOUBLE_CLASS, mxREAL);
        LowpassArray.ExportRealValues(mxGetPr(pArrayLevel));
        mxSetCell(plhs[0], Pyr_Level, pArrayLevel);
        LowpassArray.Reset();

        for (iLevel = 0; iLevel < Pyr_Level; iLevel++)
        {
            pArrayLevel = mxCreateCellMatrix(nDims, 1);

            for (i = 0; i < nDims; i++)
            {
                nSubbands = pNdirectionalSubbands[iLevel * nDims + i];

                pArrayDimension = mxCreateCellMatrix(nSubbands, 1);

                for (j = 0; j < nSubbands; j++)
                {
                    pHighpassArrays[iLevel][i][j].GetDims(pDims);
                    FlipDims(nDims, pDims);

					for (k = 0; k < nDims; k++)
						pDims_Matlab_Output[k] = (mwSize) pDims[k];

                    pArrayDirectional = mxCreateNumericArray(nDims, pDims_Matlab_Output, mxDOUBLE_CLASS, mxREAL);
                    pHighpassArrays[iLevel][i][j].ExportRealValues(mxGetPr(pArrayDirectional));
                    pHighpassArrays[iLevel][i][j].Reset();

                    mxSetCell(pArrayDimension, j, pArrayDirectional);
                }

                delete [] pHighpassArrays[iLevel][i];

                mxSetCell(pArrayLevel, nDims - 1 - i, pArrayDimension);
            }

            delete [] pHighpassArrays[iLevel];

            mxSetCell(plhs[0], iLevel, pArrayLevel);
        }
    }
    else
        mexErrMsgTxt("The decomposition parameters are not compatible with the input array size.");

	delete [] pNdirectionalSubbands;
	delete [] pLevels;
    delete [] pHighpassArrays;
    delete [] pDims;   
	delete [] pDims_Matlab_Output;
}

//	This software is provided "as-is", without any express or implied
//	warranty. In no event will the authors be held liable for any 
//	damages arising from the use of this software.