using FIGlet, Test

@testset "Stuff" begin
    iob = IOBuffer(b"flf2a", read=true);
    @test FIGlet.readmagic(iob) == UInt8['f', 'l', 'f', '2', 'a']
    @test FIGlet.FIGletHeader('$', 6, 5, 16, 15, 11) == FIGlet.FIGletHeader('$', 6, 5, 16, 15, 11, 0, 143, 0)
    @test FIGlet.availablefonts() |> length == 680

    @test all(isa.(FIGlet.readfont.(FIGlet.availablefonts()), FIGlet.FIGletFont))

    ff = FIGlet.readfont("jiskan16")
    iob = IOBuffer()
    print(iob, ff)
    @test String(take!(iob)) == "FIGletFont(n=7098)"

    iob = IOBuffer()
    print(iob, ff.font_characters['㙤'])
    @test String(take!(iob)) == "FIGletChar(ord='㙤')"

    @test_throws FIGlet.FontNotFoundError FIGlet.readfont("wat")
    @test_throws FIGlet.FontError FIGlet.readfont(joinpath(@__DIR__, "..", "README.md"))
end
