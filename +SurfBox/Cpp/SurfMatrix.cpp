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
//	SurfMatrix.cpp
//	
//	First created: 03-22-06
//	Last modified: 04-10-06
//
//////////////////////////////////////////////////////////////////////////

#include "SurfMatrix.h"
#include <cassert>
#include "math.h"

extern void MessageLog(const char*, const char*, const char*);


//////////////////////////////////////////////////////////////////////////
//	Constructor
//////////////////////////////////////////////////////////////////////////

SurfMatrix::SurfMatrix(void)
{
	nx = ny = 0;
	ptr = NULL;
}


//////////////////////////////////////////////////////////////////////////
//	Destructor
//////////////////////////////////////////////////////////////////////////

SurfMatrix::~SurfMatrix(void)
{
	if (ptr) delete [] ptr;
}


//////////////////////////////////////////////////////////////////////////
//	Allocate the required memory space
//////////////////////////////////////////////////////////////////////////
//
//	PARAMETERS:
//
//	nx_in
//		The number of rows
//
//	ny_in
//		The number of columns

void SurfMatrix::AllocateSpace(int nx_in, int ny_in)
{
	nx = nx_in;
	ny = ny_in;

    assert((nx > 0) && (ny > 0));

	if (ptr) delete [] ptr;

    try
    {
       ptr = new double [nx * ny];
    }
    catch (std::bad_alloc)
    {
        MessageLog("SurfMatrix", "Allocate Space", "Out of memory!");
        throw;
    }    
}


//////////////////////////////////////////////////////////////////////////
//  Transpose the current matrix (in-place version)
//////////////////////////////////////////////////////////////////////////
//
//  PARAMETERS:
//
//  IsRealValued
//      true: assume the matrix is real-valued
//      false: assume the matrix is complex-valued

void SurfMatrix::Transpose(bool IsRealValued /* = true */)
{
	if (!IsRealValued)
    {
        // storage: real | imag | real | imag ...
        assert(ny % 2 == 0);
    }   
    
    register int i, j;
    double *dst, *src;
    int tmp;

    try
    {
        // Get some temporary space
		double *tmp_ptr = new double [nx * ny];

        if (IsRealValued)
        {
            dst = tmp_ptr;
            // Transpose
            for (i = 0; i < ny; i++)
            {
                src = ptr + i;
                for (j = 0; j < nx; j++)
                {
                    *(dst++) = *src;
                    src += ny;
                }	
            }

            // Swap the dimensions
            tmp = ny;
            ny = nx;
            nx = tmp;
        } // real-valued
        else
        {
            dst = tmp_ptr;
            for (i = 0; i < ny / 2; i++)
            {
                src = ptr + i * 2;
                for (j = 0; j < nx; j++)
                {
                    *(dst++) = *src;
                    *(dst++) = *(src+1);
                    src += ny;
                }
            }
            tmp = ny;
            ny = nx * 2;
            nx = tmp / 2;
            
        } // complex valued
        
        // Copy the results
        memcpy(ptr, tmp_ptr, nx * ny * sizeof(double));

        // free temporary memory space
		delete [] tmp_ptr;
    }
    catch (std::bad_alloc)
    {
        MessageLog("SurfMatrix", "Transpose", "Out of memory!");
        throw;
    }
}


//////////////////////////////////////////////////////////////////////////
//  Flip the matrix along the rows (in-place version)
//////////////////////////////////////////////////////////////////////////

void SurfMatrix::FlipLR()
{
	register int i, j;
	double *src, *dst, temp;

	src = ptr;
	dst = src + nx - 1;

	for (i = 0; i < ny; i++)
	{
		for (j = 0; j < nx / 2; j++)
		{
			// Swap the values
			temp = *dst;
			*dst = *src;
			*src = temp;

			// Work towards the center
			src++; dst--;
		}

		src += nx - nx / 2;
		dst = src + nx - 1;
	}
}


//////////////////////////////////////////////////////////////////////////
//  Flip the matrix along the columns (in-place version)
//////////////////////////////////////////////////////////////////////////

void SurfMatrix::FlipUD()
{
	register int i, j;
	double *src, *dst, temp;

	for (i = 0; i < ny / 2; i++)
	{
		src = ptr + i * nx;
		dst = ptr + (ny - 1 - i) * nx;

		for (j = 0; j < nx; j++)
		{
			// Swap the values
			temp = *dst;
			*dst = *src;
			*src = temp;

			src++; dst++;
		}
	}
}


//////////////////////////////////////////////////////////////////////////
//	Get the data pointer
//////////////////////////////////////////////////////////////////////////

double* SurfMatrix::GetPointer()
{
    return ptr;
}


//////////////////////////////////////////////////////////////////////////
//	Circularly shift the matrix
//////////////////////////////////////////////////////////////////////////
//
//	PARAMETERS:
//
//	shift0
//		Shift amount along the x direction. Positive: towards the bottom. Negative: towards the top
//
//	shift1
//		Shift amount along the y direction. Positive: towards the right. Negative: towards the left

void SurfMatrix::CircularShift(int shift0, int shift1)
{
    assert(ptr);
    assert((nx > 0) && (ny > 0));

    register int i;
    double *pData;

	shift0 %= nx;
	if (shift0 < 0) shift0 += nx;

    shift1 %= ny;
    // Always shift towards the right
    if (shift1 < 0) shift1 += ny;
    
	try
	{
		double *pBuffer;
		if (shift1)
		{
	       
			// get some temporary space
			pBuffer = new double [ny];
			pData = ptr;
			for (i = 0; i < nx; i++)
			{
				// shifting by memory copying
				memcpy(pBuffer, pData + ny - shift1, shift1 * sizeof(double));
				memcpy(pBuffer + shift1, pData, (ny - shift1) * sizeof(double));
				memcpy(pData, pBuffer, ny * sizeof(double));
				pData += ny;
			}

			delete [] pBuffer;
		}
		if (shift0)
		{
			pBuffer = new double [nx * ny];
			memcpy(pBuffer, ptr + ny * (nx - shift0), ny * shift0 * sizeof(double));
			memcpy(pBuffer + ny * shift0, ptr, ny * (nx - shift0) * sizeof(double));
			memcpy(ptr, pBuffer, nx * ny * sizeof(double));

			delete [] pBuffer;
		}

	}
	catch (std::bad_alloc)
	{
		MessageLog("SurfMatrix", "CircularShift", "Out of memory!");
		throw;
	}
}


//////////////////////////////////////////////////////////////////////////
//	Release the memory resources
//////////////////////////////////////////////////////////////////////////

void SurfMatrix::Reset()
{
    if (ptr) delete [] ptr;
    ptr = NULL;
    nx = ny = 0;
}


//////////////////////////////////////////////////////////////////////////
//	Fill the current matrix with a smaller matrix
//////////////////////////////////////////////////////////////////////////
//
//	PARAMETERS:
//
//	SubMatrix
//		A matrix smaller than the current one
//
//	x0
//		The beginning row of the smaller matrix in the current matrix
//
//	y0
//		The beginning column of the smaller matrix in the current matrix

void SurfMatrix::FillSubMatrix(SurfMatrix &SubMatrix, int x0, int y0)
{
	assert((x0 >= 0) && (x0 + SubMatrix.nx <= nx) && (y0 >= 0) && (y0 + SubMatrix.ny <= ny));

	double *src, *dst;

	src = SubMatrix.GetPointer();
	dst = ptr + x0 * ny + y0;

	int dx_sub = SubMatrix.nx;
	int dy_sub = SubMatrix.ny;

	for (register int i = 0; i < dx_sub; i++)
	{
		memcpy(dst, src, dy_sub * sizeof(double));
		dst += ny;
		src += dy_sub;
	}
}


//////////////////////////////////////////////////////////////////////////
//	Fill the current matrix with a smaller matrix
//////////////////////////////////////////////////////////////////////////
//
//	This is a special case of FillSubMatrix

void SurfMatrix::FillSubMatrixF(SurfMatrix &SubMatrix, bool IsFromLeft)
{
	assert((nx >= SubMatrix.nx) && (ny >= 2 * SubMatrix.ny) && (ny % 2 == 0));

	memset(ptr, 0, nx * ny * sizeof(double));

	int nx_sub = SubMatrix.nx;
	int ny_sub = SubMatrix.ny;
	int skip_beginning = (IsFromLeft)? 0 : (ny - ny_sub * 2);
	int skip_end = (IsFromLeft)? (ny - ny_sub * 2) : 0;

    register int i;
	register int j;
	
	double *dst, *src;
	dst = ptr;
	src = SubMatrix.GetPointer();
	for (j = 0; j < nx_sub; j++)
	{
		dst += skip_beginning;
		for (i = 0; i < ny_sub; i++)
		{
			*dst = *(src++);
			dst += 2;
		}
		dst += skip_end;
	}
}


//////////////////////////////////////////////////////////////////////////
//	Resample the current matrix along the rows
//////////////////////////////////////////////////////////////////////////
//
//	PARAMETERS:
//	
//	shift
//		y_new = y_old + shift * x_old

void SurfMatrix::ResampleRow(int shift)
{
    assert(ptr);
    assert((nx > 0) && (ny > 0));

    register int i;
    double *pData;
    int s;

    if (shift)
    {
        try
        {
            // get some temporary space
            double *pBuffer = new double [ny];
            pData = ptr;
            for (i = 0; i < nx; i++)
            {
                s = (shift * i) % ny;
                // Always shift towards the right
                if (s < 0) s += ny;
                
                if (s)
                {
                    // shifting by memory copying
                    memcpy(pBuffer, pData + ny - s, s * sizeof(double));
                    memcpy(pBuffer + s, pData, (ny - s) * sizeof(double));
                    memcpy(pData, pBuffer, ny * sizeof(double));
                }
                pData += ny;
            }

            delete [] pBuffer;
        }
        catch (std::bad_alloc)
        {
            MessageLog("SurfMatrix", "CircularShift", "Out of memory!");
            throw;
        }
    }
}


//////////////////////////////////////////////////////////////////////////
//	Raising the elements of the current matrix to the power of lambda
//////////////////////////////////////////////////////////////////////////

SurfMatrix& SurfMatrix::operator ^ (const double lambda)
{
    int n_total_points = nx * ny;
    double *pD = ptr;
    for (register int i = 0; i < n_total_points; i++)
    {
        *pD = pow(*pD, lambda);
        pD++;
    }

    return *this;
}


//////////////////////////////////////////////////////////////////////////
//	Fill the current matrix with 0
//////////////////////////////////////////////////////////////////////////

void SurfMatrix::ZeroFill()
{
	assert(ptr);

	memset(ptr, 0, nx * ny * sizeof(double));
}


//////////////////////////////////////////////////////////////////////////
//	Copy two matrices. The new matrix will have its own memory space
//////////////////////////////////////////////////////////////////////////
//	
//	PARAMETERS:
//
//	Src
//		The matrix to be copied

SurfMatrix& SurfMatrix::operator = (const SurfMatrix& Src)
{
	try
	{
		AllocateSpace(Src.nx, Src.ny);
	}
	catch (std::bad_alloc)
	{
		MessageLog("SurfMatrix", "Operator =", "Out of memory");
		throw;
	}
	
	memcpy(ptr, Src.ptr, nx * ny * sizeof(double));
	return *this;
}


//	This software is provided "as-is", without any express or implied
//	warranty. In no event will the authors be held liable for any 
//	damages arising from the use of this software.