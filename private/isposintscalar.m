function r = isposintscalar(s)

r = isscalar(s) && (round(s) == s) && s > 0;
