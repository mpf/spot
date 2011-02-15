function y = vertcat(varargin)
%VERTCAT  Vertical concatenation.
%
%   [A; B] is the vertical concatenation of the operators A and B.
%
%   If Matlabpool is on, parallel stack will be called. 
%
%   See also opSpot.horzcat, opStack.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   See the file COPYING.txt for full copyright information.
%   Use the command 'spot.gpl' to locate this file.

%   http://www.cs.ubc.ca/labs/scl/spot

try
    if matlabpool('size') == 0
        y = opStack(varargin{:});
    else
        y = oppStack(varargin{:});
        warning('Matlabpool detected: Parallel Stack engaged');
    end
catch
    y = opStack(varargin{:});
end
