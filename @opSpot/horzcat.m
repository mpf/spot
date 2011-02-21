function y = horzcat(varargin)
%HORZCAT  Horizontal concatenation.
%
%   [A B] is the horizonal concatenation of operators A and B.
%
%   See also opSpot.vertcat, opDictionary.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   See the file COPYING.txt for full copyright information.
%   Use the command 'spot.gpl' to locate this file.

%   http://www.cs.ubc.ca/labs/scl/spot

y = opDictionary(varargin{:});
