function x = lsqrdivide(A,b)

[m,n] = size(A);
   opts = spotparams;
   maxits = opts.cgitsfact * min(m,min(n,20));
   x = spot.solvers.lsqr(m,n,A,b, ...
         opts.cgdamp,opts.cgtol,opts.cgtol,opts.conlim,maxits,opts.cgshow);