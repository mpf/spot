function disp(A,name)
%DISP  Display a Spot operator.
%
%   DISP(A) displays a Spot operator, excluding its name.
%
%   DISP(A,NAME) displays a Spot operator along with its name.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/spot

   if nargin < 1
      error('Not enough input arguments.');
   end
   
   if A.linear, linear = 'yes';
   else         linear = 'no';
   end
   if A.cflag,  cflag = 'yes';
   else         cflag = 'no';
   end
   
   [m,n] = size(A);

   detailed = nargin == 2 && ~isempty(name);
   
   if detailed
      fprintf('%s = \n',name);
   end
   fprintf('  Spot operator: %s\n',char(A));
   if detailed
      fprintf('    rows: %6d    complex: %3s\n',m,cflag);
      fprintf('    cols: %6d    type:    %3s\n',m,A.type);
   end
end
