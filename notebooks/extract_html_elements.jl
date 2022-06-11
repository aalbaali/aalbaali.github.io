### A Pluto.jl notebook ###
# v0.19.5

using Markdown
using InteractiveUtils

# ╔═╡ 9343f86a-a1e6-4bdb-9f9f-ba4fb02ae644
using AbstractTrees

# ╔═╡ b2eea7fa-e86c-11ec-224e-471403027963
# Julia notebook filename (no extension)
filename = "manifold_jacobians_notebook"

# ╔═╡ 8330e018-e5d7-46e0-ab5a-a0a7311e3e7c
# HTML filename
filename_html = filename * ".html";

# ╔═╡ 87287a12-23f1-4525-bc54-ca4e6ba31dcc
if isfile(filename_html);
	lines = readlines(filename_html);
end;

# ╔═╡ 4726c93f-7f3b-4700-b2e4-4bb10ec56b2c
html_content = join(lines, "\n");

# ╔═╡ 3cb3cb58-1150-4c24-ba79-50dc98d977dc
parsed_html = parsehtml(html_content);

# ╔═╡ 3530a6d5-5685-4ede-8aee-742937b29f96
# Get root element (i.e., all the HTML document)
root = parsed_html.root;

# ╔═╡ b60d9136-a85d-45c9-84be-90c813ae11e3
nodeText(root[1]);

# ╔═╡ f03a7988-83ef-4457-b58d-26c49c1ed34c
function get_head_elem(root)
	for elem in PreOrderDFS(root)
		try
			if tag(elem) == :head
				println("Found a <head> element")
				return elem;
			end
		catch
		end
	end
end

# ╔═╡ b1a89ab3-4b8f-4c48-87ee-83fbddb74c79
# Traverse the parsed html tree and print the tags
for elem in PreOrderDFS(root)
	try
		if tag(elem) == :head
			println("Found a <head> element")
			head = elem;
		end
	catch
	end
end

# ╔═╡ 35b28ae0-36b5-4aea-baf0-1cf6ded4ca91
head = get_head_elem(root);

# ╔═╡ be68b4f1-0d48-4fd4-bb43-cfa6dabfb23a
md"""
Now we traverse the head element to find an elelemnt with a matching selector. To this, we use `Cascadia`.
"""

# ╔═╡ cfda2a36-58ec-486f-b75f-5539628816da
# Set selector. Using `[foo]` tries to find HTML elements with `foo` selector (e.g., <div class="nice" foo=25>)
s = Selector("[data-pluto-file]");

# ╔═╡ 402db4ae-0bd8-4b6f-bba7-bce0bf70c915
# Get all elements that has the selector
eachmatch(s, head)

# ╔═╡ f6f3db0c-d086-4677-994f-769b77e1fc22
# Turns out, we can skip lots of the previous steps by doing the following
matches = eachmatch(s, root)

# ╔═╡ fc18a5f9-66bf-4b48-addb-0dc0fd76c009
function get_pluto_elem(root)
	s = Selector("[data-pluto-file]");
	matches = eachmatch(s, root);
	for elem in matches
		if tag(elem) == :script
			print("Found the main script!");
			return elem;
		end
	end
end

# ╔═╡ 7def921b-76ff-4e35-8e35-21624c4be784


# ╔═╡ cd3b0174-bfaa-4610-b86f-f59cff395244
pluto_elem = get_pluto_elem(root)

# ╔═╡ a960fd54-50ee-4fa2-8118-1a2b71b4cc77
nodeText(pluto_elem)

# ╔═╡ 3fef8f1e-5234-4b44-8cd1-942b1bff40bb
pluto_elem.attributes

# ╔═╡ 866b3fa2-45ea-4fb6-bc1f-43ae75494825
pluto_elem.children

# ╔═╡ c6fcb6a4-8c40-43b1-9659-7c0a6f2efe28
md"""
To print element with, run (it's a long output)
```
prettyprint(stdout, matches[2])
```
`prettyprint` takes an `IO` object and an `HTMLElemen` object (check `methods(prettyprint)` to see other methods).
Thus, it's possible to export to a `stdout` stream, a file strea, etc.

An example of exporting to a file stream is
```
prettyprint(open("dd.html", "w"), matches[2]);
```
To get a string, use an `IOBuffer`, which is similar to a string stream in C++. To do so, run
```
ss = IOBuffer()
prettyprint(ss, matches[2]);
output = String(take!(ss));
```
"""

# ╔═╡ 279d2103-9387-48ff-a880-1ed085445294
begin
	ss = IOBuffer()
	prettyprint(ss, matches[2]);
	output = String(take!(ss));	
end

# ╔═╡ c7873dbf-27f5-47fa-89f9-54ae43a46983
keys(matches[2].attributes)

# ╔═╡ a8e72a17-b41b-42d4-9c39-9dd516c6aa71
md"""
# Full function
Full implementation of a function that extracts the `launch-parmeters` files
"""

# ╔═╡ 9888a935-a886-421b-8b65-3e4b60464065
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

# ╔═╡ ad9593ea-df6e-4d8f-b6e1-8d13b29e83d2
grab_pluto_launch_params(filename_html)

# ╔═╡ 67ace316-2a9a-4e29-a211-8f0dbf75c8c7
begin
	using Gumbo;
	using Cascadia;
end

# ╔═╡ e99c0fdc-ae86-4041-8cfc-9baeab5d2a79
using Gumbo

# ╔═╡ 9af573d8-da43-4cfb-9a65-f67b8520466b
# Use this package to get selector text to choose CSS elements
using Cascadia

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
AbstractTrees = "1520ce14-60c1-5f80-bbc7-55ef81b5835c"
Cascadia = "54eefc05-d75b-58de-a785-1a3403f0919f"
Gumbo = "708ec375-b3d6-5a57-a7ce-8257bf98657a"

[compat]
AbstractTrees = "~0.3.4"
Cascadia = "~1.0.1"
Gumbo = "~0.8.0"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.7.2"
manifest_format = "2.0"

[[deps.AbstractTrees]]
git-tree-sha1 = "03e0550477d86222521d254b741d470ba17ea0b5"
uuid = "1520ce14-60c1-5f80-bbc7-55ef81b5835c"
version = "0.3.4"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.Cascadia]]
deps = ["AbstractTrees", "Gumbo"]
git-tree-sha1 = "95629728197821d21a41778d0e0a49bc2d58ab9b"
uuid = "54eefc05-d75b-58de-a785-1a3403f0919f"
version = "1.0.1"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.Downloads]]
deps = ["ArgTools", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[deps.Gumbo]]
deps = ["AbstractTrees", "Gumbo_jll", "Libdl"]
git-tree-sha1 = "e711d08d896018037d6ff0ad4ebe675ca67119d4"
uuid = "708ec375-b3d6-5a57-a7ce-8257bf98657a"
version = "0.8.0"

[[deps.Gumbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "29070dee9df18d9565276d68a596854b1764aa38"
uuid = "528830af-5a63-567c-a44a-034ed33b8444"
version = "0.10.2+0"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "abc9885a7ca2052a736a600f7fa66209f96506e1"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.4.1"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "47e5f437cc0e7ef2ce8406ce1e7e24d44915f88d"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.3.0"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
"""

# ╔═╡ Cell order:
# ╠═b2eea7fa-e86c-11ec-224e-471403027963
# ╠═8330e018-e5d7-46e0-ab5a-a0a7311e3e7c
# ╠═87287a12-23f1-4525-bc54-ca4e6ba31dcc
# ╠═4726c93f-7f3b-4700-b2e4-4bb10ec56b2c
# ╠═e99c0fdc-ae86-4041-8cfc-9baeab5d2a79
# ╠═3cb3cb58-1150-4c24-ba79-50dc98d977dc
# ╠═3530a6d5-5685-4ede-8aee-742937b29f96
# ╠═b60d9136-a85d-45c9-84be-90c813ae11e3
# ╠═9343f86a-a1e6-4bdb-9f9f-ba4fb02ae644
# ╠═f03a7988-83ef-4457-b58d-26c49c1ed34c
# ╠═b1a89ab3-4b8f-4c48-87ee-83fbddb74c79
# ╠═35b28ae0-36b5-4aea-baf0-1cf6ded4ca91
# ╟─be68b4f1-0d48-4fd4-bb43-cfa6dabfb23a
# ╠═9af573d8-da43-4cfb-9a65-f67b8520466b
# ╠═cfda2a36-58ec-486f-b75f-5539628816da
# ╠═402db4ae-0bd8-4b6f-bba7-bce0bf70c915
# ╠═f6f3db0c-d086-4677-994f-769b77e1fc22
# ╠═fc18a5f9-66bf-4b48-addb-0dc0fd76c009
# ╠═7def921b-76ff-4e35-8e35-21624c4be784
# ╠═cd3b0174-bfaa-4610-b86f-f59cff395244
# ╠═a960fd54-50ee-4fa2-8118-1a2b71b4cc77
# ╠═3fef8f1e-5234-4b44-8cd1-942b1bff40bb
# ╠═866b3fa2-45ea-4fb6-bc1f-43ae75494825
# ╟─c6fcb6a4-8c40-43b1-9659-7c0a6f2efe28
# ╠═279d2103-9387-48ff-a880-1ed085445294
# ╠═c7873dbf-27f5-47fa-89f9-54ae43a46983
# ╟─a8e72a17-b41b-42d4-9c39-9dd516c6aa71
# ╠═67ace316-2a9a-4e29-a211-8f0dbf75c8c7
# ╠═9888a935-a886-421b-8b65-3e4b60464065
# ╠═ad9593ea-df6e-4d8f-b6e1-8d13b29e83d2
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
