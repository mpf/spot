classdef opDirac < opOrthogonal   
%OPDIRAC  Dirac basis.
%
%   opDirac(N) creates the square N-by-N identity operator. Without
%   any arguments an operator corresponding to the scalar 1 is
%   created.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   See the file COPYING.txt for full copyright information.
%   Use the command 'spot.gpl' to locate this file.

%   http://www.cs.ubc.ca/labs/scl/spot

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Methods - public
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   methods
      
      % Constructor
      function op = opDirac(n)
         if nargin < 1, n = 1; end
         op = op@opOrthogonal('Dirac',n,n);
      end
      
      function A = double(op)
         A = eye(size(op));
      end
      
   end % methods - public
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Methods - protected
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   methods( Access = protected )
      
      % Multiplication
      function y = multiply(op,x,mode)
         y = x;
      end
      
   end % methods - protected
   
end % classdef
