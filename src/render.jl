function addchar(current::Matrix{Char}, thechar::Matrix{Char}, fh::FIGletHeader)
    right2left = fh.print_direction

    current = copy(current)
    thechar = copy(thechar)
    maximum_smush = smushamount(current, thechar, fh)

    _, ncols_l = size(current)
    nrows_r, ncols_r = size(thechar)

    for row in 1:nrows_r
        if right2left == 1
            for smush in 1:maximum_smush
                col_r = ncols_r - maximum_smush + smush
                col_r < 1 && ( col_r = 1 )
                thechar[row, col_r] = smushem(thechar[row, col_r], current[row, smush], fh)
            end
        else
            for smush in 1:maximum_smush
                col_l = ncols_l - maximum_smush + smush
                col_l < 1 && ( col_l = 1 )
                current[row, col_l] = smushem(current[row, col_l], thechar[row, smush], fh)
            end
        end

    end
    if right2left == 1
        current = hcat(
                       thechar,
                       current[:, ( maximum_smush + 1 ):end],
                      )

    else
        current = hcat(
                       current,
                       thechar[:, ( maximum_smush + 1 ):end],
                      )
    end

    return current
end

function render(io, text::AbstractString, ff::FIGletFont)
    (HEIGHT, WIDTH) = Base.displaysize(io)

    words = Matrix{Char}[]
    for word in split(text)
        current = fill(' ', ff.header.height, 1)
        for c in word
            current = addchar(current, ff.font_characters[c].thechar, ff.header)
        end
        current = addchar(current, ff.font_characters[' '].thechar, ff.header)
        push!(words, current)
    end

    lines = Matrix{Char}[]
    current = fill('\0', ff.header.height, 0)
    for word in words
        if size(current)[2] + size(word)[2] < WIDTH
            if ff.header.print_direction == 1
                current = hcat(word, current)
            else
                current = hcat(current, word)
            end
        else
            push!(lines, current)
            current = fill('\0', ff.header.height, 0)
            if ff.header.print_direction == 1
                current = hcat(word, current)
            else
                current = hcat(current, word)
            end
        end
    end
    push!(lines, current)

    for line in lines
        nrows, ncols = size(line)
        for r in 1:nrows
            s = join(line[r, :])
            s = replace(s, ff.header.hardblank=>' ') |> rstrip
            print(io, s)
            println(io)
        end
        println(io)
    end
end

render(io, text::AbstractString, ff::AbstractString) = render(io, text, readfont(ff))

"""
    render(text::AbstractString, font::Union{AbstractString, FIGletFont})

Renders `text` using `font` to `stdout`

Example:

    render("hello world", "standard")
    render("hello world", readfont("standard"))
"""
render(text::AbstractString, font=DEFAULTFONT) = render(stdout, text, font)
