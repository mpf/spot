%opHaar   Haar wavelet
%
%   opHaar(N) creates a Haar Wavelet operator for 1-D signals of
%   length M using 5 levels. M must be a power of 2.
%
%   opHaar(N,LEVELS) optionally allows the number of LEVELS to be
%   specified.
%
%   opHaar(N,LEVELS,REDUNDANT) optionally specifies the boolean field
%   REDUNDANT (default false).  (See opWavelet for a description of this
%   option.)
%
%   See also opWavelet.

%   Copyright 2008-2009, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id$

classdef opHaar < opWavelet
   
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods - Public
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        
        % Constructor
        function op = opHaar(n,levels,redundant)

           if nargin < 2, levels    = 5;     end
           if nargin < 3, redundant = false; end
           
           % n must be a multiple of 2^(levels)
           if rem(n,2^levels)
              error('N must be a multiple of 2^(%i)',levels)
           end
           
           op = op@opWavelet(n,1,'Haar',1,levels,redundant);
           op.type = 'Haar';
           
        end % Constructor
        
    end % Methods
        
end % Classdef
