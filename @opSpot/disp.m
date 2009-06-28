function disp(A,name)
%DISP  Display a Sparco operator.
%
%   DISP(A) displays a Sparco operator, excluding its name.
%
%   DISP(A,NAME) displays a Sparco operator along with its name.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id$

if nargin < 1
   error('Not enough input arguments.');
end

if A.linear
   linear = 'linear';
else
   linear = 'non-linear';
end

[m,n] = size(A);

if nargin == 2 && ~isempty(name)
    fprintf('%s = \n',name);
end
fprintf('Sparco operator (%s) of size %i x %i\n',linear,m,n);
fprintf('\t %s\n',char(A));
