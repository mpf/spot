function c = strcmpc(s1,s2)
% STRCMPC  - String comparison using C-convention
%	STRCMPC(S1,S2) returns :
%    < 0	S1 less than S2
%    = 0	S1 identical to S2
%    > 0	S1 greater than S2
%	See also STRCMP.

%	S. Helsen 23-09-96
%	Copyright (c) 1984-96 by VCST-VT

l=min(length(s1), length(s2));
if l==0
	if length(s1)
		c=1;
	else
		c=-1;
	end
	return
end
i=find(s1(1:l)~=s2(1:l));
if isempty(i)
	if length(s1)<length(s2)
		c=-1;
	elseif length(s1)==length(s2)
		c=0;
	else
		c=1;
	end
	return
end
i=i(1);
if s1(i)<s2(i)
	c=-1;
else
	c=1;
end
