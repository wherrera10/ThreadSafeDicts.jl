using Documenter, ThreadSafeDicts

DocMeta.setdocmeta!(ThreadSafeDicts, :DocTestSetup, :(using ThreadSafeDicts); recursive=true)

makedocs(;
    modules=[ThreadSafeDicts],
    authors="William Herrera and various patch submitters",
    sitename="ThreadSafeDicts.jl Documentation",
    repo="github.com/wherrera10/ThreadSafeDicts.jl.git",
    format=Documenter.HTML(;
        canonical="https://wherrera10.github.io/ThreadSafeDicts.jl",
        edit_link="master",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        # Add future pages here, e.g., "API Reference" => "api.md"
    ],
)

deploydocs(;
    repo="github.com/wherrera10/ThreadSafeDicts.jl.git",
    devbranch="master",
)
