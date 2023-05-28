<!--
Add here global page variables to use throughout your website.
-->
+++
import Dates

author = "Amro Al-Baali"
short_author = "Amro"
description = "Amro's website"
mintoclevel = 2
maxtoclevel = 3

# defaults for layout variables
cover = false
content_tag = ""


# Add here files or directories that should be ignored by Franklin, otherwise
# these files might be copied and, if markdown, processed by Franklin which
# you might not want. Indicate directories by ending the name with a `/`.
# Base files such as LICENSE.md and README.md are ignored by default.
ignore = ["node_modules/"]

# RSS (the website_{title, descr, url} must be defined to get RSS)
generate_rss = false
website_title = "Franklin Template"
website_descr = "Example website using Franklin"
website_url   = ""

current_year = Dates.year(Dates.today())

notebooks_html_dir = "notebooks/html"
+++

<!-- Links -->
<!-- Create an anchor that can be referenced by markdown (e.g., using [](#anchor-id))-->
\newcommand{\anchor}[1]{~~~<a name="#1"></a>~~~}

<!--
Add here global latex commands to use throughout your pages.
-->
\newcommand{\eqa}[1]{\begin{eqnarray}#1\end{eqnarray}}
\newcommand{\eqal}[1]{\begin{align}#1\end{align}}

\newcommand{\esp}{\quad\!\!}
\newcommand{\spe}[1]{\esp#1\esp}
\newcommand{\speq}{\spe{=}}

\newcommand{\mbb}[1]{\mathbb{#1}}
\newcommand{\mf}[1]{\mathfrak{#1}}

\newcommand{\mbf}[1]{\mathbf{#1}}
<!-- ABI specific -->
\newcommand{\KL}{\mathrm{KL}}

<!-- optimisation specific -->
\newcommand{\xopt}{x^\dagger}
\newcommand{\deltaopt}{\delta^\dagger}
\newcommand{\prox}{\mathrm{prox}}

<!-- matrix theory specific -->
\newcommand{\inv}{^{-1}}

<!-- Figures -->

<!-- Check https://github.com/tlienart/Franklin.jl/issues/437 -->
\newcommand{\figenv}[3]{
~~~
<figure style="text-align:center;">
<img src="!#2" style="padding:0;#3" alt="#1"/>
<figcaption>#1</figcaption>
</figure>
~~~
}
