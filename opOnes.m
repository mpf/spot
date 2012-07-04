classdef opOnes < opSpot
%OPONES   Operator equivalent to ones function.
%
%   opOnes(M,N) creates an operator corresponding to an M by N matrix
%   of ones. If parameter N is omitted it is set to M.
%
%   See also ones.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   See the file COPYING.txt for full copyright information.
%   Use the command 'spot.gpl' to locate this file.

%   http://www.cs.ubc.ca/labs/scl/spot
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods - Public
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % Constructor
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       function op = opOnes(varargin)
          if nargin == 0
             m = 1; n = 1;
          elseif nargin == 1
             if length(varargin{1}) == 2
                m = varargin{1}(1);
                n = varargin{1}(2);
             else
                m = varargin{1};
                n = m;
             end
          elseif nargin == 2
             m = varargin{1};
             n = varargin{2};
          else
             error('Too many input arguments.');
          end
          op = op@opSpot('Ones',m,n);
       end % function opOnes
       
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % Double
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       function A = double(op)
          A = ones(size(op));
       end
       
    end % Methods
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods - protected
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods( Access = protected )
       
        % Multiplication
        function y = multiply(op,x,mode)
           if (mode == 1)
              y = ones(op.m,1)*sum(x);
           else
              y = ones(op.n,1)*sum(x);
           end
        end % multiply
      
    end % Methods
        
end % Classdef
