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
//	SurfaceletFilterBank.h
//	
//	First created: 04-02-06
//	Last modified: 04-14-06
//
//////////////////////////////////////////////////////////////////////////

#ifndef SURFACELET_FILTER_BANK
#define SURFACELET_FILTER_BANK

#include <sstream>
#include "SurfArray.h"
#include "PyramidFilterBank.h"
#include "NdDirectionalFilterBank.h"


// Reconstruction Information

class SurfaceletRecInfo
{
public:
	SurfaceletRecInfo();
	~SurfaceletRecInfo();

	//	Set decomposition and reconstruction parameters
	void SetParameters(int nDims_, int bo_, int mSize_, double beta_, double lambda_, int PyrLevel_, enum Pyramid_Mode pyr_mode_, enum SmoothFunctionType func_type_, string& dir_info);
	
	//	Set decomposition and reconstruction parameters (without reading the filter coefficients)
	void SetParameters(int nDims_, int mSize_, double beta_, double lambda_, int PyrLevel_, enum Pyramid_Mode pyr_mode_, enum SmoothFunctionType func_type_);

	//	Get the decomposition level info at a certain scale
	void GetNdfbLevel(int scale, int Level[]) const;

	//	Set the decomposition level info at a certain scale
	void SetNdfbLevel(int scale, int Level[]);

	//	Directly set the checkerboard filters
	void SetFilters(double *pFilter0, int pDims0[], int center0[], 
		double *pFilter1, int pDims1[], int center1[], double *pFilter2, int pDims2[], int center2[],
		double *pFilter3, int pDims3[], int center3[]);

	enum Pyramid_Mode pyr_mode;
	enum SmoothFunctionType func_type;
	int bo;
	int mSize;
	double beta;
	double lambda;
	int PyrLevel;
	int **NdfbLevels;
	int nDims;

	SurfMatrix Dec_filter0, Dec_filter1;
	int Dec_center0[2], Dec_center1[2];

	SurfMatrix Rec_filter0, Rec_filter1;
	int Rec_center0[2], Rec_center1[2];

private:
	NdDirectionalFilterBank ndfb_fb;
};


class SurfaceletFilterBank
{
public:
	SurfaceletFilterBank();
	~SurfaceletFilterBank();

    // Surfacelet decomposition
	bool GetDecomposition(SurfArray &InArray, SurfArray **OutHighpassArrays[], SurfArray &OutLowpassArray, SurfaceletRecInfo &ReconstructionInfo);
	
    // Surfacelet reconstruction
    void GetReconstruction(SurfArray ***InHighpassArrays, SurfArray &InLowpassArray, SurfArray &OutArray, SurfaceletRecInfo &ReconstructionInfo);

	// Adjoint operator of the forward transform
	void GetAdjoint(SurfArray ***InHighpassArrays, SurfArray &InLowpassArray, SurfArray &OutArray, SurfaceletRecInfo &ReconstructionInfo);

	// Convert the surfacelet coefficients to a linear vector
	double* SurfaceletCoeff2Vec(SurfArray ***HighpassArrays, SurfArray &LowpassArray, SurfaceletRecInfo &ReconstructionInfo, int &LengthVector);

	// Convert the surfacelet coefficients from a linear vector back to nested arrays
	void SurfaceletVec2Coeff(SurfArray*** &HighpassArrays, SurfArray &LowpassArray, SurfaceletRecInfo &ReconstructionInfo, double *vec, int LengthVector, int pDims[]);

private:
    // Check the validity of the decomposition parameters
	bool CheckParameters(SurfArray &InArray, SurfaceletRecInfo &ReconstructionInfo);

    // Multidimensional multiscale pyramid
	PyramidFilterBank	pyr_fb;

    // Multidimensional directional filter bank
	NdDirectionalFilterBank NDFB_fb;
};

//	This software is provided "as-is", without any express or implied
//	warranty. In no event will the authors be held liable for any 
//	damages arising from the use of this software.

#endif