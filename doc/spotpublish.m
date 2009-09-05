function spotpublish
%spotpublish  Generate Spot documentation.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   See the file COPYING.txt for full copyright information.
%   Use the command 'spot.gpl' to locate this file.

%   http://www.cs.ubc.ca/labs/scl/spot

   format short g
   opts.format = 'html';
   opts.outputDir = 'html';
   publish('elementary_operators.m',opts);
   publish('meta_operators.m',opts);
   publish('fast_operators.m',opts);
   publish('random_ensembles.m',opts);
   publish('container_operators.m',opts);
   publish('circulant.m',opts);
   
end % function spotpublish
