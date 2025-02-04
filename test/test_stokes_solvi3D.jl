push!(LOAD_PATH, "..")

using Test
using JustRelax

# setup ParallelStencil.jl environment
model = PS_Setup(:cpu, Float64, 3)
environment!(model)

include("../miniapps/benchmarks/stokes3D/solvi/SolVi3D.jl")

function check_convergence_case1()
    nx = 16
    ny = 16
    nz = 16

    # model specific parameters
    Δη = 1e-3 # viscosity ratio between matrix and inclusion
    rc = 1e0 # radius of the inclusion
    εbg = 1e0 # background strain rate
    lx, ly, lz = 1e1, 1e1, 1e1 # domain siye in x and y directions

    # run model
    _, _, iters = solVi3D(;
        Δη=Δη,
        nx=nx,
        ny=ny,
        nz=nz,
        lx=lx,
        ly=ly,
        lz=lz,
        rc=rc,
        εbg=εbg,
        init_MPI=false,
        finalize_MPI=false,
    )

    iters_expected = (iter=500, err_evo1=[ 7.493148324044796e-10])
    passed = iters.iter == iters_expected.iter &&
       iters.err_evo1[end] ≈ iters_expected.err_evo1[end]

    return passed
end

@testset begin
    @test check_convergence_case1()
end
