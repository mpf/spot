function disp(A,name)
%DISP  Display a Spot operator.
%
%   disp(A) displays a Spot operator, excluding its name.
%
%   disp(A,NAME) displays a Spot operator along with its name.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   See the file COPYING.txt for full copyright information.
%   Use the command 'spot.gpl' to locate this file.

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
      fprintf('    rows: %6d    complex: %-10s\n',m,cflag);
      fprintf('    cols: %6d    type:    %-10s\n',n,A.type);
   end
end
