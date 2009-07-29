function r = isposintmat(m)

r = all(all( (round(m) == m) & (m > 0) ));