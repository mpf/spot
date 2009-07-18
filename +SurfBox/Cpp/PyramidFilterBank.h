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
//	PyramidFilterBank.h
//	
//	First created: 03-27-06
//	Last modified: 04-10-06
//
//////////////////////////////////////////////////////////////////////////

#ifndef PYRAMID_FILTER_BANK
#define PYRAMID_FILTER_BANK

#include "SurfArray.h"


// Three types of multiscale pyramid, each corresponding to a different redundancy ratio
enum Pyramid_Mode
{
	DOWNSAMPLE_1, // Most redundant, best quality
	DOWNSAMPLE_15, 
	DOWNSAMPLE_2, // Least redundant
} ;

// Smooth functions used in specifying the lowpass filters in the frequency domain
// These two are very similar in performance

enum SmoothFunctionType
{
	RAISED_COSINE,
	MEYER_VKBOOK,
};

//////////////////////////////////////////////////////////////////////////
//  Multidimensional multiscale pyramid
//////////////////////////////////////////////////////////////////////////

class PyramidFilterBank
{
public:
	PyramidFilterBank(void);
	~PyramidFilterBank(void);

	// Multidimensional multiscale pyramid decomposition
	void GetDecomposition(SurfArray &InArray, SurfArray OutArrays[], 
		int Level, bool OutputInFourierDomain, enum Pyramid_Mode pyr_mode, enum SmoothFunctionType func_type);
	
    // Multidimensional multiscale pyramid reconstruction
    void GetReconstruction(SurfArray InArrays[], SurfArray &OutArray, 
		int Level, bool OutputInFourierDomain, Pyramid_Mode pyr_mode, SmoothFunctionType func_type);

private:
    // One level of decomposition in the multidimensional multiscale pyramid	
    void DecompositionOneStep(SurfArray &InArray, SurfArray &LowpassArray, SurfArray &HighpassArray,
		double w, double tbw, double D, SmoothFunctionType func_type);
	
    // One level of reconstruction in the multidimensional multiscale pyramid
    void ReconstructionOneStep(SurfArray &LowpassArray, SurfArray &HighpassArray, SurfArray &OutArray,
		double w, double tbw, double D, SmoothFunctionType func_type);

    // Obtain the parameters for pyramid decomposition at different levels
	void GetPyramidParameters(enum Pyramid_Mode pyr_mode, int Levels, double w_array[], 
		double tbw_array[], double D_array[]);
    
    // raised cosine
	double rcos(double x);

    // Meyer filter from the VK book
	double Meyer_vkbook(double x);

    // Calculate the 1-D lowpass filters
    void CalculateFilterValues1D(double *pValues, int dim, double w, double tbw, bool UseSymmExt, enum SmoothFunctionType func_type);

};

#endif

//	This software is provided "as-is", without any express or implied
//	warranty. In no event will the authors be held liable for any 
//	damages arising from the use of this software.