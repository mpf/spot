%% Implementing Your Own Spot Operator
% At some point you might want to create a new Spot operator class to suit
% your own problems. In this tutorial, we will go through the definition of
% the |opZeros| class, explaining how you would define your own class along
% the way.

%% First Lines
% The first line in the file should specify the class name and say that it is
% a subclass of <matlab:doc('opSpot') opSpot>
% or another class such as <matlab:doc('opOrthogonal') opOrthogonal>:
%
%   classdef opZeros < opSpot
%
% You should then provide help comments about what the operator does:

%OPZEROS   Operator equivalent to zeros function.
%
%   opZeros(M,N) creates an operator corresponding to an M-by-N matrix
%   of zeros. If parameter N is omitted it is set to M.

%% Properties
% Next define any class properties that the operator has in addition to the
% ones inherited by |opSpot| and its other superclasses. |opZeros| has no
% extra properties defined. |opSpot| has the following properties, which are
% common to all Spot operator classes:
%
%   properties( SetAccess = protected )
%       linear   = 1;     % Flag the op. as linear (1) or nonlinear (0)
%       counter
%       m        = 0;     % No. of rows
%       n        = 0;     % No. of columns
%       type     = '';
%       cflag    = false; % Complexity of underlying operator
%       children = {};    % Constituent operators (for a meta operator)
%       precedence = 1;
%       sweepflag = false; % whether we can do a sweep multiply, A*B
%   end
%     
%   properties( Dependent = true, SetAccess = private )
%       nprods
%   end
%
% All Spot operators store their size, whether they are complex or not, and
% several other properties. As seen above, you can also set the access to
% properties. Some Spot operator classes have certain properties that are
% public, and certain properties that have public "GetAccess" but
% private "SetAccess". The default access is public.

%% Methods
% The first method that an operator needs is a constructor. The
% constructor for |opZeros| is below. It determines the values of |m|, |n|,
% and |type| according to the number and type of arguments passed in and
% then calls the |opSpot| constructor. More complicated operators such as
% <matlab:doc('opExtend') opExtend>
% have additional properties, and set these after calling the superclass
% constructor.
%
%   methods
%      function op = opZeros(varargin)
%         if nargin == 0
%            m = 1; n = 1;
%         elseif nargin == 1
%            if length(varargin{1}) == 2
%               m = varargin{1}(1);
%               n = varargin{1}(2);
%            else
%               m = varargin{1};
%               n = m;
%            end
%         elseif nargin == 2
%            m = varargin{1};
%            n = varargin{2};
%         else
%            error('Too many input arguments.');
%         end
%         op = op@opSpot('Zeros',m,n);
%         op.sweepflag  = true;
%       end % function opZeros
%
% Although the <matlab:doc('opSpot/double') double>
% function is defined in the |@opSpot| folder,
% |opZeros| has a more efficient implementation, as it only needs to create
% a matrix of zeros with the right dimensions. |double| is defined as a
% method in |opZeros|, overloading the generic |double| method:
%
%   function A = double(op)
%       A = zeros(size(op));
%   end
%
%   end % methods - public 
%
% Spot operators can overload other functions as needed. The constructor
% and |double| are both public methods - they can be called on an |opZero|
% operator by the user. The next section in the class definition is the
% protected methods. As a subclass of opSpot, the only method other than the
% constructor that this class is required to implement is
% |multiply(op,x,mode)|.
%
% Spot operators are multiplied using the
% <matlab:doc('opSpot/mtimes') mtimes>
% (or *) function. |mtimes| handles multiplication by
% scalars, calls opFoG if two Spot operators are being multiplied, and
% calls |applyMultiply| in the |opSpot| class if an operator and a matrix are
% being multiplied. The |applyMultiply| function checks the operator's
% |sweepflag| property. If |sweepflag| is set to true, the whole matrix
% is passed to the subclass's |multiply| function for a "sweep multiply".
% If |sweepflag| is false, |applyMultiply| calls the subclass
% operator's multiply function on each column of the matrix. For more
% information on multiplication with operators, see
% <usingmethods.html#multiplication Using the Methods>.
% Each operator's |multiply| function should take the "mode" into
% consideration. Mode 1 multiplies the operator, and mode 2 multiplies
% the operator's inverse.:
%
%   methods( Access = protected )
%       function y = multiply(op,x,mode)
%          if (mode == 1)
%             s = op.m;
%          else
%             s = op.n;
%          end
%          if any(isinf(x) | isnan(x))
%             y = ones(s,1) * NaN;
%          else
%             y = zeros(s,1);
%          end
%       end % function multiply
%       
%   end % methods - protected
%
% |opZeros| has |sweepflag| set to true, so the whole matrix is passed to
% the |multiply| method. Since multiplying any matrix by a matrix of zeros
% produces a column of zeros, this implementation is more efficient than
% the column-by-column approach.
%
%   end % classdef
%
% This is the end of the |opZeros| definition. Most of the Spot operators
% are more complicated, with additional properties, complicated
% constructors, their own public methods, and more overloaded public
% methods. The random operators like
% <matlab:doc('opGuassian') opGuassian>
% have implicit and explicit
% modes, which can create an explicit matrix or generate columns of a
% matrix as needed with a particular random number generator seed.
% <matlab:doc('opDCT') opDCT> and 
% <matlab:doc('opDCT2') opDCT2>
% have a public method called |spy|, which produces a graphic
% representation of the operator. Look through the Spot classes for more
% examples of operator implementations.

