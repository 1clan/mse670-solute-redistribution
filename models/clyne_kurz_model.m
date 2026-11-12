function out = clyne_kurz_model(k, c0, Ds, tf, lambda2, fs, alphaC, useWT)
%CLYNE_KURZ_MODEL  Back-diffusion microsegregation model of Clyne and Kurz.
%
%   out = clyne_kurz_model(k, c0, Ds, tf, lambda2, fs)
%   out = clyne_kurz_model(k, c0, Ds, tf, lambda2, fs, alphaC, useWT)
%
%   The liquid is fully mixed, but the solid retains a finite amount of
%   back diffusion. The dimensionless Fourier number is
%
%       alpha = Ds*tf / X^2 = 4*Ds*tf / lambda2^2
%
%   with X = lambda2/2 the representative diffusion distance. Clyne and Kurz
%   replace the Brody-Flemings back-diffusion parameter beta by
%
%       beta = 2*alpha*(1 - exp(-1/alpha)) - exp(-1/(2*alpha))
%
%   which is bounded between 0 and 1. The liquid composition follows the
%   generalized back-diffusion form
%
%       Cl/c0 = [1 - (1 - beta*k)*fs]^((k-1)/(1 - beta*k))
%
%   and the interface solid obeys local equilibrium, Cs* = k*Cl. The average
%   solid composition follows from the solute balance:
%
%       CsAvg = [c0 - (1 - fs)*Cl] / fs
%
%   Limiting cases: beta -> 0 gives Scheil-Gulliver; beta -> 1 gives the
%   equilibrium lever rule.
%
%   Inputs
%       k        partition coefficient, k > 0 (not restricted to k <= 1)
%       c0       nominal composition
%       Ds       solid diffusivity (m^2/s)
%       tf       local solidification time (s)
%       lambda2  secondary dendrite arm spacing (m)
%       fs       solid fraction, 0 <= fs <= 1 (scalar or array)
%       alphaC   optional Won-Thomas coarsening constant (default 0)
%       useWT    optional flag for the Won-Thomas correction (default false)
%
%   Outputs (struct)
%       out.alpha      base Fourier number, 4*Ds*tf/lambda2^2
%       out.alphaEff   alpha used in beta (Won-Thomas corrected if requested)
%       out.beta       Clyne-Kurz back-diffusion parameter
%       out.Cl         liquid composition
%       out.CsStar     interface solid composition, k*Cl
%       out.CsAvg      average solid composition
%       out.ClAvg      average liquid composition (= Cl; liquid is mixed)
%
%   Example
%       out = clyne_kurz_model(0.3, 1.0, 1e-13, 100, 20e-6, 0.9)
%       % alpha = 0.1, beta = 0.1933, Cl/c0 = 4.051

if nargin < 7 || isempty(alphaC)
    alphaC = 0;
end
if nargin < 8 || isempty(useWT)
    useWT = false;
end

lambda2 = max(lambda2, 1e-12);
alpha = 4*Ds*tf/(lambda2^2);

if useWT
    alphaEff = 2*(alpha + alphaC);
else
    alphaEff = alpha;
end

if alphaEff <= 0
    beta = 0;
elseif isinf(alphaEff)
    beta = 1;
else
    beta = 2*alphaEff*(1 - exp(-1/alphaEff)) - exp(-1/(2*alphaEff));
end

if abs(k - 1) < 1e-12
    Cl = c0*ones(size(fs));
else
    q = beta*k - 1;
    if abs(q) < 1e-10
        Cl = c0*exp((1 - k)*fs);
    else
        Cl = c0*(1 + q*fs).^((1 - k)/q);
    end
end

CsStar = k*Cl;

CsAvg = zeros(size(fs));
small = fs < 1e-9;
if isscalar(fs)
    if small
        CsAvg = k*c0;
    elseif fs >= 1 - 1e-12
        CsAvg = c0;
    else
        CsAvg = (c0 - (1 - fs)*Cl)/fs;
    end
else
    CsAvg(small) = k*c0;
    idx = ~small & fs < 1 - 1e-12;
    CsAvg(idx) = (c0 - (1 - fs(idx)).*Cl(idx))./fs(idx);
    CsAvg(fs >= 1 - 1e-12) = c0;
end

out.alpha = alpha;
out.alphaEff = alphaEff;
out.beta = beta;
out.Cl = Cl;
out.CsStar = CsStar;
out.CsAvg = CsAvg;
out.ClAvg = Cl;
end
