# What this site is about

**Site title:** *Solute redistribution during solidification*
**Live demo:** https://1clan.github.io/mse670-solute-redistribution/
**Local file:** `index.html`

## In one paragraph

This is a single-page, browser-based teaching tool for **MSE 670 (Solidification)**. It visualises how a solute (copper) redistributes between the growing solid and the remaining liquid as an **Al–4.8 wt.% Cu** alloy freezes. You move the solid-fraction `f_s` and interface-temperature `T` sliders, plus logarithmic `k` and `C_0` sliders, and the page updates the solid and liquid compositions, an along-the-bar concentration profile, the liquidus tie-line with `k`, `D_S`, `D_L` derived from `T`, and a live mass-balance check. A **Play** button on every parameter sweeps `f_s`, `T`, `k`, or `C_0` back and forth for a hands-off animation. A model switch lets you compare four classic solidification models side by side: Equilibrium (lever rule), Scheil–Gulliver, no solid diffusion with limited liquid diffusion, and Clyne–Kurz with back diffusion.

It is an **interactive graph / explanatory visualisation**, not a data-collection site, calculator service, or commercial product. There is no backend, no login, no tracking, and no external dependencies — the whole thing is one self-contained HTML file that can be opened offline.

## Who it is for

- Students learning microsegregation and solute redistribution during solidification.
- Anyone who wants an intuitive, hands-on way to see the difference between the equilibrium, Scheil, boundary-layer, and back-diffusion assumptions.
- Instructors who want a ready-made demo that runs in any modern browser (and has a matching MATLAB app).

## The physics problem it illustrates

When an alloy solidifies, the solid usually accepts less solute than the liquid (partition coefficient `k = C_S/C_L < 1`). The rejected solute piles up in the liquid, so:

- the first solid to form is relatively pure (`C_S = k C_0`),
- the liquid becomes richer in solute as freezing proceeds,
- the last liquid to freeze can be strongly enriched (and may reach a eutectic or a segregation limit).

How much segregation actually occurs depends on how fast solute can move:

- **In the solid** — solid-state back diffusion smooths the deposited solid.
- **In the liquid** — convection and/or diffusion determine whether rejected solute is carried away or builds up a boundary layer ahead of the interface.

The four models on the site are different idealisations of those transport assumptions. Together they bracket the range of behaviour seen in real castings.

## The four models

| Model | Solid diffusion | Liquid mixing | What it shows |
|---|---|---|---|
| **Equilibrium (lever rule)** | Infinite | Infinite | Uniform solid and liquid at every instant; the ideal, no-segregation limit. |
| **Scheil–Gulliver** | Zero | Infinite (perfectly mixed) | Classic **coring**: the solid keeps the composition it had when it formed, and the last liquid becomes strongly enriched (`C_L → C_0/k`). |
| **No solid diffusion, limited liquid diffusion** | Zero | Diffusion only, no convection | A solute **boundary layer** builds ahead of a planar interface (`δ/L = D_L/(vL)`); the solid shows an initial transient, a `C_S ≈ C_0` plateau, and a final spike. Prone to constitutional supercooling. |
| **Clyne–Kurz** | Finite (back diffusion) | Infinite | Segregation reduced by solid back diffusion, parameterised by the Fourier number `α = 4 D_s t_f / λ₂²` and `β_CK(α)`; optional **Won–Thomas** coarsening correction and direct `β` override. |

Limiting behaviour built into the models:

- `β → 0` in Clyne–Kurz recovers Scheil–Gulliver.
- `β → 1` recovers the equilibrium lever rule.
- Very thin boundary layer (`δ/L → 0`) approaches the no-mixing limit.

## What the page shows

- **Controls panel** — model switch, `f_s` slider (0 = all liquid, 1 = all solid), temperature slider (548–700 °C in whole-degree steps, moving the liquidus tie-line and deriving `k`, `D_S`, `D_L`), logarithmic `k` and `C_0` sliders paired with editable number boxes, model-specific inputs (growth velocity `v`, `D_L`, `D_s`, local solidification time `t_f`, secondary dendrite arm spacing `λ₂`, `α_C`, direct `β`), and a **▶ Play** button on every parameter (`f_s`, `T`, `k`, `C_0`) that animates it back and forth.
- **Current state readout** — `C_S` and `C_L` in wt.%, solid/liquid averages where relevant, the liquidus tie-line `C_L(T)` / `C_S(T)` with the temperature-derived `k`, `D_S`, `D_L`, and the mass-balance check `f_s C_S,avg + (1 − f_s) C_L,avg = C_0`.
- **Composition vs. solid fraction** — the main chart: solid and liquid composition (normalised by `C_0`) through the whole freezing range.
- **Composition along the bar** — a schematic bar split into solidified (teal) and liquid (amber) segments, with the concentration profile beneath it and a solid–liquid connector at the interface.
- **Graph view switch** — `Auto zoom` rescales the along-bar chart as `f_s` changes; `Fixed scale` locks the axes so only the data moves.
- **"Where the equations come from"** — a collapsible derivation for the selected model.
- **Model comparison table** — assumptions, key parameters, limiting cases, and interface stability for all four models.

## Temperature and the liquidus

The temperature slider does two things: it moves the equilibrium tie-line and it rescales the rate parameters, so the concentration curves respond to temperature.

The tie-line comes from quadratic fits to the Al–Cu liquidus and solidus through `(0, 660.3)`, `(4.8, 648)`, `(33, 548)` and `(0, 660.3)`, `(0.8304, 648)`, `(5.65, 548)`:

```
C_L(T), C_S(T) from the fits
k(T) = C_S(T) / C_L(T)
```

At `648 °C` this gives `C_L = 4.80 wt.%`, `C_S = 0.830 wt.%`, and `k = 0.173`. The diffusion coefficients follow Arrhenius scaling anchored at the same temperature:

```
D_S(T) = 4.8×10⁻¹⁵ · exp[−(130 kJ/mol)/R_g · (1/T − 1/648 °C)]
D_L(T) = 2.4×10⁻⁹  · exp[−(30 kJ/mol)/R_g  · (1/T − 1/648 °C)]
```

The **Derive k, D_s and D_L from T** checkbox is on by default. Editing `k`, dragging its slider, or animating it switches to manual mode, where `k`, `D_S`, and `D_L` are independent inputs; re-checking the box re-anchors all three to the current temperature. In whole-degree steps over 548–700 °C, `k(T)` changes only from about `0.1712` to `0.1735`, so the equilibrium and Scheil *normalized* curves move very little with temperature — the visible temperature effect is mainly through `D_S(T)` and `D_L(T)` in Clyne–Kurz and the limited-diffusion model.

For comparison, the notes' dilute liquidus `T_L = T_m − m C_L` with `m = 2.5625 °C per wt.% Cu` remains the cleaner local approximation for the tie-line itself. The quadratic fits and activation energies are standard Al–Cu approximations, not derivations from the notes, and the fits are extrapolated across the slider range.

## Reference alloy and defaults

| Quantity | Value |
|---|---|
| Alloy | Al–4.8 wt.% Cu |
| Nominal composition `C_0` | 4.8 wt.% Cu |
| Partition coefficient `k` | 0.173 at 648 °C (derived from `T` by default) |
| Liquidus / solidus fits | quadratic, anchored at `(0, 660.3)`, `(4.8, 648)`, `(548 °C)` points |
| Liquid diffusivity `D_L` | 2.4×10⁻⁹ m²/s |
| Solid diffusivity `D_S` | 4.8×10⁻¹⁵ m²/s |
| Liquidus / solidus | 648 °C / 548 °C |
| Melting point of Al | 660.3 °C |
| Growth velocity `v` | 20 µm/s |
| Local solidification time `t_f` | 100 s |
| Secondary arm spacing `λ₂` | 20 µm |

## How it is built and how to run it

- **One static HTML file** (`index.html`) with inline CSS and JavaScript and hand-drawn SVG charts. No frameworks, build step, CDN, fonts, or network calls.
- Open it by double-clicking the file, or serve the folder:
  ```bash
  cd fs_slider_project
  python3 -m http.server 8000
  # then visit http://localhost:8000
  ```
- A matching **MATLAB app** (`fs_slider.m`) reproduces the same models and controls — `f_s`, `T`, `k`, and `C_0` sliders, editable `k`/`C_0` fields, and a **▶** play button for each parameter — and requires R2020a or newer (`uifigure`, `uislider`, etc.).
- The same equations are also available as standalone MATLAB functions in `models/` (`equilibrium_model.m`, `scheil_model.m`, `limited_liquid_model.m`, `clyne_kurz_model.m`, `won_thomas_model.m`).

## Limitations and caveats

- It is a **teaching model**, not a quantitative prediction tool for a real casting.
- The temperature coupling uses empirical quadratic phase-diagram fits and Arrhenius diffusion; the notes themselves assume constant `k` and `D`. The terminal eutectic is not modelled.
- The Clyne–Kurz model does not resolve a spatial solid profile; it gives an average solid composition plus the interface value.
- The phase-diagram fits are extrapolated across the 548–700 °C slider range for display; use them near the Al–Cu composition, and treat `k(T)` as nearly constant there.
- The limited-liquid-diffusion case assumes a planar interface; in reality constitutional supercooling can make it cellular or dendritic.
- Singularities at `f_s = 1` are capped/flagged rather than treated as physical.
- For real-alloy work you would need a measured or thermodynamic partition coefficient, the actual cooling history, and a defensible microstructural length scale.

## Related files in this project

```
fs_slider_project/
├── index.html          # the website (all HTML, CSS, JS, SVG)
├── fs_slider.m         # MATLAB version of the app
├── models/             # reusable MATLAB model functions
├── preview.png         # screenshot used in the README
├── README.md           # detailed model documentation and equations
└── SITE_OVERVIEW.md    # this document
```

The wider `MSE670` folder also contains the underlying course notes, the three-case MATLAB simulation, and the written submission that this visualisation supports.
