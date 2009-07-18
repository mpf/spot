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
//	mexSurfaceletRec.cpp
//	
//	First created: 04-15-06
//	Last modified: 04-16-06
//
//////////////////////////////////////////////////////////////////////////

#include "mex.h"
#include <math.h>
#include "../Cpp/SurfaceletFilterBank.h"

// Accommodate the different array indexing conventions used in Matlab and C++
void FlipDims(int N, int dst[], const mwSize* src)
{
    for (int i = 0; i < N; i++)
        dst[i] = (int) src[N - 1 - i];
}

void FlipDims2D(int nDims, int dst[], int src[])
{
    for (int i = 0; i < nDims; i++)
        for (int j = 0; j < nDims; j++)
        {
            dst[i * nDims + j] = src[(nDims - 1- j) * nDims + nDims - 1 - i];
        }
}

//	Rec = mexSurfaceletRec(Y, pyr_mode, Lev_array, dec_filters, rec_filters, mSize, beta, lambda)

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    // Parse input
    if (nrhs < 8)
        mexErrMsgTxt("At least 8 input arguments are required!");

    if (nlhs > 1)
        mexErrMsgTxt("Too many output parameters!");

	int IsAdjoint = 0;
	if (nrhs == 9)
		IsAdjoint = (int)(*mxGetPr(prhs[8]));

    int Pyr_Level = ((int) mxGetM(prhs[2])) * ((int) mxGetN(prhs[2]));

	mwSize nDims_Matlab = mxGetNumberOfDimensions(mxGetCell(prhs[0], Pyr_Level));
	const mwSize *pDims_Matlab;

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

    

	SurfaceletRecInfo rec_info;
	rec_info.SetParameters(nDims, mSize, beta, lambda, Pyr_Level, mode, RAISED_COSINE);

	// Set the NDFB levels
	int *pLevels = new int [nDims * nDims];
    int *pNdirectionalSubbands = new int [nDims * Pyr_Level];
    int nSubbands;
	int iLevel, i, j;
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
      
    SurfArray RecArray, LowpassArray;
    SurfArray ***pHighpassArrays = new SurfArray ** [Pyr_Level];
	
    // Lowpass subband
    pDims_Matlab = mxGetDimensions(mxGetCell(prhs[0], Pyr_Level));
    FlipDims(nDims, pDims, pDims_Matlab);
    LowpassArray.AllocateSpace(nDims, pDims);
    LowpassArray.ImportRealValues(mxGetPr(mxGetCell(prhs[0], Pyr_Level)));

    // Highpass subbands
    mxArray *pArrayLevel, *pArrayDimension, *pArrayDirectional;
    for (iLevel = 0; iLevel < Pyr_Level; iLevel++)
    {
        pArrayLevel = mxGetCell(prhs[0], iLevel);
        pHighpassArrays[iLevel] = new SurfArray * [nDims];
        
        for (i = 0; i < nDims; i++)
        {
            nSubbands = pNdirectionalSubbands[iLevel * nDims + nDims - 1 - i];
            pHighpassArrays[iLevel][nDims - 1 - i] = new SurfArray [nSubbands];

            pArrayDimension = mxGetCell(pArrayLevel, i);

            for (j = 0; j < nSubbands; j++)
            {
                pArrayDirectional = mxGetCell(pArrayDimension, j);

                pDims_Matlab = mxGetDimensions(pArrayDirectional);
                FlipDims(nDims, pDims, pDims_Matlab);
                pHighpassArrays[iLevel][nDims - 1 - i][j].AllocateSpace(nDims, pDims);
                pHighpassArrays[iLevel][nDims - 1 - i][j].ImportRealValues(mxGetPr(pArrayDirectional));
            }
        }
    }
    
    SurfaceletFilterBank surf_fb;
	if (IsAdjoint)
	{
		// Adjoint operator
		surf_fb.GetAdjoint(pHighpassArrays, LowpassArray, RecArray, rec_info);
	}
	else
	{
		// usual inverse transform
		surf_fb.GetReconstruction(pHighpassArrays, LowpassArray, RecArray, rec_info);
	}
   

    // release some memory
    for (iLevel = 0; iLevel < Pyr_Level; iLevel++)
    {
        for (i = 0; i < nDims; i++)
        {
            delete [] pHighpassArrays[iLevel][i];
        }
        delete [] pHighpassArrays[iLevel];
    }
    delete [] pHighpassArrays;

    RecArray.GetDims(pDims);

	for (int k = 0; k < nDims; k++)
		pDims_Matlab_Output[k] = pDims[nDims - 1 - k];

    plhs[0] = mxCreateNumericArray(nDims, pDims_Matlab_Output, mxDOUBLE_CLASS, mxREAL);
    RecArray.ExportRealValues(mxGetPr(plhs[0]));

	delete [] pNdirectionalSubbands;
	delete [] pLevels;
    delete [] pDims;   
	delete [] pDims_Matlab_Output;
}

//	This software is provided "as-is", without any express or implied
//	warranty. In no event will the authors be held liable for any 
//	damages arising from the use of this software.