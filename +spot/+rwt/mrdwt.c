/*
File Name: MRDWT.c
Last Modification Date:	09/21/95	15:42:59
Current Version: MRDWT.c	2.4
File Creation Date: Wed Oct 12 08:44:43 1994
Author: Markus Lang  <lang@jazz.rice.edu>

Copyright (c) 2000 RICE UNIVERSITY. All rights reserved.
Created by Markus Lang, Department of ECE, Rice University. 

This software is distributed and licensed to you on a non-exclusive 
basis, free-of-charge. Redistribution and use in source and binary forms, 
with or without modification, are permitted provided that the following 
conditions are met:

1. Redistribution of source code must retain the above copyright notice, 
   this list of conditions and the following disclaimer.
2. Redistribution in binary form must reproduce the above copyright notice, 
   this list of conditions and the following disclaimer in the 
   documentation and/or other materials provided with the distribution.
3. All advertising materials mentioning features or use of this software 
   must display the following acknowledgment: This product includes 
   software developed by Rice University, Houston, Texas and its contributors.
4. Neither the name of the University nor the names of its contributors 
   may be used to endorse or promote products derived from this software 
   without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY WILLIAM MARSH RICE UNIVERSITY, HOUSTON, TEXAS, 
AND CONTRIBUTORS AS IS AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, 
BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS 
FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL RICE UNIVERSITY 
OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, 
PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; 
OR BUSINESS INTERRUPTIONS) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR 
OTHERWISE), PRODUCT LIABILITY, OR OTHERWISE ARISING IN ANY WAY OUT OF THE 
USE OF THIS SOFTWARE,  EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

For information on commercial licenses, contact Rice University's Office of 
Technology Transfer at techtran@rice.edu or (713) 348-6173

Change History: Fixed the code such that 1D vectors passed to it can be in
                either passed as a row or column vector. Also took care of 
		the code such that it will compile with both under standard
		C compilers as well as for ANSI C compilers
		Jan Erik Odegard <odegard@ece.rice.edu> Wed Jun 14 1995

MATLAB description:
%[yl,yh] = mrdwt(x,h,L);
% 
% function computes the redundant discrete wavelet transform y for a 1D or
% 2D input signal . redundant means here that the subsampling after each
% stage is omitted. yl contains the lowpass and yl the highpass
% components. In case of a 2D signal the ordering in yh is [lh hl hh lh hl
% ... ] (first letter refers to row, second to column filtering). 
%
%    Input:
%	x    : finite length 1D or 2D signal (implicitely periodized)
%       h    : scaling filter
%       L    : number of levels. in case of a 1D signal length(x) must be
%              divisible by 2^L; in case of a 2D signal the row and the
%              column dimension must be divisible by 2^L.
%   
%    Output:
%       yl   : lowpass component
%       yh   : highpass components
%
% see also: mdwt, midwt, mirdwt


*/

#include <math.h>
#include <stdio.h>
#include <inttypes.h>
#include "mex.h"
#include "matrix.h"


#define max(A,B) (A > B ? A : B)
#define min(A,B) (A < B ? A : B)
#define even(x)  ((x & 1) ? 0 : 1)
#define isint(x) ((x - floor(x)) > 0.0 ? 0 : 1)
#define mat(a, i, j) (*(a + (m*(j)+i))) 

MRDWT(double *x, intptr_t m, intptr_t n, double *h, intptr_t lh, intptr_t L,
      double *yl, double *yh)
{
  double  *h0, *h1, *ydummyll, *ydummylh, *ydummyhl;
  double *ydummyhh, *xdummyl , *xdummyh;
  intptr_t i, ir, ic, actual_m, actual_n, sample_f, c_o_a, n_c, n_cb, n_r, n_rb, c_o_a_p2n, actual_L;

  xdummyl = (double *)mxCalloc(max(m,n)+lh-1,sizeof(double));
  xdummyh = (double *)mxCalloc(max(m,n)+lh-1,sizeof(double));
  ydummyll = (double *)mxCalloc(max(m,n),sizeof(double));
  ydummylh = (double *)mxCalloc(max(m,n),sizeof(double));
  ydummyhl = (double *)mxCalloc(max(m,n),sizeof(double));
  ydummyhh = (double *)mxCalloc(max(m,n),sizeof(double));
  h0 = (double *)mxCalloc(lh,sizeof(double));
  h1 = (double *)mxCalloc(lh,sizeof(double));

  if (n==1){
    n = m;
    m = 1;
  }  
  /* analysis lowpass and highpass */
  for (i=0; i<lh; i++){
    h0[i] = h[lh-i-1];
    h1[i] =h[i];
  }
  for (i=0; i<lh; i+=2)
    h1[i] = -h1[i];
  
  actual_m = 2*m;
  actual_n = 2*n;
  for (i=0; i<m*n; i++)
    yl[i] = x[i];
  
  /* main loop */
  sample_f = 1;
  for (actual_L=1; actual_L <= L; actual_L++){
    actual_m = actual_m/2;
    actual_n = actual_n/2;
    /* actual (level dependent) column offset */
    if (m==1)
      c_o_a = n*(actual_L-1);
    else
      c_o_a = 3*n*(actual_L-1);
    c_o_a_p2n = c_o_a + 2*n;
    
    /* go by rows */
    n_cb = n/actual_n;                 /* # of column blocks per row */
    for (ir=0; ir<m; ir++){            /* loop over rows */
      for (n_c=0; n_c<n_cb; n_c++){    /* loop within one row */      
	/* store in dummy variable */
	ic = -sample_f + n_c;
	for (i=0; i<actual_n; i++){    
	  ic = ic + sample_f;
	  xdummyl[i] = mat(yl, ir, ic);  
	}
	/* perform filtering lowpass/highpass */
	fpconv(xdummyl, actual_n, h0, h1, lh, ydummyll, ydummyhh); 
	/* restore dummy variables in matrices */
	ic = -sample_f + n_c;
	for  (i=0; i<actual_n; i++){    
	  ic = ic + sample_f;
	  mat(yl, ir, ic) = ydummyll[i];  
	  mat(yh, ir, c_o_a+ic) = ydummyhh[i];  
	} 
      }
    }
      
    /* go by columns in case of a 2D signal*/
    if (m>1){
      n_rb = m/actual_m;                 /* # of row blocks per column */
      for (ic=0; ic<n; ic++){            /* loop over column */
	for (n_r=0; n_r<n_rb; n_r++){    /* loop within one column */
	  /* store in dummy variables */
	  ir = -sample_f + n_r;
	  for (i=0; i<actual_m; i++){    
	    ir = ir + sample_f;
	    xdummyl[i] = mat(yl, ir, ic);  
	    xdummyh[i] = mat(yh, ir,c_o_a+ic);  
	  }
	  /* perform filtering: first LL/LH, then HL/HH */
	  fpconv(xdummyl, actual_m, h0, h1, lh, ydummyll, ydummylh); 
	  fpconv(xdummyh, actual_m, h0, h1, lh, ydummyhl, ydummyhh); 
	  /* restore dummy variables in matrices */
	  ir = -sample_f + n_r;
	  for (i=0; i<actual_m; i++){    
	    ir = ir + sample_f;
	    mat(yl, ir, ic) = ydummyll[i];  
	    mat(yh, ir, c_o_a+ic) = ydummylh[i];  
	    mat(yh, ir,c_o_a+n+ic) = ydummyhl[i];  
	    mat(yh, ir, c_o_a_p2n+ic) = ydummyhh[i];  
	  }
	}
      }
    }
    sample_f = sample_f*2;
  }
}

fpconv(double *x_in, intptr_t lx, double *h0, double *h1, intptr_t lh,
       double *x_outl, double *x_outh)
{
  intptr_t i, j;
  double x0, x1;

  for (i=lx; i < lx+lh-1; i++)
    x_in[i] = x_in[i-lx];
  for (i=0; i<lx; i++){
    x0 = 0;
    x1 = 0;
    for (j=0; j<lh; j++){
      x0 = x0 + x_in[j+i]*h0[lh-1-j];
      x1 = x1 + x_in[j+i]*h1[lh-1-j];
    }
    x_outl[i] = x0;
    x_outh[i] = x1;
  }
}

void mexFunction(int nlhs,mxArray *plhs[],int nrhs,const mxArray *prhs[])
{
  double *x, *h,  *yl, *yh, *Lr;
  intptr_t m, n, h_col, h_row, lh, i, j, L;
  double mtest, ntest;

  /* check for correct # of input variables */
  if (nrhs>3){
    mexErrMsgTxt("There are at most 3 input parameters allowed!");
    return;
  }
  if (nrhs<2){
    mexErrMsgTxt("There are at least 2 input parameters required!");
    return;
  }
  x = mxGetPr(prhs[0]);
  n = mxGetN(prhs[0]); 
  m = mxGetM(prhs[0]); 
  h = mxGetPr(prhs[1]);
  h_col = mxGetN(prhs[1]); 
  h_row = mxGetM(prhs[1]); 
  if (h_col>h_row)
    lh = h_col;
  else  
    lh = h_row;
  if (nrhs == 3){
    L = (intptr_t) *mxGetPr(prhs[2]);
    if (L < 0)
      mexErrMsgTxt("The number of levels, L, must be a non-negative integer");
  }
  else /* Estimate L */ {
    i=n;j=0;
    while (even(i)){
      i=(i>>1);
      j++;
    }
    L=m;i=0;
    while (even(L)){
      L=(L>>1);
      i++;
    }
    if(min(m,n) == 1)
      L = max(i,j);
    else
      L = min(i,j);
    if (L==0){
      mexErrMsgTxt("Maximum number of levels is zero; no decomposition can be performed!");
      return;
    }
  }
  /* Check the ROW dimension of input */
  if(m > 1){
    mtest = (double) m/pow(2.0, (double) L);
    if (!isint(mtest))
      mexErrMsgTxt("The matrix row dimension must be of size m*2^(L)");
  }
  /* Check the COLUMN dimension of input */
  if(n > 1){
    ntest = (double) n/pow(2.0, (double) L);
    if (!isint(ntest))
      mexErrMsgTxt("The matrix column dimension must be of size n*2^(L)");
  }
  plhs[0] = mxCreateDoubleMatrix(m,n,mxREAL);
  yl = mxGetPr(plhs[0]);
  if (min(m,n) == 1)
    plhs[1] = mxCreateDoubleMatrix(m,L*n,mxREAL);
  else
    plhs[1] = mxCreateDoubleMatrix(m,3*L*n,mxREAL);
  yh = mxGetPr(plhs[1]);
  if (nrhs < 3){
      plhs[2] = mxCreateDoubleMatrix(1,1,mxREAL);
      Lr = mxGetPr(plhs[2]);
      *Lr = L;
  }
  MRDWT(x, m, n, h, lh, L, yl, yh);
}
