function spotpublish(tag)
%SPOTPUBLISH  Generate Spot documentation.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   See the file COPYING.txt for full copyright information.
%   Use the command 'spot.gpl' to locate this file.

%   http://www.cs.ubc.ca/labs/scl/spot

   if nargin < 1 || isempty(tag)
      error('tag required')
   end

   % Export to zip file.
   cd(spot.path)
   cmd = sprintf('git archive %s --prefix=spotbox-%s/ | tar -x -C /tmp',tag,tag);
   system(cmd);
   
   % Generate HTML files
   cd(sprintf('/tmp/spotbox-%s/doc',tag));
   generatehtml;
   
   % Create archive
   cd(sprintf('/tmp',tag));
   cmd = sprintf('zip -r spotbox-%s.zip spotbox-%s',tag,tag);
   system(cmd);
   cd(spot.path)
      
end % function spotpublish

function generatehtml
   %generatehtml  Generage HTML documentation
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
end % function generatehtml   
