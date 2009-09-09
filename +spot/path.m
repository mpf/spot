function spotpath = dir
%dir  Return the top-level Spot directory.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   See the file COPYING.txt for full copyright information.
%   Use the command 'spot.gpl' to locate this file.

%   http://www.cs.ubc.ca/labs/scl/spot

   parts = regexp(mfilename('fullpath'),filesep,'split');
   spotpath = fullfile(parts{1:end-2});
end
