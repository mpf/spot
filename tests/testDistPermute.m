function testDistPermute

x = matlabpool('size');
if ~x
    matlabpool 10;
    x = 10;
end
x = 5*x;

for i = 3:5
    a1 = rand(x:(x+i-1));
    a2 = distributed(a1);
    
    p = perms(1:i);
    for j = 1:length(p)
        d = randi(i);
        b1 = permute(a1,p(j,:));
        b2 = DistPermute(a2,p(j,:),d);
        assertEqual(b1,gather(b2));
    end
    fprintf('%i dimensions complete\n', i)
end