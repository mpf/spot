classdef opHaar < opWavelet
%OPHAAR   Haar wavelet.
%
%   opHaar(N) creates a Haar Wavelet operator for 1-D signals of
%   length N using 5 levels. N must be a power of 2.
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
%   See the file COPYING.txt for full copyright information.
%   Use the command 'spot.gpl' to locate this file.

%   http://www.cs.ubc.ca/labs/scl/spot
   
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
           
           op = op@opWavelet(n,'Haar',0,levels,redundant);
           op.type = 'Haar';
           
        end % function opHaar
        
    end % methods - public
        
end % classdef
