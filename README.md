# Solute Redistribution Slider

A small interactive graph for the **equilibrium solidification (lever-rule)** model from the MSE 670 solidification notes. It comes in two versions:

- `index.html` — runs in any browser, no installation needed.
- `fs_slider.m` — the same slider app in MATLAB.

![Screenshot of the slider app](preview.png)

Move the **solid fraction `f_s`** slider from 0 to 1 and watch:

- the solid composition `C_S` (solid line),
- the liquid composition `C_L` (dashed line),
- the **composition profile along the bar**, aligned with the solidified/liquid segments,
- the mass-balance check `f_s C_S + (1 − f_s) C_L = C_0`.

The model used is:

```
C_S = k C_0 / (1 − (1 − k) f_s)
C_L = C_0     / (1 − (1 − k) f_s)
```

where `k` is the equilibrium partition coefficient and `C_0` is the nominal alloy composition.

## Run it

### Browser version

No installation or build step is needed.

1. Open `index.html` in any modern browser (double-click it, or drag it into a browser window).
2. Move the `f_s` slider.
3. Optionally change `k` and `C_0` to compare alloys.

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

The MATLAB app requires R2020a or newer (`uifigure`, `uislider`, `uigridlayout`). It uses base MATLAB only.

## Controls

| Control | Meaning |
|---|---|
| `f_s` slider | Solid fraction, from 0 (all liquid) to 1 (all solid). |
| `k` | Equilibrium partition coefficient, `k = C_S*/C_L*`. Default 0.30 (illustrative). |
| `C_0` | Nominal solute concentration in wt.%. Default 1.0 wt.% (illustrative). |

## Where the equation comes from

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

which rearranges to the two expressions above.

## Views

- **Composition vs. solid fraction** — the lever-rule curves `C_S/C_0` and `C_L/C_0` over the whole freezing range.
- **Composition along the bar** — the page-1 style view: a horizontal bar shows the solidified (teal) and liquid (amber) segments, and the step profile below it shows the concentration at each position `x/L`. The interface is at `x/L = f_s`, the solid side is at `C_S`, and the liquid side is at `C_L`.

The along-bar profile is the equilibrium limit: each phase is uniform, so the profile is a sharp step at the interface.

## Assumptions and limitations

- Complete diffusion (homogenization) in **both** the liquid and the solid.
- Local thermodynamic equilibrium at the solid–liquid interface.
- Constant partition coefficient `k`.
- Closed system: no solute enters or leaves.
- The solid is uniform at each instant (the equilibrium limit). Real castings usually show **coring** because solid-state diffusion is too slow.
- This is the lever-rule/equilibrium limit. It is not the Scheil model; the Scheil liquid composition is `C_L = C_0 (1 − f_s)^(k−1)` and becomes singular as `f_s → 1`, whereas the lever-rule expressions remain finite for `k > 0`.

At the endpoints:

- `f_s = 0`: `C_S = k C_0`, `C_L = C_0`.
- `f_s = 1`: `C_S = C_0`, `C_L = C_0 / k`.

## Files

```
fs_slider_project/
├── index.html   # browser app: layout, styles, model, and SVG charts
├── fs_slider.m  # MATLAB version of the same slider graph
├── preview.png  # screenshot used in this README
└── README.md    # this file
```

`index.html` has no external dependencies, so it also works offline. The MATLAB file uses base MATLAB only.

## Notes source

The model follows the equilibrium solidification / lever-rule section of the handwritten 18-page notes (`Notes_261030_120238.pdf`, pages 1–3) and the corresponding derivation in `solute_redistribution_detailed_notes.pdf` (Chapter 5).

Default values (`k = 0.30`, `C_0 = 1.0 wt.%`) are for demonstration only; they are not measured properties of a named alloy.
