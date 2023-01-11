function generate_output(s::AbstractString, font::AbstractString="Standard")
    fontpath = FIGlet.getfontpath(font)
    io = IOContext(IOBuffer())
    render(io, s, FIGlet.readfont(fontpath))
    jl_output = String(take!(io.io))
    cli_output = read(`figlet -f $fontpath $s`, String)

    return strip(join(strip.(split(jl_output, '\n')), '\n')), strip(join(strip.(split(cli_output, '\n')), '\n'))
end
