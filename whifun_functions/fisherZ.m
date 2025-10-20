function Z = fisherZ(r)
%FISHERZ Applies the Fisher's r-to-z transformation to correlation coefficients.
%
%   Z = FISHERZ(R)
%
%   The Fisher transformation (often called Fisher's Z-transformation) is used
%   to transform the sampling distribution of the Pearson correlation coefficient
%   (r) from a non-normal (skewed) distribution to a distribution that is
%   approximately normal. This makes the transformed variable Z more suitable
%   for statistical inference, such as calculating confidence intervals or
%   performing hypothesis tests on correlation coefficients.
%
%   The formula for the transformation is:
%       $$Z = \frac{1}{2} \ln \left( \frac{1+r}{1-r} \right)$$
%
%   Input Arguments:
%   R   - The Pearson correlation coefficient(s) (or any value between -1 and 1).
%         Can be a scalar, vector, or matrix.
%
%   Output Arguments:
%   Z   - The Fisher's Z-transformed value(s). The output has the same size as R.
%
%   Note: The input r must be in the range (-1, 1). Values of r = -1 or r = 1
%         will result in Z = -Inf or Z = Inf, respectively.
%
%   Author: Pratik Jain

    Z = 0.5.*(log(1+r)-log(1-r));
end