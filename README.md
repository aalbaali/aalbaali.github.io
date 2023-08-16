# Overview
My personal website built using [Franklin.jl](https://github.com/tlienart/Franklin.jl) and the theme inherited from [tlienart.github.io](https://github.com/tlienart/tlienart.github.io).

# Usage
## Building notebooks locally
When testing the website locally, make sure the Julia Pluto notebooks are converted into HTML and stored under `notebooks/html` before inserting them into posts.
This can be done by running
```bash
julia .github/workflows/build_notebooks.jl build-all
```
or by passing the Julia filename (e.g., `notebooks/fft_primer.jl`).

Note that the files under `html` do not need to be pushed to the remote branch as they are built on the cloud.

## Running franklin
Run the following command from the project root
```bash
julia --project=Project.toml -e 'using Pkg; Pkg.instantiate(); using Franklin; serve()'
```
