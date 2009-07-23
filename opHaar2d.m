%opHaar2D   2-D Haar Wavelet
%
%   opHaar2D(M,N) creates a Haar Wavelet operator for 2-D signals of
%   size M-by-N using 5 levels. M*N must be a power of 2.
%
%   opHaar2D(M,N,LEVELS) optionally allows the number of LEVELS to be
%   specified.
%
%   opHaar2D(M,N,LEVELS,REDUNDANT) optionally specifies the boolean field
%   REDUNDANT (default false).  (See opWavelet for a description of this
%   option.)
%
%   See also opHaar, opWavelet.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id$

classdef opHaar2D < opWavelet
   
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods - Public
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        
        % Constructor
        function op = opHaar2D(m,n,levels,redundant)

           if nargin < 2, error('At least two arguments required.'); end
           if nargin < 3, levels    = 5;     end
           if nargin < 4, redundant = false; end
           
           % n must be a multiple of 2^(levels)
           if rem(m*n,2^levels)
              error('N must be a multiple of 2^(%i)',levels)
           end
           
           op = op@opWavelet(m,n,'Haar',1,levels,redundant);
           op.type = 'Haar2D';
           
        end % Constructor
        
    end % Methods
        
end % Classdef
