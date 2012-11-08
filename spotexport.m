function spotexport(tag)
%SPOTEXPORT  Exports Spot to a zip file.
% Uses the version of Spot most recently commited to git. In order to use
% the most up-to-date help browser files, run spothelpbrowser and commit
% before running spotexport.

%   Copyright 2009, Ewout van den Berg and Michael P. Friedlander
%   See the file COPYING.txt for full copyright information.
%   Use the command 'spot.gpl' to locate this file.

%   http://www.cs.ubc.ca/labs/scl/spot

   if nargin < 1 || isempty(tag)
      error('tag required')
   end
      
   % Export to folder in /tmp
   cd(spot.path)
   cmd = sprintf('git archive --format=tar --prefix=spotbox-%s/ HEAD | (cd /tmp && tar xf -)',tag);
 
   system(cmd);
   
   % Compress folder into zip file
   cd(sprintf('/tmp'));
   cmd = sprintf('zip -r spotbox-%s.zip spotbox-%s',tag,tag);
   system(cmd);
   cd(spot.path)
      
end % function spotexport
