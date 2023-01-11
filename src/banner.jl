@main function generate_output(
    s::AbstractString;
    font::Int=rand(eachindex(availablefonts())),
    output_file::String="output.txt"
)::String
    io = IOContext(IOBuffer())
    render(io, s, availablefonts()[font])
    str = String(take!(io.io))
    open(output_file, "w") do f
        write(f, str)
    end
    return str
end
