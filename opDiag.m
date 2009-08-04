classdef opDiag < opSpot
%opDiag   Diagonal operator.
%
%   opDiag(D) creates an operator for multiplication by the
%   diagonal matrix that has a vector D on its diagonal.
%
%   See also diag.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/spot

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Properties
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   properties (SetAccess = private)
      diag     % Diagonal entries
   end % Properties
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Methods - Public
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   methods
      
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      % opDiag. Constructor
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      function op = opDiag(d)
         if nargin ~= 1
            error('Invalid number of arguments.');
         end
         
         % Vectorize d and get size
         d = d(:);
         n = length(d);
         
         % Construct operator
         op = op@opSpot('Diag',n,n);
         op.cflag      = ~isreal(d);
         op.diag       = d;
      end % function opDiag
      
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      % mldivide
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      function x = mldivide(op,B)
         n = op.n;
         if size(B,1) ~= n
            error('Matrix dimensions must agree')
         end
         k = size(B,2); % No. of right-hand sides
         x = zeros(n,k);
         for j=1:k
             x(:,j) = B(:,j)./op.diag;
         end
      end % function mldivide
      
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      % double
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      function A = double(op)
         A = diag(op.diag);
      end % function double
      
   end % Methods
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Methods - protected
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   methods( Access = protected )
      
      % Multiplication
      function y = multiply(op,x,mode)
         if mode == 1
            y = op.diag.*x;
         else
            y = conj(op.diag).*x;
         end
      end % function multiply
      
   end % methods - public
   
end % classdef
