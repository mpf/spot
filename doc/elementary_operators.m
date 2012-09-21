%% Elementary operators
% The most elementary operators are created with the following commands.
%
% * <htmlhelp/opDirac.html opDirac> - Dirac basis
% * <htmlhelp/opEmpty.html opEmpty> - Operator equivalent to empty matrix
% * <htmlhelp/opEye.html opEye> - Identity operator
% * <htmlhelp/opOnes.html opOnes> - Operator equivalent to ones function
% * <htmlhelp/opZeros.html opZeros> - Operator equivalent to zeros function

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
%
