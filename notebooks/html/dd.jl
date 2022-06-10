function get_lines_between(str::T, lines::Vector{T}; include_str=false) where {T <: AbstractString}
    # Indices
    indices = findall(line -> occursin(str, line), lines)
    if length(indices) == 0
        @warn "Didn't find '$str'"
        return
    elseif length(indices) < 2
        @warn "Didn't find an enclosing '$str'"
        return
    end

    if include_str
        return lines[indices[1]:indices[2]]
    else
        return lines[indices[1]+1:indices[2]-1]
    end
end

function get_lines_between(str::T1, filename::T2; include_str=false) where {T1 <: AbstractString, T2 <: AbstractString}
    return get_lines_between(str, readlines(filename); include_str)
end


function get_post_years(dir="posts")
  # List of subfiles/subdirectories AND files
  sfiles = readdir(dir)
  return filter(sfile -> isdir(joinpath(dir, sfile)), sfiles)
end

