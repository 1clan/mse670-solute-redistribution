OVERLEAF INSTRUCTIONS
=====================

This zip is a self-contained LaTeX project. All figures and MATLAB
source listings are inside it, so it compiles without the rest of the
repository.

1. In Overleaf: New Project -> Upload Project, and choose this zip.
2. Set the main document to one of:
      TECHNICAL_REPORT.tex    (full 29-page report)
      TECHNICAL_SUMMARY.tex   (concise 4-page summary)
3. Compiler: pdfLaTeX. Compile twice so the table of contents and
   cross-references resolve.

If you upload files manually instead of using the zip, you must keep
this folder structure:

    TECHNICAL_REPORT.tex
    TECHNICAL_SUMMARY.tex
    preview.png
    figures/fig_models.png
    figures/fig_temperature.png
    figures/fig_boundary.png
    models/equilibrium_model.m
    models/scheil_model.m
    models/limited_liquid_model.m
    models/clyne_kurz_model.m
    models/won_thomas_model.m

The summary is standalone: if you only need the 4-page version, upload
TECHNICAL_SUMMARY.tex by itself.

The report uses only standard TeX Live packages (amsmath, booktabs,
listings, hyperref, xurl, microtype, caption, titlesec, fancyhdr,
enumitem, lmodern). No shell escape is required.
