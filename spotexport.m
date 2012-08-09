function spotexport(tag)
%SPOTPUBLISH  Exports Spot to a zip file.

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
   
   % Update help browser files
   addpath('doc');
   run spothelpbrowser
   
   % Create archive
   cd(sprintf('/tmp',tag));
   cmd = sprintf('zip -r spotbox-%s.zip spotbox-%s',tag,tag);
   system(cmd);
   cd(spot.path)
      
end % function spotexport
