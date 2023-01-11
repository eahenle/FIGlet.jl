module FIGlet

using Pkg.Artifacts
import Base

include.([
    "libsrc.jl"
    "fonts.jl"
    "smush.jl"
    "render.jl"
    "banner.jl"
])

export availablefonts, render, generate_output

end
