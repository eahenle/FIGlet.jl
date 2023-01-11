using FIGlet, Test

@testset verbose=true "FIGlet.jl" begin
include.([
    "stuff.jl"
    "fonts.jl"
    "render.jl"
    "generate_output.jl"
])
end
