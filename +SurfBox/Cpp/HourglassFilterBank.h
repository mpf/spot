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
//	HourglassFilterBank.h
//
//	Implementation of the hourglass filter bank
//	
//	First created: 02-28-06
//	Last modified: 04-15-06
//
//////////////////////////////////////////////////////////////////////////

#ifndef HOURGLASS_FILTER_BANK_HEADER
#define HOURGLASS_FILTER_BANK_HEADER

#include "SurfArray.h"
#include "SurfMatrix.h"


class HourglassFilterBank
{
public:
	HourglassFilterBank(void);
	~HourglassFilterBank(void);

	//	Hourglass Filter Bank Decomposition
	void GetDecomposition(SurfArray &InArray, SurfArray OutArrays[], bool OutputInFourierDomain,
		int mSize = 15, double beta = 2.5, double lambda = 4.0);

	//	Hourglass Filter Bank Reconstruction
	void GetReconstruction(SurfArray InArrays[], SurfArray& OutArray, 
		bool OutputInFourierDomain, int mSize = 15, double beta = 2.5, double lambda = 4.0);

private:
    // Filtering operation for the decomposition step.
	void DecompositionFiltering(int nDims, int* pDims, double *pDataIn, double *pDataOut[], 
		SurfMatrix *pHourglass[]);

    // Filtering operation for the reconstruction step.
    void ReconstructionFiltering(int nDims, int* pDims, double *pDataIn[], double *pDataOut, 
        SurfMatrix *pHourglass[]);

    // Get hourglass filters at all possible 2-D planes.
    void GetHourglassFilters(int nDims, int *pDims, SurfMatrix *pMappingMatrix,
		SurfMatrix *pHourglassFilters[], double lambda);

	// Get the mapping kernel for the fan-shaped frequency response
	void GetDiamondMapping(int nOrder, double beta, SurfMatrix *pMappingMatrix);

	// Get the N-point Kaiser window
	void GetKaiserWindow(int nOrder, double beta, double* pWin);

	// Calculate the 0th-order modified Bessel function I_0(x)
	double CalculateI0(double x);

	// Calculate the sinc function y = sinc(x) = sin(\pi x) / (\pi x)
	double Sinc(double x);
	
};

#endif

//	This software is provided "as-is", without any express or implied
//	warranty. In no event will the authors be held liable for any 
//	damages arising from the use of this software.