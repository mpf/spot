function y = blkdiag(varargin)
%BLKDIAG   Block-diagonal concatenation of operator input arguments.
%
%   B = blkdiag(OP1,OP2,...) produces the block-diagonal operator
%
%            [ OP1                ]
%        B = [      OP2           ]
%            [           ...      ]
%            [                OPN ]
%
%   See also opBlockDiag.
%   
%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   http://www.cs.ubc.ca/labs/scl/spot

y = opBlockDiag([],varargin{:},0); % No weight, zero overlap
