classdef opToeplitz < opSpot
%OPTOEPLITZ   Toeplitz matrix.
%
%   OP = opToeplitz(R) creates an N-by-N circular Toeplitz
%   operator from the N-vector R. The entries of R prescribe the
%   first row of the operator.
%
%   OP = opToeplitz(C,R) creates an M-by-N Toeplitz operator where
%   M = length(C) and N = length(R). The entries of C prescribe the
%   first column of the operator, and likewise, R prescribes the
%   first row.
%
%   The above calls are nearly idential to Matlab's built-in TOEPLITZ
%   function.
%
%   Additionally, each call above accepts an optional logical flag that
%   indicates if the column are scaled to have unit 2-norm length:
%
%   OP = opToeplitz(R,NORMALIZED)
%   OP = opToeplitz(C,R,NORMALIZED)
%
%   Multiplication in either mode is implemented using the fast
%   Fourier transform
%
%   See also teoplitz, opToepGauss, opToepSign.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   See the file COPYING.txt for full copyright information.
%   Use the command 'spot.gpl' to locate this file.

%   http://www.cs.ubc.ca/labs/scl/spot

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
       function op = opToeplitz(varargin)

          if nargin < 1
             error('Not enough input arguments.');
          elseif nargin > 3
              error('Too many input arguments.');
          end

          % Extract parameters
          if nargin == 1
             r = varargin{1};
             normalized = false;
             type = 'circular';
          elseif nargin == 2
             if isscalar(varargin{2})
                r = varargin{1};
                normalized = varargin{2};
                type = 'circular';
             else
                c = varargin{1};
                r = varargin{2};
                normalized = false;
                type = 'toeplitz';
             end             
          elseif nargin == 3
             c = varargin{1};
             r = varargin{2};
             normalized = varargin{3};
             type = 'toeplitz';
          end

          % Set row or column vector for symmetric Toeplitz
          if strcmp(type,'toeplitz')
             if isempty(c), c = conj(r); c(1) = r(1); end;
             if isempty(r), r = conj(c); r(1) = c(1); end;
          end
          

          % Set up the operator
          switch lower(type)
             case {'circular'}
                r  = r(:);
                m  = length(r);
                n  = m;
                df = fft([r(1); r(end:-1:2)]);

                if normalized
                   s = 1 / norm(r);
                else
                   s = 1;
                end

                if isreal(r)
                   fun = @(x,mode) opToeplitzCircular_intrnl(df,s,x,mode);
                   cflag = false;
                else
                   fun = @(x,mode) opToeplitzCircular_complex_intrnl(df,s,x,mode);
                   cflag = true;
                end

             case 'toeplitz'
                % Check compatibility of R and C
                if c(1) ~= r(1)
                   warning(sprintf(['First element of input column does not ',...
                                    'match first element of input row.\n',...
                                    '         Column wins diagonal conflict.']));
                   r(1) = c(1); % Not really needed
                end
          
                r = r(:); c = c(:);
                m = length(c);
                n = length(r);
                
                % Generate the entries of the matrix
                v  = [c;r(end:-1:2)];
                df = fft(v);

                if normalized
                   v = [c(end:-1:1);r(2:end)];
                   s = zeros(n,1);
                   for i=1:n
                      s(i) = 1 / sqrt(sum(abs(v(i:i+m-1)).^2));
                   end
                else
                   s = 1;
                end

                if isreal(v)
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
    y = opToeplitzCircular_intrnl(df,1,[s.*full(x);zeros(m-1,1)],mode);
    y = y(1:m);
else
    y = opToeplitzCircular_intrnl(df,1,[full(x);zeros(n-1,1)],mode);
    y = s.*y(1:n);  
end
end

%======================================================================

function y = opToeplitz_complex_intrnl(df,s,m,n,x,mode)
if mode == 1
    y = opToeplitzCircular_complex_intrnl(df,1,[s.*full(x);zeros(m-1,1)],mode);
    y = y(1:m);
else
    y = opToeplitzCircular_complex_intrnl(df,1,[full(x);zeros(n-1,1)],mode);
    y = s.*y(1:n);  
end
end

%======================================================================

function y = opToeplitzCircular_intrnl(df,s,x,mode)
if mode == 1
    y = ifft(df.*fft(s.*full(x)));
    if isreal(x), y = real(y); end;
else
    y = ifft(conj(df).*fft(full(x)));
    y = s.*y;
    if isreal(x), y = real(y); end;
end
end

%======================================================================

function y = opToeplitzCircular_complex_intrnl(df,s,x,mode)
if mode == 1
    y = ifft(df.*fft(s.*full(x)));
else
    y = ifft(conj(df).*fft(full(x)));
    y = s.*y;
end
end
