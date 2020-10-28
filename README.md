# Paper about the Austraits compilation

To build the paper place a copy of `austraits_2.0.0.rds` in the folder `data`. This folder is not tracked by git, as it is too large. 


Load resources:

```
devtools::load_all()
```

Build figures:
```

```

Build paper:
```
rmarkdown::render("ms.Rmd")
```
