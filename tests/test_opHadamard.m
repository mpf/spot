function test_opHadamard
%test_opHadamard  Unit tests for the Hadamard operator

% $Id$

m = 64;

Hop  = opHadamard(m);
Hmat = double(Hop);

% Check that the matrix contains only +1/-1 entries.
assertEqual( abs(Hmat), ones(m) )

% Check: H'*H = n I
assertEqual( Hmat'*Hmat, m*eye(m) )

% Check normalized version: H'*H = I
Hop = opHadamard(m,1);
assertEqual( double(Hop'*Hop), eye(m) )
