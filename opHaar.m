%OPHAAR   Haar wavelet
%
%   OPHAAR(M) creates a Haar wavelet operator for 1-D signals of
%   length M using 5 levels. M must be a power of 2.
%
%   OPHAAR(M,N) creates a Haar wavelet operator for 2-D signals of
%   size M-by-N, again using 5 levels. Both M and N must be powers of 2.
%
%   OPHAAR(M,N,LEVELS) optionally allows the number of LEVELS to be
%   specified.
%
%   See also opWavelet

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id$

classdef opHaar < opWavelet

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods - Public
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        
        % Constructor
        function op = opHaar(m,n,levels,redundant)

           if (nargin < 2), n         = 1;     end
           if (nargin < 3), levels    = 5;     end
           if (nargin < 4), redundant = false; end
       
           % Construct operator
           op = op@opWavelet(m,n,'Haar',1,levels,redundant);
           op.type = 'Haar';
        end % Constructor
        
    end % Methods
        
end % Classdef
