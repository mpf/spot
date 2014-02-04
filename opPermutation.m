classdef opPermutation < opSpot
%OPPERMUTATION   Permutation operator.
%
%   P = opPermutation(p) creates a permutation operator from a permutation
%   vector. The product P*b is then equivalent to b(p).
%
%   Dominique Orban <dominique.orban@gerad.ca>, 2014.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   See the file COPYING.txt for full copyright information.
%   Use the command 'spot.gpl' to locate this file.

%   http://www.cs.ubc.ca/labs/scl/spot

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Properties
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties( SetAccess = private )
      p             % Permutation vector
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods

       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % Constructor
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       function op = opPermutation(p)

          if nargin ~= 1
             error('Exactly one operator must be specified.')
          end

          % Check that the input is valid.
          if ~isa(p,'numeric')
             error('Input vector is not valid.')
          end

          % Construct operator
          n = length(p);
          op = op@opSpot('Permutation', n, n);
          if size(p,1) > size(p,2)
            op.p = p(:,1);
          else
            op.p = p(1,:)';
          end
          op.linear = 1;
          op.cflag  = false;
       end % function opPermutation

       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       function x = double(op)
       %double  Convert operator to a double.
          n = size(op,1);
          x = op * eye(n);
       end
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    end % methods - public

    methods ( Access = protected )
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % Multiply
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       function y = multiply(op,x,mode)
          if mode == 1
             y = x(op.p);
          else
             y(op.p) = x;
          end
        end % function multiply

       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % divide
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       function x = divide(op, b, mode)
          x = op.multiply(b, 3-mode);  % Exchange mode=1 and mode=2
       end % function divide

    end % methods - protected

end % classdef
