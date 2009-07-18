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
//	NdDirectionalFilterBank.h
//	
//	First created: 04-02-06
//	Last modified: 04-10-06
//
//////////////////////////////////////////////////////////////////////////

#ifndef ND_DIRECTIONAL_FILTER_BANK
#define ND_DIRECTIONAL_FILTER_BANK

#include <sstream>
#include "SurfMatrix.h"
#include "SurfArray.h"
#include "HourglassFilterBank.h"

// Routines for NDFB decomposition and reconstruction

class NdDirectionalFilterBank
{
public:
	//	Constructor
	NdDirectionalFilterBank(void);
	
	//	Destructor
	~NdDirectionalFilterBank(void);
	
	//  NDFB Decomposition
	void GetDecomposition(SurfArray &InArray, SurfArray *OutArrays[], bool OutputInFourierDomain, 
        int Levels[], SurfMatrix &filter0, int center0[], SurfMatrix &filter1, int center1[], int mSize = 15, double beta = 2.5, double lambda = 4.0);

	//	NDFB Reconstruction
    void GetReconstruction(SurfArray *InArrays[], SurfArray &OutArray, bool OutputInFourierDomain,
        int Levels[], SurfMatrix &filter0, int center0[], SurfMatrix &filter1, int center1[], int mSize = 15, double beta = 2.5, double lambda = 4.0);
	
	//	Read the checkerboard filter bank coefficients from files
	void GetCheckerboardFilters(int bo, bool IsDecomposition, SurfMatrix &filter0,
		int center1[2], SurfMatrix& filter1, int center2[2], string& dir_info);

private:
	//	Iteratively resampled checkerboard filter bank decomposition
    void IrcDecomposition(int nDims, int pDims[], double *pData, int dim_axis, int full_dim, int levels[],
		SurfMatrix &filter0, int center0[], SurfMatrix &filter1, int center1[]);
	
	//	Iteratively resampled checkerboard filter bank reconstruction
    void IrcReconstruction(int nDims, int pDims[], double *pData, int dim_axis, int full_dim, int levels[],
		SurfMatrix &filter0, int center0[], SurfMatrix &filter1, int center1[]);

	//	Filtering followed by downsampling
	void FilterDownsampleF(int nDims, int pDims[], double *pData, int K, int M, int Level);

	//	Filtering followed by upsampling
	void FilterUpsampleF(int nDims, int pDims[], double *pData, int K, int M, int Level);

	//  Extract an N-D array into a list of sub-arrays
	void BoxToCell(int nDims, int pDims[], double *pInData, SurfArray pSubbands[], int levels[], int dim_axis, int full_dim);

	//  Combine a list of small arrays into a larger one
	double *CellToBox(SurfArray pSubbands[], int dim_axis, int levels[]);

	//	Obtain the 2-D slice containing the frequency values of the irc filters
	void GetIrcFilterSlices(int dim_K, int dim_M, int nLevel, SurfMatrix &filter, int center[],
		SurfMatrix &FilterSlice);
	
	//	Used for hourglass filter bank decomposition and reconstruction
    HourglassFilterBank hourglass_fb;

    //  Used for 2-D filtering (IRCFB)
    SurfMatrix FilterSlice0, FilterSlice1;
};

#endif

//	This software is provided "as-is", without any express or implied
//	warranty. In no event will the authors be held liable for any 
//	damages arising from the use of this software.