//////////////////////////////////////////////////////////////////////////
//	SurfBox C++ (c)
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
//	SurfMatrix.h
//	
//	First created: 03-22-06
//	Last modified: 04-10-06
//
//////////////////////////////////////////////////////////////////////////

#ifndef SURF_MATRIX_HEADER
#define SURF_MATRIX_HEADER

#include <memory>
using namespace std;

// A simple class for real-valued matrices
class SurfMatrix
{
public:
	SurfMatrix(void);
	~SurfMatrix(void);

    // Allocate memory space
	void AllocateSpace(int nx /*rows*/, int ny /*columns*/);
	
    // Get the pointer to the data
    double *GetPointer();
    
    // Transpose the current matrix (in-place version);
	void Transpose(bool IsRealValued = true);

	// Flip the matrix along the rows (in-place version);
	void FlipLR();

	// Flip the matrix along the columns (in-place version);
	void FlipUD();

    // Resample the matrix along the rows
    void ResampleRow(int shift);
    
    // Circularly shift the current matrix along the rows
    void CircularShift(int shift0, int shift1);

	//	Fill the current matrix with 0
	void ZeroFill();

	//	Release the memory resources
    void Reset();

	//	Fill the current matrix with a smaller matrix
	void FillSubMatrixF(SurfMatrix &SubMatrix, bool IsFromLeft);

	//	Fill the current matrix with a smaller matrix
	void FillSubMatrix(SurfMatrix &SubMatrix, int x0, int y0);

	//	Raising the elements of the current matrix to the power of lambda
    SurfMatrix& operator ^ (const double lambda);

	//	Copy two matrices. The new matrix will have its own memory space
	SurfMatrix& operator = (const SurfMatrix&);

    // Rows
    int nx;
    // Columns
    int ny;

private:
    // pointer for the data
	double* ptr;
};


#endif

//	This software is provided "as-is", without any express or implied
//	warranty. In no event will the authors be held liable for any 
//	damages arising from the use of this software.