function spotpublish(tag)
%spotpublish  Generate Spot documentation.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   See the file COPYING.txt for full copyright information.
%   Use the command 'spot.gpl' to locate this file.

%   http://www.cs.ubc.ca/labs/scl/spot

   if nargin < 1 || isempty(tag)
      error('tag required')
   end

   % Documentation pages
   cd(fullfile(spot.path,'doc'))
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
   publish('spot_main_page.m',opts);
   
   % Export to zip file.
   cd(spot.path)
   cmd = sprintf('git archive --format=zip %s --prefix=spotbox-%s/ > /tmp/spotbox-%s.zip',...
      tag,tag,tag);
   system(cmd);
   
   % Add html dir to zip archive.
   htmldir = fullfile(spot.path,'doc','html');
   cmd = sprintf('zip -u /tmp/spotbox-%s.zip %s/*',tag,htmldir);
   system(cmd);
   
end % function spotpublish
