function y = blkdiag(varargin)

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id$

y = opBlockDiag([],varargin{:},0); % No weight, zero overlap
