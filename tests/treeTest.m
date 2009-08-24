% tree test function

clear all;

A1=opMatrix(randn(30,35));
A2=opEye(35,15);
A3=opToepSign(15,5);
A4=opToepGauss(5,10);
A5=opOnes(10,20);
A6=opZeros(20,25);

sA1=size(A1);
sA2=size(A2);
sA3=size(A3);
sA4=size(A4);
sA5=size(A5);
sA6=size(A6);

%% text example
B = A1*A2*A3*A4*A5*A6;
Btree = buildTree(B);
figure(1); h1 = axes;
graphTree(Btree, h1,'graphB.txt');
[preFlops, preMul, preAdd]=calculateFlops(Btree);
title(['Pre-optimized flops: ', num2str(preFlops), ...
    ' Pre-optimized multiplications: ', num2str(preMul),...
    ' Pre-optimized additions: ', num2str(preAdd)]);

C = optimalBracketing(B);
Ctree = buildTree(C);
figure(2); h2 = axes;
graphTree(Ctree, h2, 'graphC.txt');
[postFlops, postMul, postAdd]=calculateFlops(Ctree);
title(['Post-optimized flops: ', num2str(postFlops), ...
    ' Post-optimized multiplications: ', num2str(postMul),...
    ' Post-optimized additions: ', num2str(postAdd)]);

%% text example transpose
B1 = A6'*(A2*A3*A4*A5)'*A1';
B1tree = buildTree(B1);
figure(3); h3 = axes;
graphTree(B1tree, h3,'graphB1.txt');
[preFlops, preMul, preAdd]=calculateFlops(B1tree);
title(['Pre-optimized flops: ', num2str(preFlops), ...
    ' Pre-optimized multiplications: ', num2str(preMul),...
    ' Pre-optimized additions: ', num2str(preAdd)]);

C1 = optimalBracketing(B1);
C1tree = buildTree(C1);
figure(4); h4 = axes;
graphTree(C1tree, h4, 'graphC1.txt');
[postFlops, postMul, postAdd]=calculateFlops(C1tree);
title(['Post-optimized flops: ', num2str(postFlops), ...
    ' Post-optimized multiplications: ', num2str(postMul),...
    ' Post-optimized additions: ', num2str(postAdd)]);

%% text example with scalers
B2 = A1*opMatrix(10)*A2*A3*opMatrix(1/9)*A4*A5*A6;
B2tree = buildTree(B2);
figure(5); h5 = axes;
graphTree(B2tree, h5,'graphB2.txt');
[preFlops, preMul, preAdd]=calculateFlops(B2tree);
title(['Pre-optimized flops: ', num2str(preFlops), ...
    ' Pre-optimized multiplications: ', num2str(preMul),...
    ' Pre-optimized additions: ', num2str(preAdd)]);

C2 = optimalBracketing(B2);
C2tree = buildTree(C2);
figure(6); h6 = axes;
graphTree(C2tree, h6, 'graphC2.txt');
[postFlops, postMul, postAdd]=calculateFlops(C2tree);
title(['Post-optimized flops: ', num2str(postFlops), ...
    ' Post-optimized multiplications: ', num2str(postMul),...
    ' Post-optimized additions: ', num2str(postAdd)]);

%% test with sums and differences
% case checking optimization happens at the top level
B3 = (A1+randn(size(A1)))*(A2-randn(size(A2)))*A3*A4*(A5*A6+randn(sA5(1),sA6(2)));
B3tree = buildTree(B3);
figure(7); h7 = axes;
graphTree(B3tree, h7,'graphB3.txt');
[preFlops, preMul, preAdd]=calculateFlops(B3tree);
title(['Pre-optimized flops: ', num2str(preFlops), ...
    ' Pre-optimized multiplications: ', num2str(preMul),...
    ' Pre-optimized additions: ', num2str(preAdd)]);

C3 = optimalBracketing(B3);
C3tree = buildTree(C3);
figure(8); h8 = axes;
graphTree(C3tree, h8, 'graphC3.txt');
[postFlops, postMul, postAdd]=calculateFlops(C3tree);
title(['Post-optimized flops: ', num2str(postFlops), ...
    ' Post-optimized multiplications: ', num2str(postMul),...
    ' Post-optimized additions: ', num2str(postAdd)]);

% case checking optimization happens inside the summation(i.e. below the
% top level)
B4 = (A1+randn(size(A1)))*(A2-randn(size(A2)))*(A3*A4*A5*A6+A3*A4*A5*A6);
B4tree = buildTree(B4);
figure(9); h9 = axes;
graphTree(B4tree, h9,'graphB4.txt');
[preFlops, preMul, preAdd]=calculateFlops(B4tree);
title(['Pre-optimized flops: ', num2str(preFlops), ...
    ' Pre-optimized multiplications: ', num2str(preMul),...
    ' Pre-optimized additions: ', num2str(preAdd)]);

C4 = optimalBracketing(B4);
C4tree = buildTree(C4);
figure(10); h10 = axes;
graphTree(C4tree, h10, 'graphC4.txt');
[postFlops, postMul, postAdd]=calculateFlops(C4tree);
title(['Post-optimized flops: ', num2str(postFlops), ...
    ' Post-optimized multiplications: ', num2str(postMul),...
    ' Post-optimized additions: ', num2str(postAdd)]);

%% test with concatenation
B5 = [A1(1:2, :); A1(3:4, :); A1(5:end, :)]*[A2(:, 1:2), A2(:, 3:4), A2(:,5:8), A2(:,9:end)]*...
    A3*A4*A5*A6;
B5tree = buildTree(B5);
figure(11); h11 = axes;
graphTree(B5tree, h11,'graphB5.txt');
[preFlops, preMul, preAdd]=calculateFlops(B5tree);
title(['Pre-optimized flops: ', num2str(preFlops), ...
    ' Pre-optimized multiplications: ', num2str(preMul),...
    ' Pre-optimized additions: ', num2str(preAdd)]);

C5 = optimalBracketing(B5);
C5tree = buildTree(C5);
figure(12); h12 = axes;
graphTree(C5tree, h12, 'graphC5.txt');
[postFlops, postMul, postAdd]=calculateFlops(C5tree);
title(['Post-optimized flops: ', num2str(postFlops), ...
    ' Post-optimized multiplications: ', num2str(postMul),...
    ' Post-optimized additions: ', num2str(postAdd)]);
%% test with slicing
% B6 = A1*A2*[B1(1:2, 1:sA3(2)); B2(3:4, 1:sA3(2)); B3(5:sA3(1), 1:sA3(2))]*A4*A5*A6;
% B6tree = buildTree(B6);
% figure(13); h13 = axes;
% graphTree(B6tree, h13,'graphB6.txt');
% [preFlops, preMul, preAdd]=calculateFlops(B6tree);
% title(['Pre-optimized flops: ', num2str(preFlops), ...
%     ' Pre-optimized multiplications: ', num2str(preMul),...
%     ' Pre-optimized additions: ', num2str(preAdd)]);
% 
% C6 = optimalBracketing(B6);
% C6tree = buildTree(C6);
% figure(14); h14 = axes;
% graphTree(C6tree, h14, 'graphC6.txt');
% [postFlops, postMul, postAdd]=calculateFlops(C6tree);
% title(['Post-optimized flops: ', num2str(postFlops), ...
%     ' Post-optimized multiplications: ', num2str(postMul),...
%     ' Post-optimized additions: ', num2str(postAdd)]);