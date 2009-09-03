%% A first example: building a circulant operator
%
% Circulant matrices are fully specified by their first column, and
% each remaining column is a cyclic permutation of the first:
%
% $$
% C =  \pmatrix{
%        c_1   & c_{n}          & c_{n\ ^\_ \ 1} & \ldots & c_2
%    \cr c_2   & c_1            & c_n            &        & c_3
%    \cr c_3   & c_2            & c_1            & c_n    & c_4
%    \cr \vdots&                & \ddots         &        & \vdots
%    \cr c_n   & \ldots         &                & c_2    & c_1
%     }.
% $$
%
% These matrices have the property that they can be diagonalized by the
% discrete Fourier transform (DFT), so that
%
%   C = F'diag(d)F,
%
% where d = Fc. An important implication is that |C| can be treated as a
% fast operator.

%%
% In our first example we will create an 5-by-5 circulant matrix whose
% first column is simply the sequence 1,...,5:

n = 5;
c = (1:n)';  % make sure c is a column vector

%%
% Our very first Spot command will create the required DFT operator (we
% ommit the semicolon so that Matlab will display the resulting operator):

F = opDFT(n)

%%
% The central tenet of Spot is that operators should behave very much like
% matrices. Multiplication is no exception: the following command gives the
% eigenvalues of |C|:

d = F*c;

%%
% The circulant operator is then easily built as follows:

C = F'*opDiag(d)*F

x = randn(n,1);