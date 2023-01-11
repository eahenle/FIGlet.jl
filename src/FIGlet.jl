module FIGlet

using Comonicon, Pkg.Artifacts
import Base

include.([
    "libsrc.jl"
    "fonts.jl"
    "smush.jl"
    "render.jl"
    "banner.jl"
])

export command_main

end
