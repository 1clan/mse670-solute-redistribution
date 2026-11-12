function out = won_thomas_model(k, c0, Ds, tf, lambda2, fs, alphaC)
%WON_THOMAS_MODEL  Coarsening-corrected Clyne-Kurz microsegregation model.
%
%   out = won_thomas_model(k, c0, Ds, tf, lambda2, fs, alphaC)
%
%   Won and Thomas (2001) approximate the effect of dendrite coarsening by
%   replacing the Fourier number alpha in the Clyne-Kurz parameter with
%
%       alpha+ = 2*(alpha + alphaC),   alphaC = 0.1
%
%   The factor of two extends the result to columnar dendrites, and the extra
%   alphaC accounts for the smaller arm spacing present before coarsening is
%   complete. The concentration relation is unchanged:
%
%       Cl/c0 = [1 - (1 - beta*k)*fs]^((k-1)/(1 - beta*k))
%       beta  = 2*alpha+*(1 - exp(-1/alpha+)) - exp(-1/(2*alpha+))
%
%   This is an approximate correction, not a full coarsening model. The
%   empirical secondary-dendrite-arm-spacing fits in the Won-Thomas paper are
%   steel-specific and are not applied here.
%
%   Inputs
%       k        partition coefficient, k > 0 (not restricted to k <= 1)
%       c0       nominal composition
%       Ds       solid diffusivity (m^2/s)
%       tf       local solidification time (s)
%       lambda2  secondary dendrite arm spacing (m)
%       fs       solid fraction, 0 <= fs <= 1 (scalar or array)
%       alphaC   optional coarsening constant (default 0.1)
%
%   Outputs (struct)
%       out.alpha      base Fourier number, 4*Ds*tf/lambda2^2
%       out.alphaWT    corrected Fourier number, 2*(alpha + alphaC)
%       out.alphaEff   alias of alphaWT
%       out.beta       coarsening-corrected back-diffusion parameter
%       out.Cl         liquid composition
%       out.CsStar     interface solid composition, k*Cl
%       out.CsAvg      average solid composition
%       out.ClAvg      average liquid composition
%
%   Example (Al-4.8 wt.% Cu at 648 C)
%       out = won_thomas_model(0.173, 4.8, 4.8e-15, 100, 20e-6, 0.9)
%       % alphaWT = 0.2096, beta = 0.3236

if nargin < 7 || isempty(alphaC)
    alphaC = 0.1;
end

out = clyne_kurz_model(k, c0, Ds, tf, lambda2, fs, alphaC, true);
out.alphaWT = out.alphaEff;
end
