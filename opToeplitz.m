%opToeplitz   Toeplitz matrix
%
%   OP = opToeplitz(M,N,V,TYPE,NORMALIZED) creates an M by N Toeplitz
%   matrix with entries generated using V. TYPE can either be
%   'toeplitz' or 'circular'. For the 'toeplitz' type matrix, the
%   length of V should be m+n-1, whereas for the 'circular' matrix,
%   only max(m,n) generating entries are needed. When the TYPE field
%   is empty [], or not specified 'toeplitz' is chosen by
%   default. Setting the NORMALIZED flag scales the columns of the
%   Toeplitz matrix to unit norm. Multiplication is implemented using
%   the fast Fourier transform
%
%   See also opToepGauss, opToepSign.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id$

classdef opToeplitz < opSpot

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Properties
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties (SetAccess = private)
       funHandle = []; % Multiplication function
    end % Properties


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods

       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % Constructor
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       function op = opToeplitz(m,n,v,type,normalized)

          if nargin < 4 || isempty(type)
             type = 'Toeplitz';
          end
          if nargin < 5
             normalized = 0;
          end

          switch lower(type)
             case {'circular','cyclic'}
                % Check length of generating vector
                k = max(m,n); v = v(:);
                if length(v) ~= k
                   error('Mismatch in operator size and generating vector length.');
                end
                d = v;
                df = fft(d);

                if normalized
                   if m == n
                      s = 1 / norm(d);
                   else
                      s = zeros(n,1);
                      for i=1:n
                         idx = [1:m-i+1,k-i+2:k-max(0,i-m-1)];
                         s(i) = 1 / sqrt(sum(abs(d(idx)).^2));
                      end    
                   end
                else
                   s = 1;
                end

                if isreal(d)       
                   fun = @(x,mode) opToeplitzCircular_intrnl(df,s,m,n,x,mode);
                   cflag = false;
                else
                   fun = @(x,mode) opToeplitzCircular_complex_intrnl(df,s,m,n,x,mode);
                   cflag = true;
                end

             case 'toeplitz'
                % Generate the entries of the matrix
                k  = max(m,n); v = v(:);
                if length(v) ~= m+n-1
                   error('Mismatch in operator size and generating vector length.');
                end
                d  = zeros(2*k,1); d(1:m) = v(1:m); d(end-n+2:end) = v(m+1:end);
                df = fft(d);

                if normalized
                   s = zeros(n,1); k = length(d);
                   for i=1:n
                      idx = [1:m-i+1,k-i+2:k-max(0,i-m-1)];
                      s(i) = 1 / sqrt(sum(abs(d(idx)).^2));
                   end
                else
                   s = 1;
                end

                if isreal(d)
                   fun = @(x,mode) opToeplitz_intrnl(df,s,m,n,x,mode);
                   cflag = false;
                else
                   fun = @(x,mode) opToeplitz_complex_intrnl(df,s,m,n,x,mode);
                   cflag = true;
                end

             otherwise
                error('Unrecognized type parameter');
          end

          % Construct operator
          op = op@opSpot('Toeplitz', m, n);
          op.cflag     = cflag;
          op.funHandle = fun;
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

function y = opToeplitz_intrnl(df,s,m,n,x,mode)
if mode == 1
    k = max(m,n);
    y = opToeplitzCircular_intrnl(df,1,2*k,2*k,[s.*full(x);zeros(2*k-n,1)],mode);
    y = y(1:m);
else
    k = max(m,n);
    y = opToeplitzCircular_intrnl(df,1,2*k,2*k,[full(x);zeros(2*k-m,1)],mode);
    y = s.*y(1:n);  
end
end

%======================================================================

function y = opToeplitz_complex_intrnl(df,s,m,n,x,mode)
if mode == 1
    k = max(m,n);
    y = opToeplitzCircular_complex_intrnl(df,1,2*k,2*k,[s.*full(x);zeros(2*k-n,1)],mode);
    y = y(1:m);
else
    k = max(m,n);
    y = opToeplitzCircular_complex_intrnl(df,1,2*k,2*k,[full(x);zeros(2*k-m,1)],mode);
    y = s.*y(1:n);  
end
end

%======================================================================

function y = opToeplitzCircular_intrnl(df,s,m,n,x,mode)
if mode == 1
    y = ifft(df.*fft([s.*full(x);zeros(max(m,n)-n,1)]));
    y = y(1:m);
    if isreal(x), y = real(y); end;
else
    y = ifft(conj(df).*fft([full(x);zeros(max(m,n)-m,1)]));
    y = s.*y(1:n);
    if isreal(x), y = real(y); end;
end
end

%======================================================================

function y = opToeplitzCircular_complex_intrnl(df,s,m,n,x,mode)
if mode == 1
    y = ifft(df.*fft([s.*full(x);zeros(max(m,n)-n,1)]));
    y = y(1:m);
else
    y = ifft(conj(df).*fft([full(x);zeros(max(m,n)-m,1)]));
    y = s.*y(1:n);
end
end
