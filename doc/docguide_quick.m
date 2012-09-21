%% A quick guide to Spot 
% Using explicit matrices is not practical for some very large problems.
% Instead, we can use Spot operators. A Spot operator represents a matrix,
% and can be treated in a similar way, but it doesn't rely on the matrix
% itself to implement most of the methods. This short guide will show you
% how to make and use Spot operators.

%% Creating Operators
% Create a new operator using the constructor from the appropriate
% operator class. For example, to make an operator A that consists of all
% ones, with three rows and two columns, use the <matlab:doc('opOnes') opOnes> class:

A = opOnes(3,2)

%%
% We see that Spot displays some information about A when we leave off the
% semicolon, such as its construction, the number of rows and columns, and
% whether it is complex. We can also use the <matlab:doc('opSpot/double') double>
% method to construct the underlying matrix:

double(A)

%%
% Operators can be easily added or subtracted. For example, make an
% operator B consisting of all twos and add it to A:

B = 2*opOnes(3,2);
C = A + B;
double(C)

%%
% If you add a matrix and an operator, Spot will first automatically
% convert the matrix into a Spot operator using opMatrix. We can discover
% other information about the operator C by using the methods
% <matlab:doc('opSpot/size') size>,
% <matlab:doc('opSpot/disp') disp>,
% and <matlab:doc('opSpot/whos') whos>:

whos C

%% Applying Operators
% Spot operators can be multiplied by vectors just like MATLAB matrices.
% Make a vector x and apply C to it:

x = [1;2];
y = C*x

%%
% We can also multiply by the adjoint of an operator:

w = [1;2;3];
z = C'*w;

%% Subset Assignment and Reference
% If we are only interested in applying part of an operator, we can create
% a new operator that is a restriction of the existing one. The indexing
% used is the same as in MATLAB matrices; we can specify rows, columns, or
% individual elements, we can extract rows or columns in reverse, and we
% can repeat entries:

x = [1;2;3;4;5];
A = opDiag(x); % Create a 5x5 operator with x's values on its diagonal
B = A(2:4,:);  % Extract rows 2-4 of A
double(B)

%%
% We can also assign values to a subset of an operator, again using the same
% syntax as in MATLAB matrices. The row and column indices we specify don't
% have to be within those of the original operator. In fact, we can specify
% indices that don't overlap at all with the original operator, and we will
% simply end up with a larger operator. Zero out part of A:

A(1:2,:) = 0;
double(A)

%%
% Assign a new operator, C, to a subset of B:

C = opOnes(2,2);
B(2:3,1:2) = C;
double(B)

%% Creating More Complex Operators
% Spot operators can be combined into more complex operators using methods
% such as blkdiag and kron. Whenever a matrix is passed to one of these
% methods, it is automatically converted to a Spot operator.
% <matlab:doc('opSpot/blkdiag') blkdiag> takes
% a list of operators and matrices and creates a block diagonal operator:

A = opOnes(2,2);
B = 2*opOnes(3,2);
C = 3*opOnes(1,3);
D = blkdiag(A, B, C);
double(D)

%%
% We can also have the blocks overlap and create anti-diagonal operators
% (see <usingmethods.html "Using the Methods">).
% Operators can be horizontally or vertically concatenated using
% opDictionary or opStack, or simply by passing them as elements in a matrix:

E = 4*opOnes(2,3);
F = [A E];
double(F)

%%
% The <matlab:doc('opSpot/kron') kron> method
% computes the Kronecker product of an arbitrary number of operators:

G = opMatrix([2 1;3 0]);
H = opMatrix([1 2]);
K = kron(G, H);
double(K)

%% 
% For more information on how to work with Spot operators, see
% <usingmethods.html "Using the Methods">.
% For a list of methods, see the <http://www.cs.ubc.ca/labs/scl/spot/methods.html "Index of Methods">.
% For a list of the Spot operator classes and what they do, including fast
% transformations, random ensembles, and convolution, see the
% <http://www.cs.ubc.ca/labs/scl/spot/operators.html "Index of Operators">.

