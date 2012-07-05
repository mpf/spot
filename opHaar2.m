classdef opHaar2 < opWavelet2
%OPHAAR2   2-D Haar Wavelet.
%
%   opHaar2(M,N) creates a Haar Wavelet operator for 2-D signals of
%   size M-by-N using 5 levels. M*N must be a power of 2.
%
%   opHaar2(M,N,LEVELS) optionally allows the number of LEVELS to be
%   specified.
%
%   opHaar2(M,N,LEVELS,REDUNDANT) optionally specifies the boolean field
%   REDUNDANT (default false).  (See opWavelet for a description of this
%   option.)
%
%   See also opHaar, opWavelet.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   See the file COPYING.txt for full copyright information.
%   Use the command 'spot.gpl' to locate this file.

%   http://www.cs.ubc.ca/labs/scl/spot
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Methods - Public
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   methods
      
      % Constructor
      function op = opHaar2(m,n,levels,redundant)
         %opHaar  constructor
         if nargin < 2, n = m; end
         if nargin < 3, levels = 5; end
         if nargin < 4, redundant = false; end
         
         % n must be a multiple of 2^(levels)
         if rem(m*n,2^levels)
            error('N must be a multiple of 2^(%i)',levels)
         end
         
         op = op@opWavelet2(m,n,'Haar',1,levels,redundant);
         op.type = 'Haar2';
         
      end % function opHaar2
      
   end % methods - public
   
end % classdef
