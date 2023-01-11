function getfontpath(s::AbstractString)
    name = s
    if !isfile(name)
        name = abspath(normpath(joinpath(FONTSDIR, name)))
        if !isfile(name)
            name = "$name.flf"
            !isfile(name) && throw(FontNotFoundError("Cannot find font `$s`."))
        end
    end
    return name
end

function readfont(s::AbstractString)
    name = getfontpath(s)
    font = open(name) do f
        readfont(f)
    end
    return font
end

function readfont(io)
    magic = readmagic(io)

    header = split(readline(io))
    fig_header = FIGletHeader(
                           header[1][1],
                           header[2:end]...
                          )

    for i in 1:fig_header.comment_lines
        discard = readline(io)
    end

    fig_font = FIGletFont(
                          fig_header,
                          Dict{Char, FIGletChar}(),
                          v"2.0.0"
                         )

    for c in ' ':'~'
        fig_font.font_characters[c] = readfontchar(io, c, fig_header.height)
    end

    for c in ['Ä', 'Ö', 'Ü', 'ä', 'ö', 'ü', 'ß']
        if bytesavailable(io) > 1
            fig_font.font_characters[c] = readfontchar(io, c, fig_header.height)
        end
    end

    while !eof(io)
        s = readline(io)
        strip(s) == "" && continue
        s = split(s)[1]
        c = if '-' in s
            Char(-(parse(UInt16, strip(s, '-'))))
        else
            Char(parse(Int, s))
        end
        fig_font.font_characters[c] = readfontchar(io, c, fig_header.height)
    end

    return fig_font
end

function availablefonts(substring)
    fonts = String[]
    for (root, dirs, files) in walkdir(FONTSDIR)
        for file in files
            if !(file in UNPARSEABLES)
                if occursin(lowercase(substring), lowercase(file)) || substring == ""
                    push!(fonts, replace(file, ".flf"=>""))
                end
            end
        end
    end
    sort!(fonts)
    return fonts
end

"""
    availablefonts() -> Vector{String}
    availablefonts(substring::AbstractString) -> Vector{String}

Returns all available fonts.
If `substring` is passed, returns available fonts that contain the case insensitive `substring`.

Example:

    julia> availablefonts()
    680-element Array{String,1}:
     "1943____"
     "1row"
     ⋮
     "zig_zag_"
     "zone7___"

    julia> FIGlet.availablefonts("3d")
    5-element Array{String,1}:
     "3D Diagonal"
     "3D-ASCII"
     "3d"
     "Henry 3D"
     "Larry 3D"

    julia>
"""
availablefonts() = availablefonts("")

function readfontchar(io, ord, height)
    s = readline(io)
    width = length(s)-1
    width == -1 && throw(FontError("Unable to find character `$ord` in FIGlet Font."))
    thechar = Matrix{Char}(undef, height, width)

    for (w, c) in enumerate(s)
        w > width && break
        thechar[1, w] = c
    end

    for h in 2:height
        s = readline(io)
        for (w, c) in enumerate(s)
            w > width && break
            thechar[h, w] = c
        end
    end

    return FIGletChar(ord, thechar)
end
