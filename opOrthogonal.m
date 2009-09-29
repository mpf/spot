classdef opOrthogonal < opSpot
%OPORTHOGONAL   Abstract class for orthogonal operators.
%
%   opOrthogonal methods:
%     opOrthogonal - constructor
%     mldivide     - solves Ax=b  via  x=A'b.

%   NOTE: There's no reason to overload @opSpot/mrdivide because it's simply
%   a wrapper to mldivide.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   See the file COPYING.txt for full copyright information.
%   Use the command 'spot.gpl' to locate this file.

%   http://www.cs.ubc.ca/labs/scl/spot
    
   methods
      
      function op = opOrthogonal(type,m,n)
         %opOrthogonal   Constructor for the abstract class. 
         op = op@opSpot(type,m,n);
      end         
         
      function x = mldivide(op,b)
         %\ (backslash)  x = op\b
         x = op'*b;
      end
            
   end % methods
      
end % classdef
