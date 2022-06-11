# This script is used to build *modified* Julia/Pluto notebooks stored under the `notebooks`
# directory and export them to HTML files stored under `notebooks/html`.

import Pkg;
Pkg.add("Pluto");
using Pluto;

println("Passed args: ");
for (i, arg) in enumerate(ARGS)
    println("$i: " * arg);
end

# Notebooks directory 
nb_dir = "notebooks";

# The files are passed as arguments
all_files = ARGS;

# Match Julia files stored strictly under `notebooks/` directory. It ignores
# any subdirectory under notebooks
re = r"^(\.\/)?notebooks\/[^\/]*\.jl$";
julia_files = filter(f -> occursin(re, f), all_files);

# Build each notebook
for file_jl in enumerate(julia_files)
    println("Building $file");
    
    s = Pluto.ServerSession();                    
    nb = Pluto.SessionActions.open(s, file_jl; run_async=false);
    html_contents = Pluto.generate_html(nb);
    filename_html = splitext(splitdir(file_jl)[end])[1] * ".html";
    fullfile_html = joinpath(nb_dir, "html", filename_html);
    write(fullfile_html, html_contents);
end