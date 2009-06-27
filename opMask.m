%opMask  Selection mask
%
%   opMask(MASK) creates an operator that computes the dot-product of
%   a given vector with the (binary) mask provided by MASK. If MASK is
%   a matrix it will be vectorized prior to use.
%
%   See also opDiag, opRestriction.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id: opMask.m 39 2009-06-12 20:59:05Z ewout78 $

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
        
        % Constructor
        function op = opMask(mask)
           if nargin ~= 1
              error('Invalid number of arguments.');
           end
           
           % Vectorize mask and get size
           mask = mask(:);
           n    = length(mask);
           
           % Construct object
           op = op@opSpot('Mask',n,n);
           op.cflag      = true;
           op.linear     = true;
           op.mask       = double(mask ~= 0);
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
