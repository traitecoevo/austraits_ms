# Paper about the Austraits compilation

This repository contains code needed to reproduce the article:

Falster, Gallagher et al (2021) AusTraits, a curated plant trait database for the Australian flora *Scientific Data* (in press)

also available as a preprint at

Falster, Gallagher et al (2021) AusTraits – a curated plant trait database for the Australian flora *bioRxiv*: 2021.01.04.425314. doi: [10.1101/2021.01.04.425314](https://doi.org/10.1101/2021.01.04.425314)

# Instructions

The code included should enabled you to recreate the entire paper, including all figures and tables.

## Installing relevant software

All analyses were done in `R`. You need to [download this repository](http://github.com/traitecoevo/austraits_ms/archive/master.zip), and then open an R session with working directory set to the root of the project.

We use a number packages, which can be easily installed by:

```r
devtools::install_deps()
```

## Recreating the figures

To generate all figures run code in `build_figures.R`.

To generate all tables and main text run code in `ms.Rmd`.
