%% Elementary operators
% The most elementary operators are created with the following commands.
%
% * <matlab:doc('opDirac') opDirac>        - Dirac basis
% * <matlab:doc('opEmpty') opEmpty>        - Operator equivalent to empty matrix
% * <matlab:doc('opEye') opEye>          - Identity operator
% * <matlab:doc('opOnes') opOnes>         - Operator equivalent to ones function
% * <matlab:doc('opZeros') opZeros>        - Operator equivalent to zeros function

%%
% In most cases, these elementary operators mirror the Matlab primitives.
% For example,

double(opOnes(3,2))

%%
% is equivalent to

ones(3,2)

%%
% The main difference, of course, is that |opOnes| does not create an
% explicit matrix.

