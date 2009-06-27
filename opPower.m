%opPower   Raise operator to integer power
%
%   opPower(OP,P) creates the operator OP^P for integer values of
%   P. When P = 0, the identity matrix is returned. When P < 0 we
%   reformulate the operator as inv(OP^|P|).

classdef opPower < opSpot

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Properties
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties (SetAccess = private)
       funHandle = []; % Multiplication function
       exponent  = 1; % Exponent of power operator
    end % Properties


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods

       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % Constructor
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       function op = opPower(A,p)
          
          if nargin ~= 2
             error('Exactly two operators must be specified.')
          end
          if p ~= round(p)
             error('Second argument to opPower must be an integer.');
          end
          
          % Input matrices are immediately cast as opMatrix's.
          if isa(A,'numeric'), A = opMatrix(A); end
          
          % Check that the input operators are valid.
          if ~isa(A,'opSpot')
             error('Input operator is not valid.')
          end
          
          % Create function handle
          if p == 0
             fun = @(x,mode) x;
          elseif p > 0
             fun = @(x,mode) opPower_intrnl(A,p,x,mode);
          else
             fun = @(x,mode) apply(inv(A^abs(p)),x,mode);
          end

          % Construct operator
          [m, n] = size(A);
          op = op@opSpot('Power', n, m);
          op.cflag      = A.cflag;
          op.linear     = A.linear;
          op.children   = {A};
          op.precedence = 1;
          op.exponent   = p;
          op.funHandle  = fun;
       end % Constructor
      
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % Display
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       function str = char(op)
          str = [char(op.children{1}),sprintf('^%d',op.exponent)];
       end % Char
       
    end % Methods


    methods ( Access = protected )
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % Multiply
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       function y = multiply(op,x,mode)
          y = op.funHandle(x,mode);
       end % Multiply

    end % Methods
   
end % Classdef


%======================================================================


function y = opPower_intrnl(opA,p,x,mode)
y = x;
for i=1:p
   y = apply(opA,y,mode);
end
end
