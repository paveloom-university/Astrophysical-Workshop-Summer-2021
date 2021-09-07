# Notices

All reports are expected to be compiled with [`tectonic`](https://tectonic-typesetting.github.io/en-US/) as follows:

```bash
tectonic -X compile report.tex
```

Some assignments may include [Julia](https://julialang.org/) scripts. Make sure to use the project files (`Project.toml`) when running them:

```bash
julia --project=. -e "using Pkg; Pkg.instantiate()"
julia --project=. scripts/calc.jl
```
