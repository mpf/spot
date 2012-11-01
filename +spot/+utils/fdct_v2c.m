function v = fdct_v2c(x,hdr)
% FDCT_V2C  Vector to Curvelet coefficient structure
%
%   FDCT_V2C(X,HDR) returns a structure containing the
%   curvelet coefficients given by X. Parameters HDR gives
%   the size of the coefficients on each level.

%   Nameet Kumar - Oct 2010
%   Copyright 2008, Gilles Hennenfent and Ewout van den Berg, Michael P. Friedlander
%   See the file COPYING.txt for full copyright information.
%   Use the command 'spot.gpl' to locate this file.

%   http://www.cs.ubc.ca/labs/scl/spot
s = prod(hdr{1}{1});
v = cell(size(hdr));
v{1}{1} = reshape(x(1:s),hdr{1}{1});
not_finest = hdr{end}{end} == 1;
for i = 2:length(hdr) - not_finest   %each scale (treat last one seperately 
   %if we're not set to finest)
   
   n = hdr{i}{end};
   
   if length(hdr{1}{1}) == 3     %preallocate
      v{i} = cell(n*2*3,1);    
   else
      v{i} = cell(1,n*2*2);
   end
   for j = 1:2          %each size twice
      
      ind = (j-1)*(length(hdr{i})-1)*n;
      for k = 1:length(hdr{i})-1    %each size
         
         if k > 1, ind = ind + n; end
         elms = prod(hdr{i}{k});
         for l = 1:n    %do each size n times
            
            v{i}{ind+l} = reshape(x(s+(1:elms)),hdr{i}{k});
            s = s + elms;
         end
      end
   end
end
if not_finest
      v{end}{1} = reshape(x(s+(1:prod(hdr{end}{1}))),hdr{end}{1});
end
