raw"""

    smushem(lch::Char, rch::Char, fh::FIGletHeader) -> Char

Given 2 characters, attempts to smush them into 1, according to
smushmode.  Returns smushed character or '\0' if no smushing can be
done.

smushmode values are sum of following (all values smush blanks):
    1: Smush equal chars (not hardblanks)
    2: Smush '_' with any char in hierarchy below
    4: hierarchy: "|", "/\", "[]", "{}", "()", "<>"
       Each class in hier. can be replaced by later class.
    8: [ + ] -> |, { + } -> |, ( + ) -> |
    16: / + \ -> X, > + < -> X (only in that order)
    32: hardblank + hardblank -> hardblank

"""
function smushem(lch::Char, rch::Char, fh::FIGletHeader)

    smushmode = fh.full_layout
    hardblank = fh.hardblank
    right2left = fh.print_direction

    lch==' ' && return rch
    rch==' ' && return lch

    if ( smushmode & Int(HorizontalSmushing::Layout) ) == 0 return '\0' end

    if ( smushmode & 63 ) == 0
        # This is smushing by universal overlapping.

        # Ensure overlapping preference to visible characters.
        if lch == hardblank return rch end
        if rch == hardblank return lch end

        # Ensures that the dominant (foreground) fig-character for overlapping is the 
        # latter in the user's text, not necessarily the rightmost character.
        if right2left == 1 return lch end

        # Catch all exceptions
        return rch
    end

    if smushmode & Int(HorizontalSmushingRule6::Layout) != 0
        if lch == hardblank && rch == hardblank return lch end
    end

    if lch == hardblank || rch == hardblank return '\0' end

    if smushmode & Int(HorizontalSmushingRule1::Layout) != 0
        if lch == rch return lch end
    end

    if smushmode & Int(HorizontalSmushingRule2::Layout) != 0
        if lch == '_' && rch in "|/\\[]{}()<>" return rch end
        if rch == '_' && lch in "|/\\[]{}()<>" return lch end
    end

    if smushmode & Int(HorizontalSmushingRule3::Layout) != 0
        if lch == '|' && rch in "/\\[]{}()<>" return rch end
        if rch == '|' && lch in "/\\[]{}()<>" return lch end
        if lch in "/\\" && rch in "[]{}()<>" return rch end
        if rch in "/\\" && lch in "[]{}()<>" return lch end
        if lch in "[]" && rch in "{}()<>" return rch end
        if rch in "[]" && lch in "{}()<>" return lch end
        if lch in "{}" && rch in "()<>" return rch end
        if rch in "{}" && lch in "()<>" return lch end
        if lch in "()" && rch in "<>" return rch end
        if rch in "()" && lch in "<>" return lch end
    end

    if smushmode & Int(HorizontalSmushingRule4::Layout) != 0
        if lch == '[' && rch == ']' return '|' end
        if rch == '[' && lch == ']' return '|' end
        if lch == '{' && rch == '}' return '|' end
        if rch == '{' && lch == '}' return '|' end
        if lch == '(' && rch == ')' return '|' end
        if rch == '(' && lch == ')' return '|' end
    end

    if smushmode & Int(HorizontalSmushingRule5::Layout) != 0
        if lch == '/' && rch == '\\' return '|' end
        if rch == '/' && lch == '\\' return 'Y' end

        # Don't want the reverse of below to give 'X'.
        if lch == '>' && rch == '<' return 'X' end
    end

    return '\0'
end

function smushamount(current::Matrix{Char}, thechar::Matrix{Char}, fh::FIGletHeader)
    smushmode = fh.full_layout
    right2left = fh.print_direction

    # huh??
    if (smushmode & (Int(HorizontalSmushing::Layout) | Int(HorizontalFitting::Layout)) == 0)
        return 0
    end

    nrows_l, ncols_l = size(current)
    _, ncols_r = size(thechar)

    maximum_smush = ncols_r
    smush = ncols_l

    for row in 1:nrows_l
        cl = '\0'
        cr = '\0'
        linebd = 0
        charbd = 0
        if right2left == 1
            if maximum_smush > ncols_l
                maximum_smush = ncols_l
            end

            for col_r in ncols_r:-1:1
                cr = thechar[row, col_r]
                if cr == ' '
                    charbd += 1
                    continue
                else
                    break
                end
            end
            for col_l in 1:ncols_l
                cl = current[row, col_l]
                if cl == '\0' || cl == ' '
                    linebd += 1
                    continue
                else
                    break
                end
            end
        else
            for col_l in ncols_l:-1:1
                cl = current[row, col_l]
                if col_l > 1 && ( cl == '\0' || cl == ' ' )
                    linebd += 1
                    continue
                else
                    break
                end
            end

            for col_r in 1:ncols_r
                cr = thechar[row, col_r]
                if cr == ' '
                    charbd += 1
                    continue
                else
                    break
                end
            end
        end

        smush = linebd + charbd

        if cl == '\0' || cl == ' '
            smush += 1
        elseif (cr != '\0')
            if smushem(cl, cr, fh) != '\0'
                smush += 1
            end
        end

        if smush < maximum_smush
            maximum_smush = smush
        end
    end
    return maximum_smush
end
