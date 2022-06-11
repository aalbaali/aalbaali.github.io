# This file contains helper functions and HTML functions. HTML functions are Julia functions that
# can be embedded inside HTML/md pages. For more information, refer to the Franklin.jl documentation
# on https://franklinjl.org/syntax/utils/

using Dates
using Gumbo
using Cascadia


"""
Grab the <script ... "launch-params"> tag from the Pluto HTML file
"""
function grab_pluto_launch_params(html_file, attribute = "data-pluto-file")::String
	content = join(readlines(html_file), "\n");

	# Parse HTML contents
	parsed_html = parsehtml(content);

	# Set selector. Using `[foo]` tries to find HTML elements with `foo` selector (e.g., <div class="nice" foo=25>)
	s = Selector("[data-pluto-file]");

	# Get the elements of the selector
	matches = eachmatch(s, parsed_html.root);

	# Find all <script> nodes (usually it's a single element)
	script_nodes = filter(m -> tag(m) == :script, matches);

	script_node = nothing
	for elem in script_nodes
		if attribute in keys(elem.attributes)			
			script_node = elem;			
			break;		
		end
	end

	# Get the contents of <script> by using a String buffer
	ss = IOBuffer();
	prettyprint(ss, script_node);
	
	return String(take!(ss));	
end

"""
Get content of a unique HTML tag from lines of HTML file

tag <: AbstractString: Tag to search for in each line. Expect to have a single pair <head> and </head>
lines Vector{<:AbstractString}: Lines to search inside
include_str If set to true, then include the lines containing the passed 'str'
"""
function html_body_lines(
    tag::T,
    lines::Vector{T};
    include_str = false,
) where {T<:AbstractString}
    # Indices of lines containing the passed tag
    indices = findall(line -> occursin(tag, line), lines)
    if length(indices) == 0
        @error "Didn't find '$tag'"
        return
    elseif length(indices) < 2
        @error "Didn't find an enclosing '$tag'"
        return
    end

    if include_str
        return lines[indices[1]:indices[2]]
    else
        return lines[indices[1]+1:indices[2]-1]
    end
end


"""
Get content of a unique tag from an HTML file. This returns an array of strings. Check `html_body`
function that returns a single string.

tag <: AbstractString: Tag to search for in each line. Expect to have a single pair <head> and </head>
filename <:AbstractString: HTML filename
include_str If set to true, then include the tag lines (e.g., will include <head> and </head>)
join_files If set to true, then join the lines into a single string separated by "\n"
"""
function html_body_lines(
    tag::T1,
    filename::T2;
    include_str = false,
) where {T1<:AbstractString,T2<:AbstractString}
    return html_body_lines(tag, readlines(filename); include_str)
end

"""
Get content of a unique tag from an HTML file. Returns a single string joined by line breaks "\n"

tag <: AbstractString: Tag to search for in each line. Expect to have a single pair <head> and </head>
filename <:AbstractString: HTML filename
include_str If set to true, then include the tag lines (e.g., will include <head> and </head>)
join_files If set to true, then join the lines into a single string separated by "\n"
"""
function html_body(
    tag::T1,
    filename::T2;
    include_str = false,
) where {T1<:AbstractString,T2<:AbstractString}
    return join(html_body_lines(tag, readlines(filename); include_str), "\n")
end

"""
Embed an html string into a markdown file
"""
function wrap_html_to_md(string::T) where {T<:AbstractString}
    return "~~~\n" * string * "\n~~~"
end

"""
From a Plut-notebooks-exported HTML, export the lines enclosed by `tag`
"""
function get_html_notebooks_tag(
    tag::T,
    filename::T,
    html_notebooks_dir::T,
) where {T<:AbstractString}
    # Get the filepath
    fullfile = joinpath(html_notebooks_dir, filename)
    if !ispath(fullfile)
        @error "File '$(joinpath(pwd(), fullfile))' doesn't exist"
        return
    end

    return html_body(tag, fullfile)
end
function get_html_notebooks_tag(tag::T, filename::T) where {T<:AbstractString}
    # Get html notebooks dir
    html_notebooks_dir = locvar("notebooks_html_dir")
    return get_html_notebooks_tag(tag, filename, html_notebooks_dir)
end
function get_html_notebooks_tag(tag::T) where {T<:AbstractString}
    filename = locvar("notebook_html")
    if filename == nothing
        @error "Filename '$filename' doesn't exist"
    end
    return get_html_notebooks_tag(tag, filename)
end

"""
Get a notebook HTML body
"""
function hfun_notebook_content(args)
    if length(args) == 1
        contents = get_html_notebooks_tag(args[1])
    elseif length(args) == 2
        contents = get_html_notebooks_tag(args[1], args[2])
    elseif length(args) == 3
        contents = get_html_notebooks_tag(args[1], args[2], args[3])
    else
        @error "Too many arguments: '$(length(args))'"
    end
    return contents
end

"""
Extract the launch-params from the <script> tag inside the Pluto (HTML) notebook
"""
function hfun_grab_pluto_launch_params(args = nothing)
    pluto_dir = locvar("notebooks_html_dir")
    notebook = locvar("notebook_html")
    fullpath = joinpath(pluto_dir, notebook)

    return grab_pluto_launch_params(fullpath);
end

"""
HTML function used for debugging
"""
function hfun_debug(args = nothing)
    str = "DEBUG: "
    if args !== nothing
        str *= join(args, "\n")
    end
    return str
end

"""
Get a list of years inside the `posts` directory
"""
function get_post_years(dir = "posts")
    # List of subfiles/subdirectories AND files
    sfiles = readdir(dir)
    
    # Get directories only
    directories = filter(sfile -> isdir(joinpath(dir, sfile)), sfiles)

    # Return "numeric" directories (i.e., directories that can be parsed into a number)
    # For example, "2022" is a numeric directory but "_2022" is not
    return tryparse.(Int64, directories)
end

"""
HTML function used in the `Posts` page to list all avilable posts. That is, it lists posts stored
under `_posts`.

Returns an HTML string
"""
function hfun_posts()
    io = IOBuffer()

    # Get an array of the years inside the `posts` directory
    years = get_post_years()
    for year in years
        ys = "$year"
        isdir(joinpath("posts", ys)) || continue

        # Include "years" heading only if there is more than a single year
        if length(years) > 1
            write(io, "\n\n### $year\n\n")
        end

        write(io, "@@list,mb-5\n")
        for month = 12:-1:1
            ms = "0"^(month < 10) * "$month"
            base = joinpath("posts", ys, ms)
            isdir(base) || continue
            posts = filter!(p -> endswith(p, ".md"), readdir(base))
            days = zeros(Int, length(posts))
            lines = Vector{String}(undef, length(posts))
            for (i, post) in enumerate(posts)
                ps = splitext(post)[1]
                url = "/posts/$ys/$ms/$ps/"
                surl = strip(url, '/')
                title = pagevar(surl, :title)
                days[i] = parse(Int, first(ps, 2))
                pubdate = Dates.format(Date(year, month, days[i]), "U d")

                tmp = "* ~~~<span class=\"post-date\">$pubdate</span><a href=\"$url\">$title</a>"
                descr = pagevar(surl, :descr)
                if descr !== nothing
                    tmp *= ": <span class=\"post-descr\">$descr</span>"
                end
                lines[i] = tmp * "~~~\n"
            end
            # sort by day
            foreach(line -> write(io, line), lines[sortperm(days, rev = true)])
        end
        write(io, "@@\n")
    end
    return Franklin.fd2html(String(take!(io)), internal = true)
end

"""
HTML function to list all tags available from from all pages. This function is delayed so that it's
activated after all pages are built.
For more info on `@delay`ed functions, refer to Franklin's documentation
"""
@delay function hfun_list_tags()

    tagpages = globvar("fd_tag_pages")
    if tagpages === nothing
        return ""
    end
    tags = tagpages |> keys |> collect |> sort
    tags_count = [length(tagpages[t]) for t in tags]
    io = IOBuffer()
    for (t, c) in zip(tags, tags_count)
        write(
            io,
            """
      <nobr>
        <a href=\"/tag/$t/\" class=\"tag-link\">$(replace(t, "_" => " "))</a>
        <span class="tag-count"> ($c)</span>
      </nobr>
      """,
        )
    end
    return String(take!(io))
end

"""
Get tag list.
This function doesn't need to be delayed because it's generated at tag generation, after everything
else.
"""
function hfun_tag_list()

    tag = locvar(:fd_tag)::String
    items = Dict{Date,String}()
    for rpath in globvar("fd_tag_pages")[tag]
        title = pagevar(rpath, "title")
        url = Franklin.get_url(rpath)
        surl = strip(url, '/')

        ys, ms, ps = split(surl, '/')[end-2:end]
        date = Date(parse(Int, ys), parse(Int, ms), parse(Int, first(ps, 2)))
        date_str = Dates.format(date, "U d, Y")

        tmp = "* ~~~<span class=\"post-date tag\">$date_str</span><nobr><a href=\"$url\">$title</a></nobr>"
        descr = pagevar(rpath, :descr)
        if descr !== nothing
            tmp *= ": <span class=\"post-descr\">$descr</span>"
        end
        tmp *= "~~~\n"
        items[date] = tmp
    end
    sorted_dates = sort!(items |> keys |> collect, rev = true)
    io = IOBuffer()
    write(io, "@@posts-container,mx-auto,px-3,py-5,list,mb-5\n")
    for date in sorted_dates
        write(io, items[date])
    end
    write(io, "@@")
    # output = String(take!(io))
    # @info "length(output): $(length(output))"
    # return Franklin.fd2html(output, internal=true)
    return Franklin.fd2html(String(take!(io)), internal = true)
end

"""
Process tags in current page
"""
function hfun_current_tag()
    tag = locvar("fd_tag")
    println("  tag: $tag")

    return replace(locvar("fd_tag"), "_" => " ")
end

function hfun_svg_linkedin()
    return """<svg width="30" height="30" viewBox="0 50 512 512"><path fill="currentColor" d="M150.65 100.682c0 27.992-22.508 50.683-50.273 50.683-27.765 0-50.273-22.691-50.273-50.683C50.104 72.691 72.612 50 100.377 50c27.766 0 50.273 22.691 50.273 50.682zm-7.356 86.651H58.277V462h85.017V187.333zm135.901 0h-81.541V462h81.541V317.819c0-38.624 17.779-61.615 51.807-61.615 31.268 0 46.289 22.071 46.289 61.615V462h84.605V288.085c0-73.571-41.689-109.131-99.934-109.131s-82.768 45.369-82.768 45.369v-36.99z"/></svg>"""
end

"""Github logo"""
function hfun_svg_github()
    return """<svg width="30" height="30" viewBox="0 0 25 25" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M9 19c-5 1.5-5-2.5-7-3m14 6v-3.87a3.37 3.37 0 0 0-.94-2.61c3.14-.35 6.44-1.54 6.44-7A5.44 5.44 0 0 0 20 4.77 5.07 5.07 0 0 0 19.91 1S18.73.65 16 2.48a13.38 13.38 0 0 0-7 0C6.27.65 5.09 1 5.09 1A5.07 5.07 0 0 0 5 4.77a5.44 5.44 0 0 0-1.5 3.78c0 5.42 3.3 6.61 6.44 7A3.37 3.37 0 0 0 9 18.13V22"/></svg>"""
end

"""Twitter logo"""
function hfun_svg_twitter()
    return """<svg width="30" height="30" viewBox="0 0 335 276" fill="currentColor"><path d="M302 70A195 195 0 0 1 3 245a142 142 0 0 0 97-30 70 70 0 0 1-58-47 70 70 0 0 0 31-2 70 70 0 0 1-57-66 70 70 0 0 0 28 5 70 70 0 0 1-18-90 195 195 0 0 0 141 72 67 67 0 0 1 116-62 117 117 0 0 0 43-17 65 65 0 0 1-31 38 117 117 0 0 0 39-11 65 65 0 0 1-32 35"/></svg>"""
end

"""Tag logo logo"""
function hfun_svg_tag()
    # Tag symbol
    return """
            <a href="/tags/" id="tag-icon"><svg width="20" height="20" viewBox="0 0 512 512">
            <defs>
            <style>
                .cls-1 {
                fill: #141f38
                }
                
                @media (prefers-color-scheme: dark) {
                .cls-1 {
                    fill: rgba(255, 255, 255, 0.85);
                }
                }
            </style>
            </defs>
            <path class="cls-1"
            d="M215.8 512a76.1 76.1 0 0 1-54.17-22.44L22.44 350.37a76.59 76.59 0 0 1 0-108.32L242 22.44A76.11 76.11 0 0 1 296.2 0h139.2A76.69 76.69 0 0 1 512 76.6v139.19A76.08 76.08 0 0 1 489.56 270L270 489.56A76.09 76.09 0 0 1 215.8 512zm80.4-486.4a50.69 50.69 0 0 0-36.06 14.94l-219.6 219.6a51 51 0 0 0 0 72.13l139.19 139.19a51 51 0 0 0 72.13 0l219.6-219.61a50.67 50.67 0 0 0 14.94-36.06V76.6a51.06 51.06 0 0 0-51-51zm126.44 102.08A38.32 38.32 0 1 1 461 89.36a38.37 38.37 0 0 1-38.36 38.32zm0-51a12.72 12.72 0 1 0 12.72 12.72 12.73 12.73 0 0 0-12.72-12.76z" />
            <path class="cls-1"
            d="M217.56 422.4a44.61 44.61 0 0 1-31.76-13.16l-83-83a45 45 0 0 1 0-63.52L211.49 154a44.91 44.91 0 0 1 63.51 0l83 83a45 45 0 0 1 0 63.52L249.31 409.24a44.59 44.59 0 0 1-31.75 13.16zm-96.7-141.61a19.34 19.34 0 0 0 0 27.32l83 83a19.77 19.77 0 0 0 27.31 0l108.77-108.7a19.34 19.34 0 0 0 0-27.32l-83-83a19.77 19.77 0 0 0-27.31 0l-108.77 108.7z" />
            <path class="cls-1"
            d="M294.4 281.6a12.75 12.75 0 0 1-9-3.75l-51.2-51.2a12.8 12.8 0 0 1 18.1-18.1l51.2 51.2a12.8 12.8 0 0 1-9.05 21.85zM256 320a12.75 12.75 0 0 1-9.05-3.75l-51.2-51.2a12.8 12.8 0 0 1 18.1-18.1l51.2 51.2A12.8 12.8 0 0 1 256 320zM217.6 358.4a12.75 12.75 0 0 1-9-3.75l-51.2-51.2a12.8 12.8 0 1 1 18.1-18.1l51.2 51.2a12.8 12.8 0 0 1-9.05 21.85z" />
        </svg>
        </a>
        """
end

@delay function hfun_page_tags()
    pagetags = globvar("fd_page_tags")
    pagetags === nothing && return ""
    io = IOBuffer()
    tags = pagetags[splitext(locvar("fd_rpath"))[1]] |> collect |> sort
    several = length(tags) > 1
    write(io, """<div class="tags">$(hfun_svg_tag())""")
    for tag in tags[1:end-1]
        t = replace(tag, "_" => " ")
        write(io, """<a href="/tag/$tag/">$t</a>, """)
    end
    tag = tags[end]
    t = replace(tag, "_" => " ")
    write(io, """<a href="/tag/$tag/">$t</a></div>""")
    return String(take!(io))
end


"""
HTML function to insert a Pluto (Julia) notebook into a (markdown) page.
"""
function hfun_insert_notebook()
    return """<pluto-editor class="fullscreen"></pluto-editor>"""
end