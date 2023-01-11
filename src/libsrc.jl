const FONTSDIR = abspath(
    normpath(joinpath(artifact"fonts", "FIGletFonts-0.5.0", "fonts"))
)
const UNPARSEABLES = [
              "nvscript.flf",
             ]
const DEFAULTFONT = "Standard"

abstract type FIGletError <: Exception end

"""
Width is not sufficient to print a character
"""
struct CharNotPrinted <: FIGletError end

"""
Font can't be located
"""
struct FontNotFoundError <: FIGletError
    msg::String
end

Base.showerror(io::IO, e::FontNotFoundError) = print(io, "FontNotFoundError: $(e.msg)")

"""
Problem parsing a font file
"""
struct FontError <: FIGletError
    msg::String
end

Base.showerror(io::IO, e::FontError) = print(io, "FontError: $(e.msg)")


"""
Color is invalid
"""
struct InvalidColorError <: FIGletError end

Base.@enum(Layout,
    FullWidth                   =       -1,
    HorizontalSmushingRule1     =        1,
    HorizontalSmushingRule2     =        2,
    HorizontalSmushingRule3     =        4,
    HorizontalSmushingRule4     =        8,
    HorizontalSmushingRule5     =       16,
    HorizontalSmushingRule6     =       32,
    HorizontalFitting           =       64,
    HorizontalSmushing          =      128,
    VerticalSmushingRule1       =      256,
    VerticalSmushingRule2       =      512,
    VerticalSmushingRule3       =     1024,
    VerticalSmushingRule4       =     2048,
    VerticalSmushingRule5       =     4096,
    VerticalFitting             =     8192,
    VerticalSmushing            =    16384
)

struct FIGletHeader
    hardblank::Char
    height::Int
    baseline::Int
    max_length::Int
    old_layout::Int
    comment_lines::Int
    print_direction::Int
    full_layout::Int
    codetag_count::Int

    function FIGletHeader(
                          hardblank,
                          height,
                          baseline,
                          max_length,
                          old_layout,
                          comment_lines,
                          print_direction=0,
                          full_layout=-2,
                          codetag_count=0,
                          args...
                      )
        length(args) >0 && @warn "Received unknown header attributes: `$args`."
        if full_layout == -2
            full_layout = old_layout
            if full_layout == 0
                full_layout = Int(HorizontalFitting)
            elseif full_layout == -1
                full_layout = 0
            else
                full_layout = ( full_layout & 63 ) | Int(HorizontalSmushing)
            end
        end
        height < 1 && ( height = 1 )
        max_length < 1 && ( max_length = 1 )
        print_direction < 0 && ( print_direction = 0 )
        # max_length += 100 # Give ourselves some extra room
        new(
            hardblank, 
            height, 
            baseline, 
            max_length, 
            old_layout, 
            comment_lines, 
            print_direction, 
            full_layout, 
            codetag_count
        )
    end
end

function FIGletHeader(
                      hardblank,
                      height::AbstractString,
                      baseline::AbstractString,
                      max_length::AbstractString,
                      old_layout::AbstractString,
                      comment_lines::AbstractString,
                      print_direction::AbstractString="0",
                      full_layout::AbstractString="-2",
                      codetag_count::AbstractString="0",
                      args...
                     )
    return FIGletHeader(
                        hardblank,
                        parse(Int, height),
                        parse(Int, baseline),
                        parse(Int, max_length),
                        parse(Int, old_layout),
                        parse(Int, comment_lines),
                        parse(Int, print_direction),
                        parse(Int, full_layout),
                        parse(Int, codetag_count),
                        args...
                       )
end

struct FIGletChar
    ord::Char
    thechar::Matrix{Char}
end

struct FIGletFont
    header::FIGletHeader
    font_characters::Dict{Char,FIGletChar}
    version::VersionNumber
end

Base.show(io::IO, ff::FIGletFont) = 
    print(io, "FIGletFont(n=$(length(ff.font_characters)))")

function readmagic(io)
    magic = read(io, 5)
    magic[1:4] != UInt8['f', 'l', 'f', '2'] && throw(
        FontError("File is not a valid FIGlet Lettering Font format. 
        Magic header values must start with `flf2`.")
    )
    magic[5] != UInt8('a') && @warn "File may be a FLF format but not flf2a."
    return magic # File has valid FIGlet Lettering Font format magic header.
end

Base.show(io::IO, fc::FIGletChar) = print(io, "FIGletChar(ord='$(fc.ord)')")
