classdef opFactorization < opSpot
%OPFACTORIZATION  Operator representing an inverse by way of a factorization.
%                 Useful to avoid multiple factorizations as in opInverse
%                 and save time by performing only forward and backsolves.

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Properties
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  properties( SetAccess = protected )
    A             % Input matrix as operator
    Ainv          % Inverse as a factorization operator
    rNorm         % Residual norm (if iterative refinement is performed)
  end

  properties( SetAccess = public )
    nitref = 3     % Default max number of iterative refinement steps
    itref_tol = 1.0e-8       % Default iterative refinement tolerance
    force_itref = false  % Force nitref steps of iterative refinement
  end

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Methods - Public
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  methods

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % opLDL. Constructor
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function op = opFactorization(name, m, n)
      % Construct operator
      op = op@opSpot(name, m, n);
      op.sweepflag    = true;
    end % function opFactorization

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Setters
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function op = set.nitref(op, val)
      op.nitref = max(0, round(val));
    end

    function op = sef.itref_tol(op, val)
      op.itref_tol = max(0, val);
    end

    function op = set.force_itref(op, val)
      if val ~= false & val ~= true
        op.force_itref = false;
      else
        op.force_itref = val;
      end
    end

  end % methods - public

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Methods - protected
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  methods( Access = protected )

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % multiply
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function y = multiply(op, x, mode)
       y = applyMultiply(op.Ainv, x, mode);
       % Perform iterative refinement if necessary / requested
       if op.nitref > 0
          r = x - applyMultiply(op.A, y, mode);
          rNorm = norm(r, 'inf');
          xNorm = norm(x, 'inf');
          nit = 0;
          while nit < op.nitref & (rNorm >= op.itref_tol * xNorm | op.force_itref)
             dy = applyMultiply(op.Ainv, r, mode);
             y = y + dy;
             r = x - applyMultiply(op.A, y, mode);
             rNorm = norm(r, 'inf');
             nit = nit + 1;
          end
          op.rNorm = rNorm;
       end
    end % function multiply

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % divide
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function x = divide(op, b, mode)
       x = op.A * b;
    end % function divide

  end % methods - protected

end % classdef
