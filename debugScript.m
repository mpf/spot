function debugScript

randn('state',0);
errorCount = 0;

% Set up matrices and operators for problems
A  = randn(2,2) + sqrt(-1) * randn(2,2);
B  = opMatrix(A);
c  = randn(1,1) + sqrt(-1) * randn(1,1);
A  = A * c;
B  = B * c;
xr = randn(2,2);
xi = sqrt(-1) * randn(2,2);
x  = xr + xi;

% Check operator products
C = A' * 5 * A;
D = B' * 5 * B;
ensureEqual('((5*A*C)'' * A) * x',...
            '((5*B*D)'' * B) * x');
ensureEqual('((5*A*C)'' * A) * xr',...
            '((5*B*D)'' * B) * xr');
ensureEqual('((5*A*C)'' * A) * xi',...
            '((5*B*D)'' * B) * xi');
ensureEqual('(5*A*C*A) * x',...
            '(5*B*D*B) * x');
ensureEqual('(5*A*C*A) * xr',...
            '(5*B*D*B) * xr');
ensureEqual('(5*A*C*A) * xi',...
            '(5*B*D*B) * xi');
ensureEqual('double(c*ones(3,3))','double(c*(ones(3,3)''))');

% Check operator transpose
ensureEqual('A.'' * x',...
            'B.'' * x');
ensureEqual('A.'' * xr',...
            'B.'' * xr');
ensureEqual('A.'' * xi',...
            'B.'' * xi');

% Check opMatrix
ensureEqual('A * x',...
            'B * x');
ensureEqual('A * xr',...
            'B * xr');
ensureEqual('A * xi',...
            'B * xi');

% Check complex conjugate of operator
ensureEqual('A'' * x',...
            'B'' * x');
ensureEqual('A'' * xr',...
            'B'' * xr');
ensureEqual('A'' * xi',...
            'B'' * xi');

% Check 'real' command
ensureEqual('real(A)*x',...
            'real(B)*x');
ensureEqual('real(A)*xr',...
            'real(B)*xr');
ensureEqual('real(A)*xi',...
            'real(B)*xi');
ensureEqual('real(A)''*x',...
            'real(B)''*x');
ensureEqual('real(A)''*xr',...
            'real(B)''*xr');
ensureEqual('real(A)''*xi',...
            'real(B)''*xi');

% Check complex transpose of operator
ensureEqual('(A.'')*x',...
            '(B.'')*x');
ensureEqual('(A.'')''*x',...
            '(B.'')''*x');
ensureEqual('conj(A.'')*x',...
            'conj(B.'')*x');

% Check 'imag' command
ensureEqual('imag(A)*x',...
            'imag(B)*x');
ensureEqual('imag(A)*xr',...
            'imag(B)*xr');
ensureEqual('imag(A)*xi',...
            'imag(B)*xi');
ensureEqual('imag(A)''*x',...
            'imag(B)''*x');
ensureEqual('imag(A)''*xr',...
            'imag(B)''*xr');
ensureEqual('imag(A)''*xi',...
            'imag(B)''*xi');

% Check 'conj' command
ensureEqual('conj(A)*x',...
            'conj(B)*x');
ensureEqual('conj(A)*xr',...
            'conj(B)*xr');
ensureEqual('conj(A)*xi',...
            'conj(B)*xi');
ensureEqual('conj(A)''*x',...
            'conj(B)''*x');
ensureEqual('conj(A)''*xr',...
            'conj(B)''*xr');
ensureEqual('conj(A)''*xi',...
            'conj(B)''*xi');
ensureEqual('conj(c*conj(A)'')','double(conj(c*conj(B)''))');


% Check inverse and power
ensureEqual('A \ x',...
            'B \ x');
ensureEqual('inv(A) * x',...
            'inv(B) * x');
ensureEqual('(A^3) * x',...
            '(B^3) * x');
ensureEqual('(A^-3) * x',...
            '(B^-3) * x', 1e-12);

c = randn(1,1) + sqrt(-1) * randn(1,1);
A = randn(3,3) + sqrt(-1) * randn(3,3);
B = opMatrix(A);
ensureEqual('double(inv(B))',...
                   'inv(A)');
ensureEqual('double(inv(B)'')',...
                   'inv(A)''');
ensureEqual('double(inv(c*inv(B)))'  ,'A/c');
ensureEqual('double(inv(c*inv(B)''))','A''/c',1e-13);
ensureEqual('double(inv(inv(B*c)))'  ,'A*c');
ensureEqual('double(inv(inv(B*c)''))','(A*c)''');
ensureEqual('double(((c*B^3)'')^2)',...
                   '((c*A^3)'')^2', 1e-12);
ensureEqual('double((c*B^3)^2)',...
                   '(c*A^3)^2', 1e-12);
ensureEqual('double(inv(c*B)^-2)',...
                   'inv(c*A)^-2',3e-12);
ensureEqual('double(inv(c*B'')^-2)',...
                   'inv(c*A'')^-2',1e-12);
ensureEqual('double(inv(c*B^2)^-2)',...
                   'inv(c*A^2)^-2',1e-8);
ensureEqual('double((inv(c*B^2)'')^-2)',...
                   '(inv(c*A^2)'')^-2',2e-8);
ensureEqual('double(inv(c*B)^-2)',...
                   'inv(c*A)^-2')
ensureEqual('double((inv(c*B)'')^-2)',...
                   '(inv(c*A)'')^-2');

% Check indexing
A = randn(4,5);
B = opMatrix(A);
idx1 = [1,3];
idx2 = [2,4,5];
ensureEqual('A(:,:)',...
            'double(B(:,:))');
ensureEqual('A(:)',...
            'B(:)');
ensureEqual('A(idx1,idx2)',...
            'double(B(idx1,idx2))');
ensureEqual('A(idx1,:)',...
            'double(B(idx1,:))');
ensureEqual('A(:,idx2)',...
            'double(B(:,idx2))');
ensureEqual('A(end-2:end,1:end)',...
            'double(B(end-2:end,1:end))');

% Indexing with absolute indices
idx1 = [1,2,3,5; 6,10,11,18]';
%B.counter = 'bcounter';
ensureEqual('A(idx1)',...
            'B(idx1)');
%if ~all(evalin('base','bcounter') == [0,3])
%   fprintf('Error: Something wrong with absolute indexing\n');
%   errorCount = errorCount + 1;
%end

idx2 = [1,2,3,9; 11,12,17,18]';
%B.counter = 'bcounter';
ensureEqual('A(idx2)',...
            'B(idx2)');
%if ~all(evalin('base','bcounter') == [3,0])
%   fprintf('Error: Something wrong with absolute indexing\n');
%   errorCount = errorCount + 1;
%end

% Indexing with logical array
mask1 = zeros(size(A)); mask1(idx1) = 1; mask1 = (mask1 > 0.5);
%B.counter = 'bcounter';
ensureEqual('A(mask1)',...
            'B(mask1)');
%if ~all(evalin('base','bcounter') == [0,3])
%   fprintf('Error: Something wrong with logical indexing\n');
%   errorCount = errorCount + 1;
%end

mask2 = zeros(size(A)); mask2(idx2) = 1; mask2 = (mask2 > 0.5);
%B.counter = 'bcounter';
ensureEqual('A(mask2)',...
            'B(mask2)');
%if ~all(evalin('base','bcounter') == [3,0])
%   fprintf('Error: Something wrong with logical indexing\n');
%   errorCount = errorCount + 1;
%end

mask3 = [true, false, true];
%B.counter = 'bcounter';
ensureEqual('A(mask3)',...
            'B(mask3)');
%if ~all(evalin('base','bcounter') == [1,0])
%   fprintf('Error: Something wrong with logical indexing\n');
%   errorCount = errorCount + 1;
%end

% evalin('base','clear bcounter');


% =====================================================================
% Operator checks
% =====================================================================

% Operator Toeplitz
cols = [10,10,5]; rows = [10,5,10];
for i=1:length(cols)
   % Create matrix
   T = zeros(rows(i),cols(i));
   v = randn(rows(i)+cols(i)-1,1) + sqrt(-1)*randn(rows(i)+cols(i)-1,1);
   n = length(v);
   for j=1:cols(i)
      T(:,j) = [v(end-j+2:min(n,n+rows(i)+1-j)); v(1:rows(i)+1-j)];
   end

   for normalize=[false,true]
      M = T(1:rows(i),1:cols(i));
      if normalize
         MatToeplitz = M * spdiags(1./sqrt(sum(abs(M.*M))'),0,size(M,2),size(M,2));
      else
         MatToeplitz = M; 
      end
      OpToeplitz  = opToeplitz(rows(i),cols(i),v,'toeplitz',normalize);

      ensureEqual('double(OpToeplitz)','MatToeplitz');
      ensureEqual('double(OpToeplitz'')','MatToeplitz''');
   end
end


% Operator Toeplitz -- Circular
v = randn(10,1)+sqrt(-1)*randn(10,1);
T = zeros(10,10);
for i=1:10
   T(:,i) = [v(12-i:10); v(1:11-i)];
end

cols = [10,10,5]; rows = [10,5,10];
for normalize=[false,true]
   for i=1:length(cols)
      M = T(1:rows(i),1:cols(i));
      if normalize
         MatToeplitz = M * spdiags(1./sqrt(sum(abs(M.*M))'),0,size(M,2),size(M,2));
      else
         MatToeplitz = M; 
      end
      OpToeplitz  = opToeplitz(rows(i),cols(i),v,'circular',normalize);

      ensureEqual('double(OpToeplitz)','MatToeplitz');
      ensureEqual('double(OpToeplitz'')','MatToeplitz''');
   end
end


% One-dimensional convolution -- Cyclic
f = randn(4,1);
g = randn(2,1); C = opConvolve(4,1,g,1,'cyclic');
ensureEqual('C*f','debugConv(f,g,1,''cyclic'')');
ensureEqual('double(C)''','double(C'')');

g = randn(9,1); C = opConvolve(4,1,g,1,'cyclic');
ensureEqual('C*f','debugConv(f,g,1,''cyclic'')');
ensureEqual('double(C)''','double(C'')');

f = randn(4,1) + sqrt(-1) * randn(4,1);
g = randn(7,1); C = opConvolve(4,1,g,3,'cyclic');
ensureEqual('C*f','debugConv(f,g,3,''cyclic'')');
ensureEqual('double(C)''','double(C'')');

g = randn(8,1) + sqrt(-1) * randn(8,1);
C = opConvolve(4,1,g,-2,'cyclic');
ensureEqual('C*f','debugConv(f,g,-2,''cyclic'')');
ensureEqual('double(C)''','double(C'')');

f = randn(4,1);
C = opConvolve(4,1,g,12,'cyclic');
ensureEqual('reshape(C*f(:),size(f))','debugConv(f,g,12,''cyclic'')');
ensureEqual('double(C)''','double(C'')');


% Two-dimensional convolution -- Cyclic
f = randn(4,5);
g = randn(2,2); C = opConvolve(4,5,g,[1,1],'cyclic');
ensureEqual('reshape(C*f(:),size(f))','debugConv(f,g,[1,1],''cyclic'')');
ensureEqual('double(C)''','double(C'')');

g = randn(2,9); C = opConvolve(4,5,g,[1,1],'cyclic');
ensureEqual('reshape(C*f(:),size(f))','debugConv(f,g,[1,1],''cyclic'')');
ensureEqual('double(C)''','double(C'')');

g = randn(9,2); C = opConvolve(4,5,g,[1,1],'cyclic');
ensureEqual('reshape(C*f(:),size(f))','debugConv(f,g,[1,1],''cyclic'')');
ensureEqual('double(C)''','double(C'')');

g = randn(7,10); C = opConvolve(4,5,g,[1,1],'cyclic');
ensureEqual('reshape(C*f(:),size(f))','debugConv(f,g,[1,1],''cyclic'')');
ensureEqual('double(C)''','double(C'')');

g = randn(7,10); C = opConvolve(4,5,g,[3,-2],'cyclic');
ensureEqual('reshape(C*f(:),size(f))','debugConv(f,g,[3,-2],''cyclic'')');
ensureEqual('double(C)''','double(C'')');

f = randn(4,5) + sqrt(-1) * randn(4,5);
g = randn(7,11); C = opConvolve(4,5,g,[-1,20],'cyclic');
ensureEqual('reshape(C*f(:),size(f))','debugConv(f,g,[-1,20],''cyclic'')');
ensureEqual('double(C)''','double(C'')');

g = randn(12,1) + sqrt(-1) * randn(12,1);
C = opConvolve(4,5,g,[20,-1],'cyclic');
ensureEqual('reshape(C*f(:),size(f))','debugConv(f,g,[20,-1],''cyclic'')');
ensureEqual('double(C)''','double(C'')');

f = randn(4,5);
C = opConvolve(4,5,g,[0,1],'cyclic');
ensureEqual('reshape(C*f(:),size(f))','debugConv(f,g,[0,1],''cyclic'')');
ensureEqual('double(C)''','double(C'')');


% One-dimensional convolution - Regular and truncated
f = randn(4,1); g = randn(2,1);
C = opConvolve(4,1,g,1,'regular');
ensureEqual('C*f','debugConv(f,g,1,''regular'')');
ensureEqual('double(C)''','double(C'')');
C = opConvolve(4,1,g,1,'truncated');
ensureEqual('C*f','debugConv(f,g,1,''truncated'')');
ensureEqual('double(C)''','double(C'')');

g = randn(9,1);
C = opConvolve(4,1,g,1,'regular');
ensureEqual('C*f','debugConv(f,g,1,''regular'')');
ensureEqual('double(C)''','double(C'')');
C = opConvolve(4,1,g,1,'truncated');
ensureEqual('C*f','debugConv(f,g,1,''truncated'')');
ensureEqual('double(C)''','double(C'')');

f = randn(4,1) + sqrt(-1) * randn(4,1);
g = randn(7,1);
C = opConvolve(4,1,g,3,'regular');
ensureEqual('C*f','debugConv(f,g,3,''regular'')');
ensureEqual('double(C)''','double(C'')');
C = opConvolve(4,1,g,3,'truncated');
ensureEqual('C*f','debugConv(f,g,3,''truncated'')');
ensureEqual('double(C)''','double(C'')');

g = randn(8,1) + sqrt(-1) * randn(8,1);
C = opConvolve(4,1,g,-2,'regular');
ensureEqual('C*f','debugConv(f,g,-2,''regular'')');
ensureEqual('double(C)''','double(C'')');
C = opConvolve(4,1,g,-2,'truncated');
ensureEqual('C*f','debugConv(f,g,-2,''truncated'')');
ensureEqual('double(C)''','double(C'')');

f = randn(4,1);
C = opConvolve(4,1,g,12,'regular');
ensureEqual('C*f','debugConv(f,g,12,''regular'')');
ensureEqual('double(C)''','double(C'')');
C = opConvolve(4,1,g,12,'truncated');
ensureEqual('C*f','debugConv(f,g,12,''truncated'')');
ensureEqual('double(C)''','double(C'')');


% Two-dimensional convolution -- Regular and truncated
f = randn(4,5);
g = randn(2,2);
C = opConvolve(4,5,g,[1,1],'regular');
ensureEqual('reshape(C*f(:),5,6)','debugConv(f,g,[1,1],''regular'')');
ensureEqual('double(C)''','double(C'')');
C = opConvolve(4,5,g,[1,1],'truncated');
ensureEqual('reshape(C*f(:),size(f))','debugConv(f,g,[1,1],''truncated'')');
ensureEqual('double(C)''','double(C'')');

g = randn(2,9);
C = opConvolve(4,5,g,[1,1],'regular');
ensureEqual('reshape(C*f(:),5,13)','debugConv(f,g,[1,1],''regular'')');
ensureEqual('double(C)''','double(C'')');
C = opConvolve(4,5,g,[1,1],'truncated');
ensureEqual('reshape(C*f(:),size(f))','debugConv(f,g,[1,1],''truncated'')');
ensureEqual('double(C)''','double(C'')');

g = randn(9,2);
C = opConvolve(4,5,g,[1,1],'regular');
ensureEqual('reshape(C*f(:),12,6)','debugConv(f,g,[1,1],''regular'')');
ensureEqual('double(C)''','double(C'')');
C = opConvolve(4,5,g,[1,1],'truncated');
ensureEqual('reshape(C*f(:),size(f))','debugConv(f,g,[1,1],''truncated'')');
ensureEqual('double(C)''','double(C'')');

g = randn(7,10);
C = opConvolve(4,5,g,[1,1],'regular');
ensureEqual('reshape(C*f(:),10,14)','debugConv(f,g,[1,1],''regular'')');
ensureEqual('double(C)''','double(C'')');
C = opConvolve(4,5,g,[1,1],'truncated');
ensureEqual('reshape(C*f(:),size(f))','debugConv(f,g,[1,1],''truncated'')');
ensureEqual('double(C)''','double(C'')');

g = randn(7,10);
C = opConvolve(4,5,g,[3,-2],'regular');
ensureEqual('reshape(C*f(:),10,17)','debugConv(f,g,[3,-2],''regular'')');
ensureEqual('double(C)''','double(C'')');
C = opConvolve(4,5,g,[3,-2],'truncated');
ensureEqual('reshape(C*f(:),size(f))','debugConv(f,g,[3,-2],''truncated'')');
ensureEqual('double(C)''','double(C'')');

f = randn(4,5) + sqrt(-1) * randn(4,5);
g = randn(7,11);
C = opConvolve(4,5,g,[-1,20],'regular');
ensureEqual('reshape(C*f(:),12,24)','debugConv(f,g,[-1,20],''regular'')');
ensureEqual('double(C)''','double(C'')');
C = opConvolve(4,5,g,[-1,20],'truncated');
ensureEqual('reshape(C*f(:),size(f))','debugConv(f,g,[-1,20],''truncated'')');
ensureEqual('double(C)''','double(C'')');

g = randn(12,1) + sqrt(-1) * randn(12,1);
C = opConvolve(4,5,g,[20,-1],'regular');
ensureEqual('reshape(C*f(:),23,7)','debugConv(f,g,[20,-1],''regular'')');
ensureEqual('double(C)''','double(C'')');
C = opConvolve(4,5,g,[20,-1],'truncated');
ensureEqual('reshape(C*f(:),size(f))','debugConv(f,g,[20,-1],''truncated'')');
ensureEqual('double(C)''','double(C'')');

f = randn(4,5);
C = opConvolve(4,5,g,[0,1],'regular');
ensureEqual('reshape(C*f(:),16,5)','debugConv(f,g,[0,1],''regular'')');
ensureEqual('double(C)''','double(C'')');
C = opConvolve(4,5,g,[0,1],'truncated');
ensureEqual('reshape(C*f(:),size(f))','debugConv(f,g,[0,1],''truncated'')');
ensureEqual('double(C)''','double(C'')');


% Kronecker product
A1 = randn(3,4) + sqrt(-1) * randn(3,4);
A2 = randn(3,2) + sqrt(-1) * randn(3,2);
A3 = randn(2,2) + sqrt(-1) * randn(2,2);
A  = kron(A1,kron(A2,A3));
B  = kron(opMatrix(A1),kron(opMatrix(A2),opMatrix(A3)));
x  = randn(size(A,1),2) + sqrt(-1)*randn(size(A,1),2);
y  = randn(size(A,2),2) + sqrt(-1)*randn(size(A,2),2);
ensureEqual('A*y',...
            'B*y',3e-14);
ensureEqual('A''*x',...
            'B''*x',3e-14);
ensureEqual('A','double(B)');
ensureEqual('A''','double(B'')');


% =====================================================================
% Final report
% =====================================================================
if errorCount == 0
   fprintf('All tests were passed successfully!\n');
end



function ensureEqual(cmdA,cmdB,tol)
   if nargin < 3, tol = 1e-14; end;

   diff = eval(sprintf('abs((%s)-(%s))',cmdA,cmdB));
   if ~all(diff < tol)
      [ST,I] = dbstack;
      fprintf('Error on line %d: %s and %s differ by %e!\n',ST(2).line,cmdA,cmdB,max(max(diff)));
      errorCount = errorCount + 1;
   end
end

end
