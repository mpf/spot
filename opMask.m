%opMask  Selection mask
%
%   opMask(N,IDX) creates a diagonal N-by-N operator that has ones
%   only on those locations indicated by IDX.
%
%   See also opDiag, opRestriction.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id$

classdef opMask < opSpot

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Properties
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties (SetAccess = private)
       mask = []; % Binary mask
    end % Properties

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods - Public
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % Constructor
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       function op = opMask(n,idx)
          if nargin ~= 2
             error('Exactly two operators must be specified.')
          end
           
          idx = full(idx(:));

          if islogical(idx)
             if length(idx) > n
                error('Index exceeds operator dimensions.');
             end
          elseif isposintmat(idx) || isempty(idx)
             if ~isempty(idx) && (max(idx) > n)
                error('Index exceeds operator dimensions.');
             end
          else
             error('Subscript indices must either be real positive integers or logicals.');
          end
           
           % Set mask
           mask = zeros(n,1);
           mask(idx) = 1;
           
           % Construct operator
           op = op@opSpot('Mask',n,n);
           op.mask = mask;
        end % Constructor
        
    end % Methods

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods - protected
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods( Access = protected )
       
        % Multiplication
        function y = multiply(op,x,mode)
            y = op.mask.*x;
        end % Multiply
      
    end % Methods
        
end % Classdef
