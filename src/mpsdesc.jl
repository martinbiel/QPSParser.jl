struct MPSDescription{T<:AbstractFloat}
  Q::Matrix{T}
  q₁::Vector{T}
  q₂::T
  c₁::Vector{T}
  C::Matrix{T}
  c₂::Vector{T}
  A::Matrix{T}
  b::Vector{T}
  lb::Vector{T}
  ub::Vector{T}
  vars::Vector{Symbol}
  name::String
end

function MPSDescription(::Type{T}, n::Int, m₁::Int, m₂::Int,
  name::AbstractString = "QP") where T<:AbstractFloat
  MPSDescription{T}(zeros(T, n, n), zeros(T, n), zero(T), fill(convert(T, -Inf), m₁),
    zeros(T, m₁, n), fill(convert(T, Inf), m₁), zeros(T, m₂, n), zeros(T, m₂),
    zeros(T, n), fill(convert(T, Inf), n), Symbol[Symbol(:x_,k) for k in 1:n],
    name)
end

MPSDescription(n::Int, m₁::Int, m₂::Int, name::AbstractString = "QP")           =
  MPSDescription(Float64, n, m₁, m₂, name)
MPSDescription(t::Type{T}, name::AbstractString = "QP") where T<:AbstractFloat  =
  MPSDescription(t, 0, 0, 0, name)
MPSDescription(name::AbstractString = "QP")                                     =
  MPSDescription(Float64, name)

function MPSDescription(::Type{T}, Q::AbstractMatrix, q₁::AbstractVector, q₂::Real,
  c₁::AbstractVector, C::AbstractMatrix, c₂::AbstractVector, A::AbstractMatrix,
  b::AbstractVector, lb::AbstractVector, ub::AbstractVector,
  vars::AbstractVector{S}, name::AbstractString) where T<:AbstractFloat where
  S<:Union{Symbol,Char,AbstractString}

  n₁, n₂  = size(Q)
  m₁, n₃  = size(C)
  m₂, n₄  = size(A)
  n₅      = length(vars)

  if n₁ ≠ n₂
    warn("MPSDescription: `Q` matrix must be symmetric")
    throw(DomainError())
  elseif n₁ ≠ length(q₁)
    warn("MPSDescription: `q₁` must have $(n₁) elements")
    throw(DomainError())
  elseif n₁ ≠ n₃
    warn("MPSDescription: `C` must have $(n₁) columns")
    throw(DomainError())
  elseif m₁ ≠ length(c₁) || m₁ ≠ length(c₂)
    warn("MPSDescription: Both `c₁` and `c₂` must have $(m₁) elements")
    throw(DomainError())
  elseif n₁ ≠ n₄
    warn("MPSDescription: `A` must have $(n₁) columns")
    throw(DomainError())
  elseif m₂ ≠ length(b)
    warn("MPSDescription: `b` must have $(m₂) elements")
    throw(DomainError())
  elseif n₁ ≠ length(lb) || n₁ ≠ length(ub)
    warn("MPSDescription: Both `lb` and `ub` must have $(n₁) elements")
    throw(DomainError())
  elseif n₁ ≠ length(vars)
    warn("MPSDescription: `vars` must have $(n₁) elements")
    throw(DomainError())
  end

  MPSDescription{T}(Q, q₁, q₂, c₁, C, c₂, A, b, lb, ub, vars, name)

end

MPSDescription(Q::AbstractMatrix, q₁::AbstractVector, q₂::Real, c₁::AbstractVector,
  C::AbstractMatrix, c₂::AbstractVector, A::AbstractMatrix, b::AbstractVector,
  lb::AbstractVector, ub::AbstractVector, vars::AbstractVector{S},
  name::AbstractString) where S<:Union{Symbol,Char,AbstractString} =
  MPSDescription(Float64, Q, q₁, q₂, c₁, C, c₂, A, b, lb, ub, vars, name)


objective(qp::MPSDescription)     = (qp.Q, qp.q₁, qp.q₂)
inequalities(qp::MPSDescription)  = (qp.C, qp.c₁, qp.c₂)
equalities(qp::MPSDescription)    = (qp.A, qp.b)
bounds(qp::MPSDescription)        = (qp.lb, qp.ub)
variables(qp::MPSDescription)     = qp.vars
name(qp::MPSDescription)          = qp.name