function v = fdct_v2c(x,hdr,ac,nba)
% FDCT_V2C  Vector to Curvelet coefficient structure
%
%   FDCT_V2C(X,HDR,AC,NBA) returns a structure containing the
%   curvelet coefficients given by X. Parameters HDR, AC and
%   NBA respectively give the size of the coefficients on each
%   level, the treatment of the finest level (e.g. AC=2 for
%   wavelets), and the number of angles.

%   Copyright 2008, Gilles Hennenfent and Ewout van den Berg, Michael P. Friedlander
%   See the file COPYING.txt for full copyright information.
%   Use the command 'spot.gpl' to locate this file.

%   http://www.cs.ubc.ca/labs/scl/spot

k = prod(hdr{1}{1});
v{1}{1} = reshape(x(1:k),hdr{1}{1});
for i=2:length(hdr)+1-ac
   sz = nba * 2^floor((i-1)/2);
   ns = prod(hdr{i}{1}); % North-South
   ew = prod(hdr{i}{2}); % East-West
    
   % North
   for j=1:sz/4
      v{i}{j} = reshape(x(k+(1:ns)),hdr{i}{1});
      k = k + ns;
   end
    
   % East
   for j=1:sz/4
      v{i}{j+sz/4} = reshape(x(k+(1:ew)),hdr{i}{2});
      k = k + ew;
   end
    
   % South
   for j=1:sz/4
      v{i}{j+sz/2} = reshape(x(k+(1:ns)),hdr{i}{1});
      k = k + ns;
   end
    
   % West
   for j=1:sz/4
      v{i}{j+3*sz/4} = reshape(x(k+(1:ew)),hdr{i}{2});
      k = k + ew;
   end
end

% Wavelet
if ac == 2
   v{length(hdr)}{1} = x(k+1:end);
end
