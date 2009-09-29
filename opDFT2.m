classdef opDFT2 < opOrthogonal
%OPDFT2  Two-dimensional fast Fourier transform (DFT).
%
%   opDFT2(M,N) creates a two-dimensional normalized Fourier transform
%   operator for matrices of size M by N. Input and output of the
%   matrices is done in vectorized form.
%
%   opDFT2(M,N,CENTERED) just like opDFT2(M,N), but with components
%   shifted to have to zero-frequency component in the center of the
%   spectrum, if the CENTERED flag is set to true.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   See the file COPYING.txt for full copyright information.
%   Use the command 'spot.gpl' to locate this file.

%   http://www.cs.ubc.ca/labs/scl/spot

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Properties
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   properties ( Access = private )
      funHandle         % Multiplication function
   end % properties
   
   properties ( SetAccess = private, GetAccess = public )
      inputdims         % Dimensions of the input
      centered          % Flag if operator created with center flag
   end % properties
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Methods - Public
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   methods
      
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      % opDFT2. Constructor.
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      function op = opDFT2(m,n,centered)
         if nargin < 1 || nargin > 3
            error('Invalid number of arguments to opDFT2.');
         elseif nargin == 1
            n = m;
         end
         if nargin >= 3 && islogical(centered)
            centered = true;
         else
            centered = false;
         end
         if  ~isscalar(m) || m~=round(m) || m <= 0
            error('First argument to opDFT2 must be positive integer.');
         end
         if  ~isscalar(n) || n~=round(n) || n <= 0
            error('Second argument to opDFT2 must be positive integer.');
         end
         
         op = op@opOrthogonal('DFT2',m*n,m*n);
         op.centered  = centered;
         op.cflag     = true;
         op.inputdims = [m,n];
         
         % Initialize function handle
         if centered
            op.funHandle = @opDFT2d_centered_intrnl;
         else
            op.funHandle = @opDFT2d_intrnl;
         end
      end % function opDFT2
      
   end % methods - public
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Methods - protected
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   methods( Access = protected )
      
      function y = multiply(op,x,mode)
         y = op.funHandle(op,x,mode);
      end % function multiply
      
   end % methods - protected

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Methods - private
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   methods( Access = private )

      function y = opDFT2d_intrnl(op,x,mode)
         m = op.inputdims(1);
         n = op.inputdims(2);
         if mode == 1
            y = reshape( fft2(reshape(full(x),m,n)) / sqrt(m*n), m*n, 1);
         else
            y = reshape(ifft2(reshape(full(x),m,n)) * sqrt(m*n), m*n, 1);
         end
      end % function opDFT2d_intrnl
      
      % Two-dimensional DFT - Centered
      function y = opDFT2d_centered_intrnl(op,x,mode)
         m = op.inputdims(1);
         n = op.inputdims(2);
         if mode == 1
            y = fftshift(fft2(reshape(full(x),m,n))) / sqrt(m*n);
            y = reshape(y,m*n,1);
         else
            y = ifft2(ifftshift(reshape(full(x),m,n))) * sqrt(m*n);
            y = reshape(y,m*n,1);
         end
      end % function opDFT2d_centered_intrnl

   end % methods - private
   
end % classdef
