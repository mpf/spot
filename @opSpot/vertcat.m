function y = vertcat(varargin)
%VERTCAT  Vertical concatenation.
%
%   [A; B] is the vertical concatenation of the operators A and B.
%
%   See also horzcat, opStack.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/spot

y = opStack(varargin{:});
