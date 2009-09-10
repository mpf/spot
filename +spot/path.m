function spotpath = path
%path  Return the top-level Spot directory.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   See the file COPYING.txt for full copyright information.
%   Use the command 'spot.gpl' to locate this file.

%   http://www.cs.ubc.ca/labs/scl/spot

   fullpath = mfilename('fullpath');
   idx      = find(fullpath == filesep);
   spotpath = fullpath(1:idx(end-1));
end
