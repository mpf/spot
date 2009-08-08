function y = horzcat(varargin)
%HORZCAT  Horizontal concatenation.
%
%   [A B] is the horizonal concatenation of operators A and B.
%
%   See also vertcat, opDictionary.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/spot

y = opDictionary(varargin{:});
