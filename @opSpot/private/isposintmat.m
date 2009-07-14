function r = isposintmat(m)
%isposintmat  returns true if input matrix is has all positive integers.

r = all(all( (round(m) == m) & (m > 0) ));
