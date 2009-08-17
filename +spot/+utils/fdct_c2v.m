function c = fdct_c2v(x,cn)
% FDCT_C2V  Curvelet coefficients to vector
%
%   FDCT_C2V(X,CN) returns a vector of length CN containing
%   the curvelet coefficients contained in X. When parameter
%   CN is omitted the vector length is determined from X.

%   Copyright 2008, Gilles Hennenfent, Ewout van den Berg, Michael P. Friedlander
%   See the file COPYING.txt for full copyright information.
%   Use the command 'spot.gpl' to locate this file.

%   http://www.cs.ubc.ca/labs/scl/spot

% If vector size is not give, determine from coefficients
if nargin < 2
  cn = 0;
  for i = 1:length(x)
     for j=1:length(x{i})
        cn = cn + prod(size(x{i}{j}));
     end
   end  
end

% Get the coefficients
c = zeros(cn,1);
k = 1;
for i = 1:length(x)
   for j=1:length(x{i})
      sz = prod(size(x{i}{j}));
      c(k:k+sz-1) = reshape(x{i}{j},sz,1);
      k = k + sz;
   end
end
