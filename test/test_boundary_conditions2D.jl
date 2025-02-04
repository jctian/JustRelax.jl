push!(LOAD_PATH, "..")

using Test
using JustRelax

model = PS_Setup(:cpu, Float64, 2)
environment!(model)

@testset begin
    di = 0.1, 0.1
    
    # periodicity
    n = 5 # number of elements
    Vx, Vy = @rand(n+1,n+2), @rand(n+2,n+1)
    bcs = FlowBoundaryConditions(; 
        no_slip = (left=false, right=false, top=false, bot=false), 
        free_slip = (left=false, right=false, top=false, bot=false), 
        periodicity = (left=true, right=true, top=true, bot=true) 
    )
    flow_bcs!(bcs, Vx, Vy, di)
    
    @test @views Vx[:, 1] == Vx[:, end-1]
    @test @views Vx[:, end] == Vx[:, 2]
    @test @views Vy[1, :] == Vy[end-1, :]
    @test @views Vy[end, :] == Vy[2, :]
    
    # free-slip
    bcs = FlowBoundaryConditions(; 
        no_slip = (left=false, right=false, top=false, bot=false), 
        free_slip = (left=true, right=true, top=true, bot=true),
        periodicity = (left=false, right=false, top=false, bot=false)
    )
    flow_bcs!(bcs, Vx, Vy, di)
    
    @test @views Vx[:, 1] == Vx[:, 2]
    @test @views Vx[:, end] == Vx[:, end-1]
    @test @views Vy[1, :] == Vy[2, :]
    @test @views Vy[end, :] == Vy[end-1, :]
    
    # no-slip
    bcs = FlowBoundaryConditions(; 
        no_slip = (left=true, right=true, top=true, bot=true),
        free_slip = (left=false, right=false, top=false, bot=false), 
        periodicity = (left=false, right=false, top=false, bot=false)
    )
    flow_bcs!(bcs, Vx, Vy, di)
    @test @views Vx[1, :] == Vx[end, :] == Vy[:, 1] == Vy[:, end]
    @test @views Vx[:, 1] == Vx[:, 2]*0.5/di[1]
    @test @views Vx[:, end] == Vx[:, end-1]*0.5/di[1]
    @test @views Vy[1, :] == Vy[2, :]*0.5/di[1]
    @test @views Vy[end, :] == Vy[end-1, :]*0.5/di[1]
end
