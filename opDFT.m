classdef opDFT < opOrthogonal
%OPDFT  Fast Fourier transform (DFT).
%
%   opDFT(M) create a unitary one-dimensional discrete Fourier
%   transform (DFT) for vectors of length M.
%
%   opDFT(M,CENTERED), with the CENTERED flag set to true, creates a
%   unitary DFT that shifts the zero-frequency component to the center
%   of the spectrum.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   See the file COPYING.txt for full copyright information.
%   Use the command 'spot.gpl' to locate this file.

%   http://www.cs.ubc.ca/labs/scl/spot

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Properties
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   properties ( Access = private )
      funHandle       % Multiplication function
   end % Properties
   
   properties ( SetAccess = private, GetAccess = public )
      centered
   end % properties
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Methods - public
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   methods
      
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      % opDFT. Constructor.
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      function op = opDFT(m,centered)
         if nargin < 1 || nargin > 2
            error('Invalid number of arguments to opDFT.');
         end
         if nargin == 2 && islogical(centered)
            centered = true;
         else
            centered = false;
         end
         if  ~isscalar(m) || m~=round(m) || m <= 0
            error('First argument to opDFT has to be a positive integer.');
         end
         
         op = op@opOrthogonal('DFT',m,m);
         op.centered    = centered;
         op.cflag       = true;
         op.sweepflag   = true;
         
         % Create function handle
         if centered
            op.funHandle = @opDFT_centered_intrnl;
         else
            op.funHandle = @opDFT_intrnl;
         end
      end % function opDFT
      
   end % methods - public
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Methods - protected
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   methods( Access = protected )
      
      % Multiplication
      function y = multiply(op,x,mode)
         y = op.funHandle(op,x,mode);
      end % Multiply
      
   end % Methods
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Methods - private
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   methods( Access = private )
      
      function y = opDFT_intrnl(op,x,mode)
         % One-dimensional DFT
         n = op.n;
         if mode == 1
            % Analysis
            y = fft(full(x)) / sqrt(n);
         else
            % Synthesis
            y = ifft(full(x)) * sqrt(n);
         end
      end
      
      function y = opDFT_centered_intrnl(op,x,mode)
         % One-dimensional DFT - Centered
         n = op.n;
         if mode == 1
            y = fftshift(fft(full(x))) / sqrt(n);
         else
            y = ifft(ifftshift(full(x))) * sqrt(n);
         end
      end
      
   end % Methods
   
end % classdef

