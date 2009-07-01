%opFFT2  Two-dimensional fast Fourier transform (FFT).
%
%   opFFT2(M,N) creates a two-dimensional normalized Fourier transform
%   operator for matrices of size M by N. Input and output of the
%   matrices is done in vectorized form.
%
%   opFFT2(M,N,CENTERED) just like opFFT2(M,N), but with components
%   shifted to have to zero-frequency component in the center of the
%   spectrum, if the CENTERED flag is set to true.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id: opFFT.m 13 2009-06-28 02:56:46Z mpf $

classdef opFFT2 < opSpot

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
        function op = opFFT2(m,n,centered)
           if nargin < 2 || nargin > 3
              error('Invalid number of arguments to opFFT2.');
           end
           if nargin < 3, centered = false; end;

           if  ~isscalar(m) || m~=round(m) || m <= 0
              error('First argument to opFFT2 has to be a positive integer.');
           end
           
           if  ~isscalar(n) || n~=round(n) || n <= 0
              error('Second argument to opFFT2 has to be a positive integer.');
           end

           if ~(isscalar(centered))
              error('Third argument to opFFT2 must be a scalar.');
           end

           % Initialize function handle
           if centered
              fun = @(x,mode) opFFT2d_centered_intrnl(m,n,x,mode);
           else
              fun = @(x,mode) opFFT2d_intrnl(m,n,x,mode);
           end
           
           op = op@opSpot('FFT2',m*n,m*n);
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
