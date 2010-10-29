function v = mefdct_v2c(x,hdr,nba)
% MEFDCT_V2C  Vector to mirror-extended curvelet coefficients
%   MEFDCT_V2C(X,HDR,NBA) returns a structure containing the
%   mirror-extended curvelet coefficients given by X. Parameters
%   HDR and NBA respectively give the size of the coefficients on
%   each and the number of angles.

%   Copyright 2008, Gilles Hennenfent and Ewout van den Berg
%   http://www.cs.ubc.ca/labs/scl/sparco
%   $Id: mefdct_v2c.m 1040 2008-06-26 20:29:02Z ewout78 $

k = prod(hdr{1}{1});
v{1}{1} = reshape(x(1:k),hdr{1}{1});

for i=2:length(hdr)
   sz = nba/4 * 2^floor((i-1)/2);
   ns = prod(hdr{i}{1}); % North-South
   ew = prod(hdr{i}{2}); % East-West
   
   % North
   for j=1:sz/2
      v{i}{j} = reshape(x(k+(1:ns)),hdr{i}{1});
      k = k + ns;
   end
    
   % East
   for j=1:sz/2
      v{i}{j+sz/2} = reshape(x(k+(1:ew)),hdr{i}{2});
      k = k + ew;
   end
end
