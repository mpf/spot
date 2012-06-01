clear all
A = Fog(randn(3,3),randn(3));
for i=1:13
    tic;
    A  = randn(3,3) * A;
    t1 = toc;
    sa = whos('A');
    tic;
    b  = A * randn(3,1);
    t2 = toc;
    fprintf('Atic=%f bytes=%d btic=%f\n',t1,sa.bytes,t2);
end
