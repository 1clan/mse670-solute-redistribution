# Solute Redistribution Slider

An interactive graph for **solute redistribution during solidification**, based on the MSE 670 solidification notes. It compares four models that bracket the behaviour seen in real castings:

- **Equilibrium (lever rule)** — complete diffusion in both phases.
- **Scheil–Gulliver** — no diffusion in the solid, perfect mixing in the liquid.
- **Tiller et al.** — diffusion-controlled planar growth: no solid diffusion, no convective mixing in the liquid, and a solute boundary layer ahead of the interface.
- **Clyne–Kurz** — finite solid back diffusion with a fully mixed liquid, plus an optional Won–Thomas coarsening correction.

It comes in two versions that stay in sync:

- `index.html` — runs in any browser, no installation needed.
- `fs_slider.m` — the same slider app in MATLAB.

**Live demo:** https://1clan.github.io/mse670-solute-redistribution/

![Screenshot of the slider app](preview.png)

Move the **solid fraction `f_s`** slider from 0 to 1 and watch:

- the solid composition `C_S` (solid line),
- the liquid composition `C_L` (dashed line, or the boundary-layer profile for Tiller),
- the **composition along the bar**, aligned with the solidified/liquid segments,
- the **solid–liquid connector** at the interface (green to orange),
- the mass-balance check `f_s C_S,avg + (1 − f_s) C_L,avg = C_0`.

## Models

Pick a model with the 2×2 buttons above the controls. `k` can be any positive number — it is **not** limited to `0 < k ≤ 1`.

### Equilibrium (lever rule)

```
C_S = k C_0 / (1 − (1 − k) f_s)
C_L = C_0     / (1 − (1 − k) f_s)
```

Here `k` is the equilibrium partition coefficient and `C_0` is the nominal alloy composition. The solid is uniform at every instant, so the along-bar profile is a sharp step at the interface.

### Scheil–Gulliver

```
C_L = C_0 (1 − f_s)^(k − 1)
C_S = k C_0 (1 − f_s)^(k − 1)
```

The solid that forms at the interface has `C_S* = k C_L`, but it never re-equilibrates. The result is a **cored** solid:

```
C_S(x) = k C_0 (1 − x)^(k − 1),   0 ≤ x ≤ f_s
```

The average composition of all solid formed so far is

```
C_S,avg = C_0 [1 − (1 − f_s)^k] / f_s
```

with `C_S,avg → k C_0` as `f_s → 0`.

### Tiller et al. (diffusion-controlled planar growth)

This is the Tiller–Jackson–Rutter–Chalmers case: `D_S = 0`, and the liquid is not convectively mixed. Solute rejected by the growing solid can only spread by **diffusion in the liquid**, so a boundary layer builds up ahead of the interface.

With the Péclet number `Pe = v L / D_L`, the boundary-layer thickness is

```
δ / L = 1 / Pe
```

and the steady liquid profile is

```
C_L(z) = C_0 [1 + (1 − k)/k · exp(−Pe z)]
```

where `z` is the distance ahead of the interface. The three stages are:

1. **Initial transient** — the first solid is `k C_0` and rises toward `C_0`:

   ```
   C_S(x) ≈ C_0 [k + (1 − k)(1 − exp(−k Pe x))]
   ```

2. **Steady-state growth** — the interface liquid reaches `C_0/k`, so the solid grows at `C_S = C_0`.

3. **Final transient** — near `f_s = 1` the boundary layer is squeezed against the mold wall and both compositions spike.

The app integrates the solid profile from the local-equilibrium condition and the overall solute balance, so the initial transient, the `C_S = C_0` plateau, and the final spike are mass-conserving. The liquid boundary layer is shown as a separate profile. Use `Pe ≥ 1` for a thin boundary layer; smaller values broaden the layer and the transient.

### Clyne–Kurz (back diffusion)

The liquid is assumed homogeneous, but the solid retains a finite amount of back diffusion. The Fourier number is

```
α = D_s t_f / X² = 4 D_s t_f / λ₂²
```

where `X = λ₂/2` is the representative diffusion distance. Clyne and Kurz replace the Brody–Flemings parameter `β` by

```
β_CK = 2α(1 − exp(−1/α)) − exp(−1/(2α))
```

which is bounded between 0 and 1. The liquid composition follows the generalized back-diffusion form

```
C_L / C_0 = [1 − (1 − β k) f_s]^((k − 1)/(1 − β k))
```

The interface solid obeys local equilibrium, `C_S* = k C_L`, and the average solid composition follows from the solute balance:

```
C_S,avg = [C_0 − (1 − f_s) C_L] / f_s
```

Limiting cases:

- `β → 0` recovers **Scheil–Gulliver** (no back diffusion).
- `β → 1` recovers the **equilibrium lever rule** (complete back diffusion).

### Won–Thomas coarsening correction

The Won–Thomas extension approximates dendrite coarsening by enlarging the Fourier number:

```
α⁺ = 2(α + α_C),    α_C = 0.1
```

and then recomputing `β_CK` with `α⁺`. The factor of two extends the result to columnar dendrites, while `α_C` accounts for the smaller arm spacing present before coarsening is complete. This is an approximate correction, not a full coarsening model; the empirical secondary-dendrite-arm-spacing fits in the Won–Thomas paper are steel-specific and are not applied here.

## Model comparison

| Feature | Equilibrium | Scheil–Gulliver | Tiller et al. | Clyne–Kurz |
|---|---|---|---|---|
| Solid diffusion `D_S` | Infinite | Zero | Zero | Finite; back diffusion included |
| Liquid mixing `D_L` | Infinite | Infinite | Diffusion only; no convection | Infinite; liquid homogenized |
| Solid composition | Uniform at `C_0` | Continuously varying (cored) | Initial transient → `C_0` plateau → final spike | Varies; segregation reduced by back diffusion |
| Liquid composition | Uniform | Uniform | Boundary layer `C_L(z)` | Uniform |
| Key parameters | `k` | `k` | `Pe = vL/D_L` | `α = 4D_s t_f/λ₂²`, `β_CK` |
| Limiting cases | Complete diffusion in both phases | `β = 0` | `Pe → ∞`; very thin layer | `β → 0` gives Scheil; `β → 1` gives lever rule |
| Interface stability | Planar | Planar (assumed) | Prone to constitutional supercooling | Planar / local equilibrium assumed |

## Run it

### Browser version

No installation or build step is needed.

1. Open `index.html` in any modern browser (double-click it, or drag it into a browser window).
2. Pick **Equilibrium**, **Scheil–Gulliver**, **Tiller et al.**, or **Clyne–Kurz**.
3. Move the `f_s` slider.
4. Optionally change `k`, `C_0`, and the model parameters.

If your browser restricts local files for any reason, serve the folder instead:

```bash
cd fs_slider_project
python3 -m http.server 8000
# then open http://localhost:8000
```

### MATLAB version

1. Set the Current Folder to `fs_slider_project`.
2. In the Command Window, run:

```matlab
fs_slider
```

The MATLAB app requires R2020a or newer (`uifigure`, `uislider`, `uidropdown`, `uigridlayout`). It uses base MATLAB only.

### Standalone model functions

The `models/` folder contains the same equations as reusable functions, independent of the UI:

```matlab
addpath('models');

[Cs, Cl, CsAvg] = equilibrium_model(0.3, 1.0, 0.5);
[Cs, Cl, CsAvg] = scheil_model(0.3, 1.0, 0.5);

outT = tiller_model(0.3, 1.0, 20, 0.5);      % k, C0, Pe, fs
outK = clyne_kurz_model(0.3, 1.0, 1e-13, 100, 20e-6, 0.9);
outW = won_thomas_model(0.3, 1.0, 1e-13, 100, 20e-6, 0.9, 0.1);
```

`clyne_kurz_model` and `won_thomas_model` return a struct with `alpha`, `beta`, `Cl`, `CsStar`, `CsAvg`, and `ClAvg`. `tiller_model` returns the solid profile `x`, `csProfile`, the interface values, the liquid boundary layer `z`, `ClProfile`, and `delta`.

## Controls

| Control | Meaning |
|---|---|
| Model | Equilibrium, Scheil–Gulliver, Tiller et al., or Clyne–Kurz. |
| `f_s` slider | Solid fraction, from 0 (all liquid) to 1 (all solid). |
| `k` | Partition coefficient, `k = C_S*/C_L*`. Any value `0.01 ≤ k ≤ 100`; not restricted to `k ≤ 1`. Default 0.30 (illustrative). |
| `C_0` | Nominal solute concentration in wt.%. Default 1.0 wt.% (illustrative). |
| `Pe` | Tiller Péclet number, `Pe = vL/D_L`, default 20. Use `Pe ≥ 1` for a thin boundary layer. |
| `D_s` | Clyne–Kurz solid diffusivity, entered in units of `10⁻¹² m²/s`; default `0.1` (i.e. `1×10⁻¹³ m²/s`). |
| `t_f` | Local solidification time in seconds; default 100 s. |
| `λ₂` | Secondary dendrite arm spacing in µm; default 20 µm. |
| `α_C` | Won–Thomas coarsening constant; default 0.10. |
| Won–Thomas | Replaces `α` by `α⁺ = 2(α + α_C)` before computing `β_CK`. |

With the defaults above, `α = 0.10` and `β_CK ≈ 0.1933`. Enabling Won–Thomas gives `α⁺ = 0.40` and `β_CK ≈ 0.4478`.

## Where the equations come from

### Equilibrium

Solute conservation for a closed representative volume gives

```
C_0 = f_s C_S + (1 − f_s) C_L
```

and local equilibrium at the interface gives

```
C_S = k C_L
```

Substituting:

```
C_0 = [f_s k + (1 − f_s)] C_L = [1 − (1 − k) f_s] C_L
```

which rearranges to the two lever-rule expressions above.

### Scheil–Gulliver

Assume no solid-state diffusion (`D_S = 0`), instantaneous and uniform liquid mixing (`D_L → ∞`), and local equilibrium at the interface (`k = C_S/C_L`). A solute balance on a small increment of solid gives

```
(1 − f_s) dC_L = (k − 1) C_L df_s
```

Integrating from `C_L(0) = C_0`:

```
ln(C_L/C_0) = (k − 1) ln(1 − f_s)
C_L = C_0 (1 − f_s)^(k − 1)
```

and `C_S = k C_L` gives the solid equation. Integrating the deposited solid (`∫ C_S df_s`) and dividing by `f_s` gives `C_S,avg`.

### Tiller et al.

At steady state the solute rejected at the interface balances diffusion down the boundary layer. With a fixed frame moving at velocity `v`, the liquid diffusion equation becomes

```
D_L d²C_L/dz² + v dC_L/dz = 0
```

whose solution that tends to `C_0` far from the interface is

```
C_L(z) = C_0 + (C_L* − C_0) exp(−v z / D_L)
```

At steady state `C_L* = C_0/k`, which gives the profile quoted above. The initial transient follows from the same balance before the boundary layer is fully developed, and the final transient appears when the layer reaches the end of the bar. The app solves the solid profile numerically from local equilibrium and the global solute balance rather than plotting a closed-form transient that ignores mass conservation.

### Clyne–Kurz

A solute balance on an increment of solid with partial back diffusion gives the Brody–Flemings form

```
C_L/C_0 = [1 + (β k − 1) f_s]^((1 − k)/(β k − 1))
```

Clyne and Kurz chose `β_CK(α)` so that the result is bounded between the Scheil and lever-rule limits. The interface solid is `C_S* = k C_L`, and `C_S,avg` follows from the overall solute balance.

## Views

- **Composition vs. solid fraction** — `C_S/C_0` and `C_L/C_0` over the whole freezing range.
- **Composition along the bar** — a horizontal bar shows the solidified (teal) and liquid (amber) segments, and the profile below it shows the concentration at each position `x/L`. The interface is at `x/L = f_s`, and the green solid dot is joined to the orange liquid dot by a connector.

For **equilibrium**, each phase is uniform, so the along-bar profile is a sharp step at the interface. For **Scheil–Gulliver**, the solid is cored and follows `C_S(x) = k C_0 (1 − x)^(k−1)`; the remaining liquid is uniform. For **Tiller et al.**, the solid follows the integrated transient/plateau/spike profile and the liquid shows the decaying boundary layer, with a marker for `δ/L`. For **Clyne–Kurz**, the solid line is the back-diffused average composition (the model has no resolved spatial solid profile), and the interface composition `C_S*` is marked separately.

## Assumptions and limitations

### Equilibrium

- Complete diffusion (homogenization) in **both** the liquid and the solid.
- Local thermodynamic equilibrium at the solid–liquid interface.
- Constant partition coefficient `k`.
- Closed system: no solute enters or leaves.
- The solid is uniform at each instant. Real castings usually show **coring** because solid-state diffusion is too slow.

### Scheil–Gulliver

- **No diffusion in the solid:** `D_S = 0`; back-diffusion is neglected.
- **Infinite diffusion in the liquid:** `D_L → ∞`; solute mixing is instantaneous and uniform.
- **Local equilibrium:** the interface follows the phase diagram, `k = C_S/C_L`.
- Constant `k`.
- Closed system.

### Tiller et al.

- **No diffusion in the solid:** `D_S = 0`.
- **No convective mixing in the liquid:** transport is by liquid diffusion only, with `D_L` finite.
- **Local equilibrium** at the interface, `C_S* = k C_L*`, and constant `k`.
- Planar interface. In practice, constitutional supercooling can make the interface cellular or dendritic.
- `Pe ≥ 1` gives a thin boundary layer. The ideal no-mixing limit produces a singular last-liquid composition as `f_s → 1`.
- The displayed liquid profile is the steady boundary-layer form; the solid profile is integrated to conserve solute over the whole bar.

### Clyne–Kurz

- **Finite back diffusion in the solid:** characterized by `α = 4D_s t_f/λ₂²`.
- **Infinite diffusion in the liquid:** the liquid is uniform.
- Local equilibrium at the interface, constant `k`.
- The model is an analytical approximation; it does not resolve the spatial solid profile.
- The Won–Thomas option is an approximate coarsening correction. The empirical arm-spacing fits in the original paper are specific to the steels and cooling conditions studied there and should not be transferred automatically to other alloys.

### Endpoints

| `f_s` | Equilibrium | Scheil–Gulliver | Tiller et al. | Clyne–Kurz |
|---|---|---|---|---|
| 0 | `C_S = kC_0`, `C_L = C_0` | `C_S = kC_0`, `C_L = C_0` | `C_S* = kC_0`, `C_L* = C_0` | `C_S* = kC_0`, `C_L = C_0` |
| 1 | `C_S = C_0`, `C_L = C_0/k` | `k < 1`: singular; `k > 1`: both → 0; `C_S,avg = C_0` | singular in the ideal no-mixing limit; `C_S,avg = C_0` | finite for `β > 0`; `C_S,avg = C_0`; `β = 0, k < 1` recovers the Scheil singularity |

The app caps the plotted range and shows `∞` / “singular” in the readout at exactly `f_s = 1`. All models can be used with `k > 1`, where the curves fall toward zero as the liquid is depleted.

## Files

```
fs_slider_project/
├── index.html                 # browser app: layout, styles, models, and SVG charts
├── fs_slider.m                # MATLAB version of the same slider graph
├── models/
│   ├── equilibrium_model.m    # lever rule
│   ├── scheil_model.m         # Scheil–Gulliver
│   ├── tiller_model.m         # diffusion-controlled planar growth
│   ├── clyne_kurz_model.m     # back-diffusion model
│   └── won_thomas_model.m     # coarsening-corrected Clyne–Kurz
├── preview.png                # screenshot used in this README
└── README.md                  # this file
```

`index.html` has no external dependencies, so it also works offline. The MATLAB files use base MATLAB only.

## Notes source

The models follow the equilibrium / lever-rule and Scheil–Gulliver sections of the handwritten notes (`Notes_261030_120238.pdf`, pages 1–3), the diffusion-controlled boundary-layer case in the three-case notes, and the derivations in `solute_redistribution_detailed_notes.pdf` (Chapters 5, 8, and 9, including the Won–Thomas discussion).

Default values (`k = 0.30`, `C_0 = 1.0 wt.%`, `Pe = 20`, `D_s = 1×10⁻¹³ m²/s`, `t_f = 100 s`, `λ₂ = 20 µm`, `α_C = 0.10`) are for demonstration only; they are not measured properties of a named alloy.
