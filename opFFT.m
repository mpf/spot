%opFFT  Fast Fourier transform (FFT).
%
%   opFFT(M) create a normalized one-dimensional Fourier transform
%   operator for vectors of length M.
%
%   opFFT(M,CENTERED) creates a normalized one-dimensional Fourier
%   transform. If the CENTERED flag is set to true the components are
%   shifted to have to zero-frequency component in the center of the
%   spectrum. 

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id$

classdef opFFT < opSpot

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Properties
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties ( SetAccess = private )
       funHandle = []; % Multiplication function
    end % Properties

    properties ( SetAccess = private, GetAccess = public )
       centered = false;
    end % properties
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods - Public
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        
        % Constructor
        function op = opFFT(m,centered)
           if nargin < 1 || nargin > 2
              error('Invalid number of arguments to opFFT.');
           end
           if nargin == 2 && islogical(centered)
              centered = true;
           else
              centered = false;
           end
           if  ~isscalar(m) || m~=round(m) || m <= 0
              error('First argument to opFFT has to be a positive integer.');
           end
 
           op = op@opSpot('FFT',m,m);
           op.centered = centered;
           op.cflag    = true;

           % Create function handle
           if centered
              fun = @(x,mode) opFFT_centered_intrnl(op,x,mode);
           else
              fun = @(x,mode) opFFT_intrnl(op,x,mode);
           end 
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

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods - private
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods( Access = private )
        
        function y = opFFT_intrnl(op,x,mode)
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

        function y = opFFT_centered_intrnl(n,x,mode)
           % One-dimensional DFT - Centered
           n = op.n;
           if mode == 1
               y = fftshift(fft(full(x))) / sqrt(n);
           else
               y = ifft(ifftshift(full(x))) * sqrt(n);
           end
        end
           
   end % Methods
    
end % Classdef

