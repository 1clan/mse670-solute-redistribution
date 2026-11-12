# Solute Redistribution Slider

An interactive graph for **solute redistribution during solidification**, based on the MSE 670 solidification notes. It compares two limiting models:

- **Equilibrium (lever rule)** — complete diffusion in both phases.
- **Scheil–Gulliver** — no diffusion in the solid, perfect mixing in the liquid.

It comes in two versions that stay in sync:

- `index.html` — runs in any browser, no installation needed.
- `fs_slider.m` — the same slider app in MATLAB.

**Live demo:** https://1clan.github.io/mse670-solute-redistribution/

![Screenshot of the slider app](preview.png)

Move the **solid fraction `f_s`** slider from 0 to 1 and watch:

- the solid composition `C_S` (solid line),
- the liquid composition `C_L` (dashed line),
- the **composition along the bar**, aligned with the solidified/liquid segments,
- the mass-balance check `f_s C_S,avg + (1 − f_s) C_L = C_0`.

## Models

Toggle between the two models with the buttons above the controls. `k` can be any positive number — it is **not** limited to `0 < k ≤ 1`.

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

The solid that forms at the interface has `C_S* = k C_L`, but it never re-equilibrates. The result is a **cored** solid: the along-bar profile is

```
C_S(x) = k C_0 (1 − x)^(k − 1),   0 ≤ x ≤ f_s
```

where `x/L` is the position along the bar. The average composition of all solid formed so far (used for mass balance) is

```
C_S,avg = C_0 [1 − (1 − f_s)^k] / f_s
```

with the limit `C_S,avg → k C_0` as `f_s → 0`.

## Run it

### Browser version

No installation or build step is needed.

1. Open `index.html` in any modern browser (double-click it, or drag it into a browser window).
2. Pick **Equilibrium** or **Scheil–Gulliver**.
3. Move the `f_s` slider.
4. Optionally change `k` and `C_0` to compare alloys.

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

## Controls

| Control | Meaning |
|---|---|
| Model | Equilibrium (lever rule) or Scheil–Gulliver. |
| `f_s` slider | Solid fraction, from 0 (all liquid) to 1 (all solid). |
| `k` | Partition coefficient, `k = C_S*/C_L*`. Any value `0.01 ≤ k ≤ 100`; not restricted to `k ≤ 1`. Default 0.30 (illustrative). |
| `C_0` | Nominal solute concentration in wt.%. Default 1.0 wt.% (illustrative). |

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

Substituting `C_S = k C_L`:

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

## Views

- **Composition vs. solid fraction** — `C_S/C_0` and `C_L/C_0` over the whole freezing range.
- **Composition along the bar** — the page-1 style view: a horizontal bar shows the solidified (teal) and liquid (amber) segments, and the profile below it shows the concentration at each position `x/L`. The interface is at `x/L = f_s`.

For **equilibrium**, each phase is uniform, so the along-bar profile is a sharp step at the interface. For **Scheil–Gulliver**, the solid is cored and the solid-side profile follows `C_S(x) = k C_0 (1 − x)^(k−1)`; the remaining liquid is uniform at `C_L`.

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

### Endpoints

| `f_s` | Equilibrium | Scheil–Gulliver |
|---|---|---|
| 0 | `C_S = k C_0`, `C_L = C_0` | `C_S = k C_0`, `C_L = C_0` |
| 1 | `C_S = C_0`, `C_L = C_0 / k` | `k < 1`: `C_S, C_L → ∞` (singular); `k > 1`: both `→ 0`; `C_S,avg = C_0` |

The Scheil liquid composition diverges as `f_s → 1` for `k < 1` (the last liquid is enriched without bound in the ideal model). The app caps the plotted range and shows `∞` / “singular” in the readout at exactly `f_s = 1`. The Scheil model can also be used with `k > 1`, where the curves fall toward zero as the liquid is depleted.

## Files

```
fs_slider_project/
├── index.html   # browser app: layout, styles, models, and SVG charts
├── fs_slider.m  # MATLAB version of the same slider graph
├── preview.png  # screenshot used in this README
└── README.md    # this file
```

`index.html` has no external dependencies, so it also works offline. The MATLAB file uses base MATLAB only.

## Notes source

The models follow the equilibrium solidification / lever-rule and Scheil–Gulliver sections of the handwritten 18-page notes (`Notes_261030_120238.pdf`, pages 1–3) and the corresponding derivations in `solute_redistribution_detailed_notes.pdf` (Chapter 5).

Default values (`k = 0.30`, `C_0 = 1.0 wt.%`) are for demonstration only; they are not measured properties of a named alloy.
