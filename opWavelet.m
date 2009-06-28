%opWavelet   Wavelet operator
%
%   opWavelet(M,N,FAMILY,FILTER,LEVELS,REDUNDANT,TYPE) creates a
%   wavelet operator of given FAMILY, for M by N matrices. The wavelet
%   transformation is computed using the Rice Wavelet Toolbox.  The
%   values supported for FAMILY are 'Daubechies' and 'Haar'.
%
%   The remaining four parameters are optional. FILTER (= 8) specifies
%   the filter length and must be even. LEVELS (= 5) gives the number
%   of levels in the transformation. Both M and N must be divisible by
%   2^LEVELS. The Boolean field REDUNDANT (= false) indicates whether
%   the wavelet is redundant. TYPE (= 'min') indictates what type of
%   solution is desired; 'min' for minimum phase, 'max' for maximum
%   phase, and 'mid' for mid-phase solutions.

%   Copyright 2009, Rayan Saab, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id$

classdef opWavelet < opSpot

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Properties
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties (SetAccess = private)
       family    = ''; % Wavelet family
       filter    = 0;  % Filter length
       levels    = 0;  % Number of levels
       redundant = 0;  % Redundant flag
       funHandle = []; % Multiplication function
    end % Properties


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods

       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % Constructor
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       function op = opWavelet(m,n,family,filter,levels,redundant,type)
          if (nargin < 3), family    = 'Daubechies'; end;
          if (nargin < 4), filter    = 8;            end;
          if (nargin < 5), levels    = 5;            end;
          if (nargin < 6), redundant = false;        end;
          if (nargin < 7), type      = 'min';        end;

          family = lower(family);

          switch family
             case {'daubechies'}
                family = 'Daubechies';
                h = daubcqf(filter);
    
             case {'haar'}
                family = 'Haar';
                h = daubcqf(0);
    
             otherwise
                error('Wavelet family %s is unknown.', family);
          end

          % Initialize function handle
          if redundant
             r   = 3*levels + 1;
             fun = @(x,mode) opWaveletRedundant_intrnl(m,n,family,filter,levels,type,h,x,mode);
          else
             r   = 1;
             fun = @(x,mode) opWavelet_intrnl(m,n,family,filter,levels,type,h,x,mode);
          end

          % Construct operator
          op = op@opSpot('Wavelet', r*m*n, m*n);
          op.funHandle = fun;
          op.family    = family;
          op.filter    = filter;
          op.levels    = levels;
          op.redundant = redundant;
       end % Constructor

    end % Methods
       
 
    methods ( Access = protected )
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % Multiply
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       function y = multiply(op,x,mode)
          y = op.funHandle(x,mode);
       end % Multiply          

    end % Methods
   
end % Classdef


%=======================================================================


function y = opWavelet_intrnl(m,n,family,filter,levels,type,h,x,mode)
if mode == 1
   if isreal(x)
      [y,l] = mdwt(reshape(x,[m,n]), h, levels);
   else
      [y1,l] = mdwt(reshape(real(x),[m,n]), h, levels);
      [y2,l] = mdwt(reshape(imag(x),[m,n]), h, levels);
     y = y1 + sqrt(-1) * y2;    
   end   
   y = reshape(y,[m*n,1]);
else
   if isreal(x)
     [y,l] = midwt(reshape(x,[m,n]), h, levels);
   else
     [y1,l] = midwt(reshape(real(x),[m,n]), h, levels);
     [y2,l] = midwt(reshape(imag(x),[m,n]), h, levels);
     y = y1 + sqrt(-1) * y2;    
   end
   y = reshape(y,[m*n,1]);
end
end

%=======================================================================

function y = opWaveletRedundant_intrnl(m,n,family,filter,levels,type,h,x,mode)
if mode == 1
   if isreal(x)
      [yl,yh,l] = mrdwt(reshape(x,[m,n]), h, levels);
      y = [yl,yh];
   else
      [yl1,yh1,l] = mrdwt(reshape(real(x),[m,n]), h, levels);
      [yl2,yh2,l] = mrdwt(reshape(imag(x),[m,n]), h, levels);
      y = [yl1,yh1] + sqrt(-1) * [yl2,yh2];
   end   
   y = reshape(y,[(3*levels+1)*m*n,1]);
else
   xl = reshape(x(1:m*n),m,n);
   xh = reshape(x(m*n+1:end),m,3*levels*n);
   if isreal(x)
     [y,l] = mirdwt(xl, xh, h, levels);
   else
     [y1,l] = mirdwt(real(xl), real(xh), h, levels);
     [y2,l] = mirdwt(imag(xl), imag(xh), h, levels);
     y = y1 + sqrt(-1) * y2;    
   end
   y = reshape(y,[m*n,1]);
end
end
