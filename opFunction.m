classdef opFunction < opSpot
%OPFUNCTION   Wrapper for functions.
%
%   opFunction(M,N,FUN) creates a wrapper for function FUN, which
%   corresponds to an M-by-N operator. The FUN parameter can be one of two
%   types:
%
%   1) A handle to a function of the form FUN(X,MODE), where the
%      operator is applied to X when MODE = 1, and the transpose is applied
%      when MODE = 2;
%   2) A cell array of two function handles: {FUN,FUN_TRANSPOSE},
%      each of which requires only one parameter, X.
%
%   opFunction(M,N,FUN,CFLAG,LINFLAG) additionally allows the arguments
%   CFLAG and LINFLAG to indicate whether the function implements a complex
%   or real operator and whether it is linear or not. The default values
%   are CFLAG=0, LINFLAG=1.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   See the file COPYING.txt for full copyright information.
%   Use the command 'spot.gpl' to locate this file.

%   http://www.cs.ubc.ca/labs/scl/spot

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Properties
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties ( SetAccess = private )
       funHandle  % Function handles
    end % Properties

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods - Public
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        
        % Constructor
        function op = opFunction(m,n,funhandle,cflag,linflag)
           import spot.utils.*
           if nargin < 3
              error('opFunction requires at least three parameters.');
           end
           if nargin < 4 || isempty(cflag)
              cflag = 0;
           end
           if nargin < 5 || isempty(linflag)
              linflag = 1;
           end
           if ~isposintscalar(m) || ~isposintscalar(n)
              error('Dimensions of operator must be positive integers.');
           end
           
           if iscell(funhandle) && length(funhandle) == 2
              if ~isa(funhandle{1},'function_handle') || ...
                 ~isa(funhandle{2},'function_handle')
                 error('Invalid function handle specified.');
              end
              fun = @(x,mode) opFunction_intrnl(funhandle,x,mode);
              
           elseif isa(funhandle,'function_handle')
              fun = @(x,mode) funhandle(x,mode);
              
           else
              error('Invalid function handle specified.');
              
           end
           
           % Construct operator
           op = op@opSpot('Function',m,n);
           op.cflag  = cflag;
           op.linear = linflag;
           op.funHandle = fun;
        end % Constructor
        
    end % Methods

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods - protected
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods( Access = protected )
       
        % Multiplication
        function y = multiply(op,x,mode)
           y = op.funHandle(x,mode);
        end % Multiply
       
    end % Methods
        
end % Classdef

%======================================================================

function y = opFunction_intrnl(funhandle,x,mode)
if mode == 1
   fun = funhandle{1};
else
   fun = funhandle{2};
end

% Evaluate the function
y = fun(x);
end
