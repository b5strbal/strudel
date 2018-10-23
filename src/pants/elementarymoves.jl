module ElementaryMoves

export apply_firstmove!, apply_secondmove!, applymove_onesided_to_onesided!, applymove_twoonesided_to_twosided!, applymove_twosided_to_twoonesided!, apply_halftwist!, apply_dehntwist!


using Donut.Pants
using Donut.Pants: _pantscurve, _getpant
using Donut.Utils: nextindex, previndex, otherside
using Donut.Constants: LEFT, RIGHT
# function elementarymove_type(pd::PantsDecomposition, curveindex::Int)
#     if isboundary_pantscurve(pd, curveindex)
#         return
#     end
# end

function _setpantscurveside_to_pantend(pd::PantsDecomposition, curveindex::Int,
        side::Int, pantnumber::Int, bdyindex::Int)
    pantscurve = _pantscurve(pd, curveindex)
    if curveindex < 0
        side = otherside(side)
    end
    pantscurve.neighboring_pantends[side].pantnumber = pantnumber
    pantscurve.neighboring_pantends[side].bdyindex = bdyindex
end

function _setboundarycurves(pd::PantsDecomposition, pantindex::Int, bdy1::Int, bdy2::Int, bdy3::Int)
    pant = _getpant(pd, pantindex)
    pant.boundaries[1] = bdy1
    pant.boundaries[2] = bdy2
    pant.boundaries[3] = bdy3
end

function apply_secondmove!(pd::PantsDecomposition, curveindex::Int)
    @assert istwosided_pantscurve(pd, curveindex)
    leftpant = pant_nextto_pantscurve(pd, curveindex, LEFT)
    leftindex = bdyindex_nextto_pantscurve(pd, curveindex, LEFT)
    rightpant = pant_nextto_pantscurve(pd, curveindex, RIGHT)
    rightindex = bdyindex_nextto_pantscurve(pd, curveindex, RIGHT)
    @assert leftpant != rightpant
    leftor_preserving = ispantscurveside_orientationpreserving(pd, curveindex, LEFT)
    rightor_preserving = ispantscurveside_orientationpreserving(pd, curveindex, RIGHT)

    topleft = pantend_to_pantscurveside(pd, leftpant, nextindex(leftindex, 3))
    bottomleft = pantend_to_pantscurveside(pd, leftpant, previndex(leftindex, 3))
    topright = pantend_to_pantscurveside(pd, rightpant, previndex(rightindex, 3))
    bottomright = pantend_to_pantscurveside(pd, rightpant, nextindex(rightindex, 3))

    if !leftor_preserving
        topleft, bottomleft = (-bottomleft[1], otherside(bottomleft[2])), (-topleft[1], otherside(topleft[2]))
    end
    if !rightor_preserving
        topright, bottomright = (-bottomright[1], otherside(bottomright[2])), (-topright[1], otherside(topright[2]))
    end

    # println("Topleft: ", topleft)
    # println("Bottomleft: ", bottomleft)
    # println("Topright: ", topright)
    # println("Bottomright: ", bottomright)


    # turning the middle curve left by 90 degrees
    # top pant
    toppant = rightpant
    _setboundarycurves(pd, toppant, -curveindex, topright[1], topleft[1])
    _setpantscurveside_to_pantend(pd, curveindex, RIGHT, toppant, 1)
    # bottom pant
    bottompant = leftpant
    _setboundarycurves(pd, bottompant, curveindex, bottomleft[1], bottomright[1])
    _setpantscurveside_to_pantend(pd, curveindex, LEFT, bottompant, 1)

    _setpantscurveside_to_pantend(pd, topleft[1], topleft[2], toppant, 3)
    _setpantscurveside_to_pantend(pd, topright[1], topright[2], toppant, 2)
    _setpantscurveside_to_pantend(pd, bottomleft[1], bottomleft[2], bottompant, 2)
    _setpantscurveside_to_pantend(pd, bottomright[1], bottomright[2], bottompant, 3)
end


function apply_firstmove!(pd::PantsDecomposition, curveindex::Int)
    @assert istwosided_pantscurve(pd, curveindex)
    @assert pant_nextto_pantscurve(pd, curveindex, LEFT) == pant_nextto_pantscurve(pd, curveindex, RIGHT)
    # nothing to do, the gluing list does not change.
    # TODO: shall we permute the boundaries so that the boundary of the torus has index 1?
end


function applymove_onesided_to_onesided(pd::PantsDecomposition, curveindex::Int)
    @assert isonesided_pantscurve(pd, curveindex)

end

function applymove_twoonesided_to_twosided(pd::PantsDecomposition, curveindex1::Int, curveindex2::Int)

end

function applymove_twosided_to_twoonesided(pd::PantsDecomposition, curve)

end


function apply_halftwist!(pd::PantsDecomposition, pantindex::Int, bdyindex::Int)
    boundaries = pantboundaries(pd, pantindex)
    idx1 = bdyindex
    idx2 = nextindex(bdyindex, 3)
    idx3 = previndex(bdyindex, 3)

    curve2, side2 = pantend_to_pantscurveside(pd, pantindex, idx2)
    curve3, side3 = pantend_to_pantscurveside(pd, pantindex, idx3)

    boundaries[idx2], boundaries[idx3] = boundaries[idx3], boundaries[idx2]
    _setboundarycurves(pd, pantindex, boundaries...)
    _setpantscurveside_to_pantend(pd, curve2, side2, pantindex, idx3)
    _setpantscurveside_to_pantend(pd, curve3, side3, pantindex, idx2)
end

function apply_dehntwist!(pd::PantsDecomposition, pantindex::Int, bdyindex::Int, direction::Int)
    # The gluing list remains the same, nothing to do.
end

end