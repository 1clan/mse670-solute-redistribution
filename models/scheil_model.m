function [Cs, Cl, CsAvg, ClAvg] = scheil_model(k, c0, fs)
%SCHEIL_MODEL  Scheil-Gulliver solute redistribution.
%
%   [Cs, Cl, CsAvg, ClAvg] = scheil_model(k, c0, fs)
%
%   No solid diffusion (D_S = 0) and a perfectly mixed liquid (D_L -> inf),
%   with local equilibrium k = Cs/Cl at the interface:
%
%       Cs = k*c0*(1 - fs)^(k-1)
%       Cl =    c0*(1 - fs)^(k-1)
%
%   The solid is cored. Its average composition follows from the solute
%   balance and is
%
%       CsAvg = c0*[1 - (1 - fs)^k] / fs        (CsAvg -> k*c0 as fs -> 0)
%
%   Inputs
%       k   partition coefficient, k > 0 (not restricted to k <= 1)
%       c0  nominal composition
%       fs  solid fraction, 0 <= fs <= 1 (scalar or array)
%
%   Outputs
%       Cs      interface solid composition
%       Cl      liquid composition
%       CsAvg   average solid composition
%       ClAvg   average liquid composition (= Cl; the liquid is uniform)
%
%   For k < 1 the liquid and interface solid compositions diverge as fs -> 1.
%
%   Example (Al-4.8 wt.% Cu)
%       [Cs, Cl, CsAvg] = scheil_model(0.173, 4.8, 0.5)
%
%   HOW TO RUN
%       addpath('models')                 % from fs_slider_project
%       [Cs, Cl] = scheil_model(0.173, 4.8, 0.5);
%       fs = linspace(0,0.99,200);
%       [Cs, Cl, CsAvg] = scheil_model(0.173, 4.8, fs);
%
%   AUTHOR
%       Prathamesh Deepak Ladhe, MSE 670 -- Solidification
%
%   SEE ALSO
%       equilibrium_model, clyne_kurz_model, limited_liquid_model.
%       Derivation: report/TECHNICAL_REPORT.pdf, Section 2.3.

Cl = c0 .* (1 - fs).^(k - 1);
Cs = k .* Cl;
ClAvg = Cl;

CsAvg = zeros(size(fs));
small = fs < 1e-9;
if isscalar(fs)
    if small
        CsAvg = k*c0;
    else
        CsAvg = c0*(1 - (1 - fs)^k)/fs;
    end
else
    CsAvg(small) = k*c0;
    idx = ~small;
    CsAvg(idx) = c0*(1 - (1 - fs(idx)).^k)./fs(idx);
end
end
