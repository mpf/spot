%% Using Spot containers
% Spot provides a set of "wrappers" that can be used to integrate
% external opertors with Spot utilities.

%% Function containers
% Suppose that we have an existing function that implements a discretized
% <http://en.wikipedia.org/wiki/Heaviside_step_function Heaviside step
% function>. This function
% returns a vector with the cumulative sum of the input vector
% (i.e., Matlab's <matlab:doc('cumsum') cumsum> function.) In the
% "adjoint" mode, our function returns the cumulative-sum vector, but in
% reverse order. Here is one simple way to implement such a function:

type heaviside.m

%%
% In order to make this function available as a Spot operator, we wrap it
% using <matlab:doc('opFunction') opFunction>:

n = 5; m = 5;
A = opFunction(n,m,@heaviside);

%%
% Note that we provide the number of rows and columns for this particular
% instance, because all Spot operators must have their dimensions defined.
% Now |A| can be used like any other Spot operator. For example:

B = A(1:2:end,:);         % B is a new operator with even rows of A
double(B)                 % print the elements of B

%% Matrix containers
% Spot's default behavior when multiplying operators with matrices is to
% apply the operator to each column of the matrix.  For example, this next
% command scales the columns of the Heaviside operator:

C = A * diag(1:m)

%%
% But if we instead want to form a new operator formed from the products of
% A and the diagonal, we first need to wrap the diagonal matrix:

C = A * opMatrix(diag(1:m))

%%
% Though in this special case, we might have as well used the Spot operator
% <matlab:doc('opDiag') opDiag> instead of the more general (and in this
% case, cumbersome) <matlab:doc('opMatrix') opMatrix>|(diag(1:m))|.

%% Class containers
% Finally, the <matlab:doc('opClass') opClass> container can be used to encapsulate
% objects defined by external toolboxes.

