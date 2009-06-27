%opFFT  Fast Fourier transform (FFT).
%
%   opFFT(M) create a normalized one-dimensional Fourier transform
%   operator for vectors of length M.
%
%   opFFT(M,CENTERED) creates a normalized one-dimensional Fourier
%   transform. If the CENTERED flag is set to true the components are
%   shifted to have to zero-frequency component in the center of the
%   spectrum. 
%
%   opFFT(M,N) creates a two-dimensional normalized Fourier transform
%   operator for matrices of size M by N. Input and output of the
%   matrices is done in vectorized form.
%
%   opFFT(M,N,CENTERED) just like OPFFT(M,N), but with components
%   shifted to have to zero-frequency component in the center of the
%   spectrum, if the CENTERED flag is set to true.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id: opFFT.m 44 2009-06-17 00:33:32Z ewout78 $

classdef opFFT < opSpot

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Properties
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties (SetAccess = private)
       funHandle = []; % Multiplication function
    end % Properties

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods - Public
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        
        % Constructor
        function op = opFFT(varargin)
           if nargin < 1 || nargin > 3
              error('Invalid number of arguments to opFFT.');
           end

           m = varargin{1}; n = 1; centered = false;
           if  ~isscalar(m) || m~=round(m) || m <= 0
              error('First argument to opFFT has to be a positive integer.');
           end

           if nargin == 2
              k = varargin{2};
              if islogical(k) && numel(k)==1
                 centered = k;
              elseif isscalar(k) && k==round(k)
                 n = k;
              else
                 error('Invalid combination of arguments to opFFT.');
              end
           end

           if nargin == 3
              n        = varargin{2};
              centered = varargin{3};
              if ~(islogical(centered) || numel(centered)==1 || isscalar(n))
                 error('Invalid combination of arguments to opFFT.');
              end
           end

           if n == 1
              % One-dimensional transform
              if centered
                 fun = @(x,mode) opFFT_centered_intrnl(m,x,mode);
              else
                 fun = @(x,mode) opFFT_intrnl(m,x,mode);
              end
           else
               % Two-dimensional transform
               if centered
                  fun = @(x,mode) opFFT2d_centered_intrnl(m,n,x,mode);
               else
                  fun = @(x,mode) opFFT2d_intrnl(m,n,x,mode);
               end
           end
           
           op = op@opSpot('FFT',m*n,m*n);
           op.cflag     = true;
           op.funHandle = fun;
        end
        
    end % Methods
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods - protected
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods( Access = protected )
       
        % Multiplication
        function y = multiply(op,x,mode)
           y = op.funHandle(x,mode);
        end % Multiply
      
    end % Methods
        
end % Classdef


%======================================================================


% One-dimensional DFT
function y = opFFT_intrnl(n,x,mode)
if mode == 1
   % Analysis
   y = fft(full(x)) / sqrt(n);
else
   % Synthesis
   y = ifft(full(x)) * sqrt(n);
end
end

%======================================================================

% One-dimensional DFT - Centered
function y = opFFT_centered_intrnl(n,x,mode)
if mode == 1
   y = fftshift(fft(full(x))) / sqrt(n);
else
   y = ifft(ifftshift(full(x))) * sqrt(n);
end
end

%======================================================================

% Two-dimensional DFT
function y = opFFT2d_intrnl(m,n,x,mode)
if mode == 1
   y = reshape( fft2(reshape(full(x),m,n)) / sqrt(m*n), m*n, 1);
else
   y = reshape(ifft2(reshape(full(x),m,n)) * sqrt(m*n), m*n, 1);
end
end

%======================================================================

% Two-dimensional DFT - Centered
function y = opFFT2d_centered_intrnl(m,n,x,mode)
if mode == 1
   y = fftshift(fft2(reshape(full(x),m,n))) / sqrt(m*n);
   y = reshape(y,m*n,1);
else
   y = ifft2(ifftshift(reshape(full(x),m,n))) * sqrt(m*n);
   y = reshape(y,m*n,1);
end
end
