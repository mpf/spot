function r = isposintmat(m)
%ispostintmat  Check if input vector is positive integer.

%   See the file COPYING.txt for full copyright information.
%   Use the command 'spot.gpl' to locate this file.

%   http://www.cs.ubc.ca/labs/scl/spot

r = all(all( (round(m) == m) & (m > 0) ));
