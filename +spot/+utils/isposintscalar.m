function r = isposintscalar(s)
%ispostintscalar  Check if input vector is positive scalar.

%   See the file COPYING.txt for full copyright information.
%   Use the command 'spot.gpl' to locate this file.

%   http://www.cs.ubc.ca/labs/scl/spot

r = isscalar(s) && (round(s) == s) && s > 0;
