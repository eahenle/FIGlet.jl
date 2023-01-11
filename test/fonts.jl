using FIGlet, Test

@testset "Fonts" begin
    pass = true
    for (i, font) in enumerate(FIGlet.availablefonts())
        try
            iob = IOBuffer()
            sentence = "the quick brown fox jumps over the lazy dog"
            FIGlet.render(iob, sentence, font)
            FIGlet.render(iob, uppercase(sentence), font)
            @assert length(String(take!(iob))) > 0
        catch
            println("Cannot render font: number = $i, name = \"$font\"")
            pass = false
        end
    end
    @test pass
end
