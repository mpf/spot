function y = vertcat(varargin)
%VERTCAT  Vertical concatenation.
%
%   [A; B] is the vertical concatenation of the operators A and B.
%
%   See also opSpot.horzcat, opStack.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   See the file COPYING.txt for full copyright information.
%   Use the command 'spot.gpl' to locate this file.

%   http://www.cs.ubc.ca/labs/scl/spot

y = opStack(varargin{:});
