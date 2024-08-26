

export BoundingBox

struct BoundingBox
  sideLengths::SVector{3,Float64}
  center::SVector{3,Float64}
end

function Base.:(==)(a::T, b::T) where {T<:BoundingBox}
  return a.sideLengths == b.sideLengths && a.center == b.center  
end

function BoundingBox(params::Dict)
  sideLengths = params["sideLengths"]
  center = params["center"]
  return BoundingBox(sideLengths,center)
end

function toDict(bb::BoundingBox)
  params = Dict{String,Any}()
  params["sideLengths"] = vec(bb.sideLengths)
  params["center"] = bb.center
  return params
end

Base.minimum(bb::BoundingBox) = bb.center - 0.5*bb.sideLengths
Base.maximum(bb::BoundingBox) = bb.center + 0.5*bb.sideLengths

BoundingBox(bbA::BoundingBox, bbB::BoundingBox) = BoundingBox(maximum(bbA) - minimum(bbA) + maximum(bbB) - minimum(bbB), 0.5*(minimum(bbA) + maximum(bbA) + minimum(bbB) + maximum(bbB)))
function BoundingBox(bbs::Vector{BoundingBox})
  minPos = minimum(bbs[1])
  maxPos = maximum(bbs[1])
  for i=2:length(bbs)
    minPos = min.(minPos, minimum(bbs[i]))
    maxPos = max.(maxPos, maximum(bbs[i]))
  end
  return BoundingBox(maxPos - minPos, 0.5*(minPos + maxPos))
end
BoundingBox(sideLengths::Vector{Float64}, center::Vector{Float64}) = BoundingBox(SVector{3,Float64}(sideLengths), SVector{3,Float64}(center))

Base.in(pos, bbox::BoundingBox) = all(pos .>= minimum(bbox)) && all(pos .<= maximum(bbox))