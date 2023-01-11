using FIGlet, Test

@testset "Generate Output" begin
    generated = FIGlet.generate_output("foo")
    @test isfile("output.txt")
    written = String(read("output.txt"))
    @test generated == written

    @test command_main(["bar", "--output-file", "output2.txt", "--font", "42"]) == 0
    @test isfile("output2.txt")
    written = String(read("output2.txt"))
    @test FIGlet.generate_output("bar"; font=42, output_file="output3.txt") == written
end
