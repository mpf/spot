%clear all
%clc
A = opMatrix(randn(3,3));
for i=1:14
    tic;
    A  = randn(3,3) * A;
    t1 = toc;
    sa = whos('A');
    tic;
    b  = A * randn(3,1);
    t2 = toc;
    fprintf('Atic=%f bytes=%d btic=%f\n',t1,sa.bytes,t2);
end
%pause
%clear all
