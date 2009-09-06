function y = heaviside(x,mode)
%heaviside  The discrete Heaviside function.
  if mode == 1
     y = cumsum(x);
  else
     y = flipud(cumsum(flipud(x)));
  end
end