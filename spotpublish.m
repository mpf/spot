function spotpublish(tag)
%spotpublish  Generate Spot documentation.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   See the file COPYING.txt for full copyright information.
%   Use the command 'spot.gpl' to locate this file.

%   http://www.cs.ubc.ca/labs/scl/spot

   % Documentation pages
   format short g
   opts.format = 'html';
   opts.outputDir = 'html';
   publish('spot_operators.m',opts);
   publish('container_operators.m',opts);
   publish('elementary_operators.m',opts);
   publish('meta_operators.m',opts);
   publish('fast_operators.m',opts);
   publish('random_ensembles.m',opts);
   publish('guide_circulant.m',opts);
   
   % Main page
   system('jemdoc spot_main_page')
   
   % Export to zip file.
   cmd = sprintf('git archive --format=zip %s --prefix=spotbox-%s/ > /tmp/spotbox-%s.zip',tag);
   system(cmd);
   
end % function spotpublish
