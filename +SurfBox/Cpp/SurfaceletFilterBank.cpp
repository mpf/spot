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
//	SurfaceletFilterBank.cpp
//	
//	First created: 04-02-06
//	Last modified: 04-14-06
//
//////////////////////////////////////////////////////////////////////////

#include "SurfaceletFilterBank.h"
#include <math.h>
#include <cassert>

extern void MessageLog(const char*, const char*, const char*);


//////////////////////////////////////////////////////////////////////////
//	Constructor
//////////////////////////////////////////////////////////////////////////

SurfaceletRecInfo::SurfaceletRecInfo()
{
	// Initialize the pointer
	NdfbLevels = NULL;
}


//////////////////////////////////////////////////////////////////////////
//	Destructor
//////////////////////////////////////////////////////////////////////////

SurfaceletRecInfo::~SurfaceletRecInfo()
{
	// Release memory resource
	if (NdfbLevels)
	{
		assert(PyrLevel >= 1);
		for (int i = 0; i < PyrLevel; i++)
			delete [] NdfbLevels[i];

		delete [] NdfbLevels;
	}
}


//////////////////////////////////////////////////////////////////////////
//	Set decomposition and reconstruction parameters
//////////////////////////////////////////////////////////////////////////

void SurfaceletRecInfo::SetParameters(int nDims_, int bo_, int mSize_, double beta_, double lambda_, int PyrLevel_,
		enum Pyramid_Mode pyr_mode_, enum SmoothFunctionType func_type_, string& dir_info)
{
	assert(NdfbLevels == NULL);
	
	nDims = nDims_;
	assert(nDims >= 2);

	bo = bo_;
	mSize = mSize_;
	beta = beta_;
	lambda = lambda_;

	PyrLevel = PyrLevel_;
	assert(PyrLevel >= 1);

	pyr_mode = pyr_mode_;
	func_type = func_type_;

	try
	{
		// Get the checkerboard filters
		ndfb_fb.GetCheckerboardFilters(bo, true, Dec_filter0, Dec_center0, Dec_filter1, Dec_center1, dir_info);
		ndfb_fb.GetCheckerboardFilters(bo, false, Rec_filter0, Rec_center0, Rec_filter1, Rec_center1, dir_info);
	}
	catch (...)
	{
		// filter coefficients files not found
		throw;
	}
	
	// allocate memory space
	try
	{
		NdfbLevels = new int * [PyrLevel];
		for (int i = 0; i < PyrLevel; i++)
			NdfbLevels[i] = new int [nDims * nDims];
	}
	catch (std::bad_alloc)
	{
		MessageLog("SurfaceletRecInfo", "SetParameters", "Out of memory!");
		throw;
	}
}


//////////////////////////////////////////////////////////////////////////
//	Set decomposition and reconstruction parameters (without reading the filter coefficients files)
//////////////////////////////////////////////////////////////////////////

void SurfaceletRecInfo::SetParameters(int nDims_, int mSize_, double beta_, double lambda_, 
	int PyrLevel_, enum Pyramid_Mode pyr_mode_, enum SmoothFunctionType func_type_)
{
	assert(NdfbLevels == NULL);

	nDims = nDims_;
	assert(nDims >= 2);

	mSize = mSize_;
	beta = beta_;
	lambda = lambda_;

	PyrLevel = PyrLevel_;
	assert(PyrLevel >= 1);

	pyr_mode = pyr_mode_;
	func_type = func_type_;

	// allocate memory space
	try
	{
		NdfbLevels = new int * [PyrLevel];
		for (int i = 0; i < PyrLevel; i++)
			NdfbLevels[i] = new int [nDims * nDims];
	}
	catch (std::bad_alloc)
	{
		MessageLog("SurfaceletRecInfo", "SetParameters", "Out of memory!");
		throw;
	}
}


//////////////////////////////////////////////////////////////////////////
//	Directly set the checkerboard filters
//////////////////////////////////////////////////////////////////////////

void SurfaceletRecInfo::SetFilters(double *pFilter0, int pDims0[], int center0[], 
	double *pFilter1, int pDims1[], int center1[], double *pFilter2, int pDims2[], int center2[],
	double *pFilter3, int pDims3[], int center3[])
{
	// Decomposition filter 0
	Dec_filter0.AllocateSpace(pDims0[0], pDims0[1]);
	memcpy(Dec_filter0.GetPointer(), pFilter0, pDims0[0] * pDims0[1] * sizeof(double));
	Dec_center0[0] = center0[0];
	Dec_center0[1] = center0[1];

	// Decomposition filter 1
	Dec_filter1.AllocateSpace(pDims1[0], pDims1[1]);
	memcpy(Dec_filter1.GetPointer(), pFilter1, pDims1[0] * pDims1[1] * sizeof(double));
	Dec_center1[0] = center1[0];
	Dec_center1[1] = center1[1];

	// Reconstruction filter 0
	Rec_filter0.AllocateSpace(pDims2[0], pDims2[1]);
	memcpy(Rec_filter0.GetPointer(), pFilter2, pDims2[0] * pDims2[1] * sizeof(double));
	Rec_center0[0] = center2[0];
	Rec_center0[1] = center2[1];

	// Reconstruction filter 1
	Rec_filter1.AllocateSpace(pDims3[0], pDims3[1]);
	memcpy(Rec_filter1.GetPointer(), pFilter3, pDims3[0] * pDims3[1] * sizeof(double));
	Rec_center1[0] = center3[0];
	Rec_center1[1] = center3[1];
}

//////////////////////////////////////////////////////////////////////////
//	Get the decomposition level info at a certain scale
//////////////////////////////////////////////////////////////////////////
//
//	PARAMETERS:
//
//	scale:
//		Specifying pyramid scale
//
//	Level:
//		An int array of dimension nDims * nDims to be filled with the decomposition levels

void SurfaceletRecInfo::GetNdfbLevel(int scale, int Level[]) const
{
	assert((scale >= 0) && (scale < PyrLevel));

	memcpy(Level, NdfbLevels[scale], nDims * nDims * sizeof(int));
}


//////////////////////////////////////////////////////////////////////////
//	Set the decomposition level info at a certain scale
//////////////////////////////////////////////////////////////////////////
//
//	PARAMETERS:
//
//	scale:
//		Specifying pyramid scale
//
//	Level:
//		An int array of dimension nDims * nDims storing the decomposition levels

void SurfaceletRecInfo::SetNdfbLevel(int scale, int Level[])
{
	assert((scale >= 0) && (scale < PyrLevel));
	assert(NdfbLevels != NULL);

	memcpy(NdfbLevels[scale], Level, nDims * nDims * sizeof(int));
}


//////////////////////////////////////////////////////////////////////////
//	Constructor
//////////////////////////////////////////////////////////////////////////

SurfaceletFilterBank::SurfaceletFilterBank()
{
	// do nothing
}


//////////////////////////////////////////////////////////////////////////
//	Destructor
//////////////////////////////////////////////////////////////////////////

SurfaceletFilterBank::~SurfaceletFilterBank()
{
	// do nothing
}


//////////////////////////////////////////////////////////////////////////
//	Surfacelet filter bank decomposition
//////////////////////////////////////////////////////////////////////////
//
//	PARAMETERS:
//
//	InArray
//		The input array
//	
//	OutHighpassArrays
//		The resulting highpass directional subbands
//
//	LowpassArray
//		The lowpass subband
//
//	ReconstructionInfo
//		Filter bank parameters

bool SurfaceletFilterBank::GetDecomposition(SurfArray &InArray, SurfArray **OutHighpassArrays[], SurfArray &OutLowpassAray, 
	SurfaceletRecInfo &ReconstructionInfo)
{
	// First check the validity of the parameters
	if (!CheckParameters(InArray, ReconstructionInfo))
		return false;
	
	int nDims = InArray.GetRank();
	assert(nDims >= 2);
		
	SurfArray *Pyr_Subbands;
	int iLevel, *NDFB_levels;
	int PyrLevel = ReconstructionInfo.PyrLevel;

	try
	{
		Pyr_Subbands = new SurfArray [PyrLevel + 1];
		NDFB_levels = new int [nDims * nDims];

	}
	catch(std::bad_alloc)
	{
		MessageLog("SurfaceletFilterBank", "GetDecomposition", "Out of memory!");
		throw;
	}

	// Multidimensional multiscale pyramid decomposition
	pyr_fb.GetDecomposition(InArray, Pyr_Subbands, PyrLevel, true, 
		ReconstructionInfo.pyr_mode, ReconstructionInfo.func_type);

	// Copy lowpass array
    Pyr_Subbands[PyrLevel].GetInPlaceBackwardFFT();
	OutLowpassAray = Pyr_Subbands[PyrLevel];
	
	// Free memory space
	Pyr_Subbands[PyrLevel].Reset();

	// NDFB decomposition at each pyramid scale
	for (iLevel = 0; iLevel < PyrLevel; iLevel++)
	{
		// Prepare the output array
		OutHighpassArrays[iLevel] = new SurfArray * [nDims]; 
		
		// Get decomposition levels
		ReconstructionInfo.GetNdfbLevel(iLevel, NDFB_levels);

		// NDFB decomposition			
		NDFB_fb.GetDecomposition(Pyr_Subbands[iLevel], OutHighpassArrays[iLevel], false, NDFB_levels, ReconstructionInfo.Dec_filter0, ReconstructionInfo.Dec_center0, ReconstructionInfo.Dec_filter1, ReconstructionInfo.Dec_center1, 
			ReconstructionInfo.mSize, ReconstructionInfo.beta, ReconstructionInfo.lambda);

		// Free memory space
		Pyr_Subbands[iLevel].Reset();
	}

	delete [] NDFB_levels;
	delete [] Pyr_Subbands;

	return true;
}


//////////////////////////////////////////////////////////////////////////
//	Surfacelet filter bank reconstruction
//////////////////////////////////////////////////////////////////////////
//
//	PARAMETERS:
//
//	InHighpassArrays
//		The input highpass directional subbands
//
//	InLowpassArray
//		The lowpass subband
//
//	OutArray
//		The reconstructed array
//
//	ReconstructionInfo
//		Filter bank parameters

void SurfaceletFilterBank::GetReconstruction(SurfArray ***InHighpassArrays, SurfArray &InLowpassArray, 
	SurfArray &OutArray, SurfaceletRecInfo &ReconstructionInfo)
{
	int nDims = InHighpassArrays[0][0][0].GetRank();
	assert(nDims >= 2);

	SurfArray *Pyr_Subbands;
	int iLevel, *NDFB_levels;
	int PyrLevel = ReconstructionInfo.PyrLevel;

	try
	{
		Pyr_Subbands = new SurfArray [PyrLevel + 1];
		NDFB_levels = new int [nDims * nDims];

	}
	catch(std::bad_alloc)
	{
		MessageLog("SurfaceletFilterBank", "GetDecomposition", "Out of memory!");
		throw;
	}

	// NDFB reconstruction at each pyramid scale
	for (iLevel = 0; iLevel < PyrLevel; iLevel++)
	{
		// Get decomposition levels
		ReconstructionInfo.GetNdfbLevel(iLevel, NDFB_levels);

		NDFB_fb.GetReconstruction(InHighpassArrays[iLevel], Pyr_Subbands[iLevel], true, NDFB_levels,
			ReconstructionInfo.Rec_filter0, ReconstructionInfo.Rec_center0, ReconstructionInfo.Rec_filter1,
			ReconstructionInfo.Rec_center1);
		
	}

	// Copy the lowpass subband
	Pyr_Subbands[PyrLevel] = InLowpassArray;

	// Multidimensional multiscale pyramid decomposition
	pyr_fb.GetReconstruction(Pyr_Subbands, OutArray, PyrLevel, false, ReconstructionInfo.pyr_mode, ReconstructionInfo.func_type);
	
	delete [] NDFB_levels;
	delete [] Pyr_Subbands;

}


//////////////////////////////////////////////////////////////////////////
//	The adjoint operator of the forward surfacelet transform
//////////////////////////////////////////////////////////////////////////
//
//	PARAMETERS:
//
//	InHighpassArrays
//		The input highpass directional subbands
//
//	InLowpassArray
//		The lowpass subband
//
//	OutArray
//		The reconstructed array
//
//	ReconstructionInfo
//		Filter bank parameters

void SurfaceletFilterBank::GetAdjoint(SurfArray ***InHighpassArrays, SurfArray &InLowpassArray, 
											 SurfArray &OutArray, SurfaceletRecInfo &ReconstructionInfo)
{
	int nDims = InHighpassArrays[0][0][0].GetRank();
	assert(nDims >= 2);

	SurfArray *Pyr_Subbands;
	int iLevel, *NDFB_levels;
	int PyrLevel = ReconstructionInfo.PyrLevel;
	SurfMatrix filter0, filter1;
	int center0[2], center1[2];

	try
	{
		Pyr_Subbands = new SurfArray [PyrLevel + 1];
		NDFB_levels = new int [nDims * nDims];

	}
	catch(std::bad_alloc)
	{
		MessageLog("SurfaceletFilterBank", "GetDecomposition", "Out of memory!");
		throw;
	}

	// The filters for the adjoint operator are the time-reversed analysis filters
	filter0 = ReconstructionInfo.Dec_filter0;
	filter1 = ReconstructionInfo.Dec_filter1;

	// Flip the filters
	filter0.FlipLR();
	filter0.FlipUD();
	filter1.FlipLR();
	filter1.FlipUD();

	// Also change the centers of the filters
	center0[0] = filter0.nx - 1 - ReconstructionInfo.Dec_center0[0];
	center0[1] = filter0.ny - 1 - ReconstructionInfo.Dec_center0[1];
	center1[0] = filter1.nx - 1 - ReconstructionInfo.Dec_center1[0];
	center1[1] = filter1.ny - 1 - ReconstructionInfo.Dec_center1[1];


	// NDFB reconstruction at each pyramid scale
	for (iLevel = 0; iLevel < PyrLevel; iLevel++)
	{
		// Get decomposition levels
		ReconstructionInfo.GetNdfbLevel(iLevel, NDFB_levels);

		NDFB_fb.GetReconstruction(InHighpassArrays[iLevel], Pyr_Subbands[iLevel], true, NDFB_levels,
			filter0, center0, filter1, center1);

		// Some proper scaling
		Pyr_Subbands[iLevel].PointwiseMultiply((double)nDims);

	}

	// Copy the lowpass subband
	Pyr_Subbands[PyrLevel] = InLowpassArray;

	// Multidimensional multiscale pyramid decomposition
	pyr_fb.GetReconstruction(Pyr_Subbands, OutArray, PyrLevel, false, ReconstructionInfo.pyr_mode, ReconstructionInfo.func_type);

	delete [] NDFB_levels;
	delete [] Pyr_Subbands;

}


//////////////////////////////////////////////////////////////////////////
//	Convert the surfacelet coefficients to a linear vector
//////////////////////////////////////////////////////////////////////////
//
//	PARAMETERS:
//
//	HighpassArrays
//		The coefficients for the highpass directional subbands
//
//	LowpassArray
//		The coefficients for the lowpass subband
//
//	ReconInfo
//		The book keeping structure for the transform
//
//	LengthVector
//		The total number of elements in the linear vector
//
//	Output
//		Pointer to the memory block for the vector.
//		It is the caller's responsibility to free the memory space after use.

double* SurfaceletFilterBank::SurfaceletCoeff2Vec(SurfArray ***HighpassArrays, SurfArray &LowpassArray, SurfaceletRecInfo &ReconInfo, int &LengthVector)
{
	double *pVector;
	int nDims = LowpassArray.GetRank();
	int nElementSubband = LowpassArray.GetNumberOfElements();

	// First we need to know the total number of coefficients
	int nPyrLevels = ReconInfo.PyrLevel;
	
	int i, j, k;
		
	LengthVector = nElementSubband;
	nElementSubband *= nDims;

	for (i = nPyrLevels; i >= 1; i--)
	{
		if (i == 1)
		{
			switch (ReconInfo.pyr_mode)
			{
			case DOWNSAMPLE_1:
				// do nothing;
				break;
			
			case DOWNSAMPLE_15:

				nElementSubband = (int)(nElementSubband * pow(1.5, (double)nDims));
				break;
			
			case DOWNSAMPLE_2:
				nElementSubband *= (int)pow(2.0, (double)nDims);
				break;
			}
		}
		else
		{
			nElementSubband *= (int)pow(2.0, (double)nDims);
		}

		LengthVector += nElementSubband;
	}

	try
	{
		pVector = new double [LengthVector];
	}
	catch (std::bad_alloc)
	{
		MessageLog("SurfaceletFilterBank", "SurfaceletCoeff2Vec", "Out of memory!");
		throw;
	}
		
	// Now pull out the coefficients from the nested arrays
	int idx = 0;
	int nSubbands;
	int *pLevels0 = new int [nDims * nDims], *pLevels;
	for (i = 0; i < nPyrLevels; i++)
	{
		pLevels = pLevels0;
		ReconInfo.GetNdfbLevel(i, pLevels);
		for (j = 0; j < nDims; j++)
		{
			// get the number of directional subbands
			nSubbands = 1;
			for (k = 0; k < nDims; k++)
				nSubbands *= (k == j)? 1 : (int)pow(2.0, (double)pLevels[k]);

			for (k = 0; k < nSubbands; k++)
			{
				HighpassArrays[i][j][k].ExportRealValues(pVector + idx);
				idx += HighpassArrays[i][j][k].GetNumberOfElements();
			}

			pLevels += nDims;
		}
	}

	// And the lowpass subband
	LowpassArray.ExportRealValues(pVector + idx);
	idx += LowpassArray.GetNumberOfElements();

	assert(idx == LengthVector);

	delete [] pLevels0;

	return pVector;
}


//////////////////////////////////////////////////////////////////////////
//	Convert the surfacelet coefficients from a linear vector back to a nested array
//////////////////////////////////////////////////////////////////////////
//
//	PARAMETERS:
//
//	HighpassArrays
//		The coefficients for the highpass directional subbands
//
//	LowpassArray
//		The coefficients for the lowpass subband
//
//	ReconInfo
//		The book keeping structure for the transform
//
//	pVec
//		Pointer to the linear vector
//
//	LengthVector
//		The total number of elements in the linear vector
//
//	pDims
//		The dimensions of the input signal to the transform

void SurfaceletFilterBank::SurfaceletVec2Coeff(SurfArray*** &HighpassArrays, SurfArray &LowpassArray, SurfaceletRecInfo &ReconInfo, double *pVec, int LengthVector, int pDims[])
{
	int nDims = ReconInfo.nDims;
	int *pDimsSubband = new int [nDims];
	int *pDimsScale = new int [nDims];
	int *pLevels0 = new int [nDims * nDims], *pLevels;

	int i, j, k;
	int nSubbands, idx = 0;
	double df;

	memcpy(pDimsScale, pDims, nDims * sizeof(int));
		
	try
	{
		HighpassArrays = new SurfArray** [ReconInfo.PyrLevel];
		for (i = 0; i < ReconInfo.PyrLevel; i++)
		{
			HighpassArrays[i] = new SurfArray* [nDims];
			
			pLevels = pLevels0;
			ReconInfo.GetNdfbLevel(i, pLevels);

			for (j = 0; j < nDims; j++)
			{
				memcpy(pDimsSubband, pDimsScale, nDims * sizeof(int));
				nSubbands = 1;
				for (k = 0; k < nDims; k++)
				{
					if (k != j)
					{
						nSubbands *= (int)pow(2.0, (double)pLevels[k]);
						pDimsSubband[k] /= (int)pow(2.0, (double)pLevels[k]);
					}
				}
				HighpassArrays[i][j] = new SurfArray[nSubbands];

				for (k = 0; k < nSubbands; k++)
				{
					HighpassArrays[i][j][k].AllocateSpace(nDims, pDimsSubband);
					HighpassArrays[i][j][k].ImportRealValues(pVec + idx);
					idx += HighpassArrays[i][j][k].GetNumberOfElements();
				}

				pLevels += nDims;
			}

			if (i == 0)
			{
				switch (ReconInfo.pyr_mode)
				{
				case DOWNSAMPLE_1:
					df = 1.0;
					break;

				case DOWNSAMPLE_15:

					df = 1.5;
					break;

				case DOWNSAMPLE_2:
					// the same as nElementSubband *= (int)pow(2.0, nDims);
					df = 2.0;
					break;
				}
			}
			else
			{
				df = 2.0;
			}

			for (j = 0; j < nDims; j++)
				pDimsScale[j] = (int)(pDimsScale[j] / df);
		}

		LowpassArray.AllocateSpace(nDims, pDimsScale);
		LowpassArray.ImportRealValues(pVec + idx);
		idx += LowpassArray.GetNumberOfElements();

		assert(idx == LengthVector);
	}
	catch (std::bad_alloc)
	{
		MessageLog("SurfaceletFilterBank", "SurfaceletVec2Coeff", "Out of memory!");
		delete [] pDimsSubband;
		delete [] pDimsScale;
		delete [] pLevels0;
		throw;
	}

	delete [] pDimsSubband;
	delete [] pDimsScale;
	delete [] pLevels0;
}


//////////////////////////////////////////////////////////////////////////
//	Check the validity of the decomposition parameters
//////////////////////////////////////////////////////////////////////////
//
//  PARAMETERS:
//
//  InArray
//      The input multidimensional array.
//
//  ReconstructionInfo
//      Decomposition and reconstruction parameters for the surfacelet filter bank
//
//  Return Value
//      False if the parameters are not yet supported by the current implementation.
//
//  NOTE:
//


bool SurfaceletFilterBank::CheckParameters(SurfArray &InArray, SurfaceletRecInfo &ReconstructionInfo)
{
	int nDims = InArray.GetRank();

	if (nDims < 2)
	{
		MessageLog("SurfaceletFilterBank", "CheckParameters", "The input array must be multidimensional.");
		return false;
	}

	if (ReconstructionInfo.PyrLevel < 1)
	{
		MessageLog("SurfaceletFilterBank", "CheckParameters", "The levels of pyramid decomposition must be at least one.");
		return false;
	}

	bool IsValid = true;

	int *pDims, *pLevels;

	pDims = new int [nDims];
	pLevels = new int [nDims * nDims];

	InArray.GetDims(pDims);

	int i, j, downsample_factor, iLevel, Level, subband_nx, max_shiftingfactor, filter_ny, max_filter_ny;
	
	for (iLevel = 0; iLevel < ReconstructionInfo.PyrLevel; iLevel++)
	{
		// Get the NDFB decomposition levels
		ReconstructionInfo.GetNdfbLevel(iLevel, pLevels);

        // Check conditions for the hourglass filter bank
        for (i = 0; i < nDims; i++)
        {
            if (pDims[i] < 2 * ReconstructionInfo.mSize - 1)
            {
                MessageLog("SurfaceletFilterBank", "CheckParameters", "The dimensions of the array is smaller than 2 * mSize - 1. Try reducing mSize.");
                IsValid = false;
                break;
            }
        }

        if (!IsValid) break;

		for (i = 0; i < nDims; i++)
		{
			if (pLevels[i * nDims + i] != -1)
			{
				MessageLog("SurfaceletFilterBank", "CheckParameters", "The diagonal elements of the NDFB level matrices must be -1.");
				IsValid = false;
				break;
			}

			for (j = 0; j < nDims; j++)
			{
				if (i == j) continue;

				if ((Level = pLevels[i * nDims + j]) < 0)
				{
					MessageLog("SurfaceletFilterBank", "CheckParameters", "The off-diagonal elements of the NDFB level matrices must be nonnegative.");
					IsValid = false;
					break;
				}

				if (Level == 0) continue;

				Level = (int)pow(2.0, Level - 1);

				max_shiftingfactor = Level - 1;
				max_filter_ny = -1;

				filter_ny = ReconstructionInfo.Dec_filter0.ny + (ReconstructionInfo.Dec_filter0.nx - 1) * max_shiftingfactor;
				if (filter_ny > max_filter_ny)
					max_filter_ny = filter_ny;

				filter_ny = ReconstructionInfo.Dec_filter1.ny + (ReconstructionInfo.Dec_filter1.nx - 1) * max_shiftingfactor;
				if (filter_ny > max_filter_ny)
					max_filter_ny = filter_ny;

				filter_ny = ReconstructionInfo.Rec_filter0.ny + (ReconstructionInfo.Rec_filter0.nx - 1) * max_shiftingfactor;
				if (filter_ny > max_filter_ny)
					max_filter_ny = filter_ny;

				filter_ny = ReconstructionInfo.Rec_filter1.ny + (ReconstructionInfo.Rec_filter1.nx - 1) * max_shiftingfactor;
				if (filter_ny > max_filter_ny)
					max_filter_ny = filter_ny;

				if (pDims[i] < max_filter_ny)
				{
					MessageLog("SurfaceletFilterBank", "CheckParameters", "The resampled (sheared) filter size if larger than the downsampled array size.");
					IsValid = false;
					break;
				}


				if (pDims[j] % (Level * 2))
				{
					MessageLog("SurfaceletFilterBank", "CheckParameters", "The downsampling factor of the multidimensional pyramid must be able to divide the dimensions of the input array");
					IsValid = false;
					break;
				}
				
				subband_nx = pDims[j] / Level;

				if ((subband_nx < ReconstructionInfo.Dec_filter0.nx) || (subband_nx < ReconstructionInfo.Dec_filter1.nx)
					|| (subband_nx < ReconstructionInfo.Rec_filter0.nx) || (subband_nx < ReconstructionInfo.Rec_filter1.nx))
				{
					MessageLog("SurfaceletFilterBank", "CheckParameters", "The checkerboard filter size is larger than the downsampled subband size. Try reducing the level of decompositions or bo.");
					IsValid = false;
					break;
				}

			}

			if (!IsValid) break;
		}


		// Update the dimensions according to the downsample operations in the pyramid decomposition
		switch (ReconstructionInfo.pyr_mode)
		{
		case DOWNSAMPLE_1:
			
			downsample_factor = (iLevel == 0)? 1 : 2;
			break;

		case DOWNSAMPLE_15:
			
			downsample_factor = (iLevel == 0)? 3 : 2;
			break;

		case DOWNSAMPLE_2:

			downsample_factor = 2;
			break;

		default:
			assert(false);
		}

		for (i = 0; i < nDims; i++)
		{
			if (pDims[i] % downsample_factor)
			{
				MessageLog("SurfaceletFilterBank", "CheckParameters", "The downsampling factor of the multidimensional pyramid must be able to divide the dimensions of the input array");
				IsValid = false;
				break;
			}
			else
				pDims[i] /= downsample_factor;

			if ((iLevel == 0) && (ReconstructionInfo.pyr_mode == DOWNSAMPLE_15))
				pDims[i] *= 2;
		}

		if (!IsValid) break;

	}
	
	delete [] pLevels;
	delete [] pDims;

	return IsValid;

}


//	This software is provided "as-is", without any express or implied
//	warranty. In no event will the authors be held liable for any 
//	damages arising from the use of this software.
