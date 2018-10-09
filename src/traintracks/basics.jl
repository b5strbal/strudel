export TrainTrack, branch_endpoint, numoutgoing_branches, outgoing_branches, outgoing_branch, outgoing_branch_index, istwisted, isswitch, isbranch, switches, branches, switchvalence

using Donut.Constants: LEFT, RIGHT, FORWARD, BACKWARD, START, END

mutable struct Branch
    endpoint::Array{Int,1}  # dim: (2), indexed by START, END
    istwisted::Bool
end

Branch() = Branch([0, 0], false)

struct Switch
    outgoing_branch_indices::Array{Array{Int,1},1}  # dim: (2, max_num_branches)
    numoutgoing_branches::Array{Int,1}  # dim: (2), indexed by FORWARD, BACKWARD
end

Switch() = Switch([Int[], Int[]], Int[0, 0])



struct TrainTrack
    branches::Array{Branch,1}
    switches::Array{Switch,1}

    function TrainTrack(gluinglist::Array{Array{Int,1},1},
                        twisted_branches::Array{Int,1}=Int[])
        if length(gluinglist) % 2 == 1
            error("The length of the gluing list must be even.")
        end

        for ls in gluinglist
            if length(ls) == 0
                error("Each array should be non-empty")
            end
        end

        all_branches = sort(collect(Iterators.flatten(gluinglist)))
        if length(all_branches) % 2 != 0
            error("The total number of indices in the input should be even.")
        end

        halflen = div(length(all_branches), 2)
        for i in 1:halflen
            if all_branches[i] != -all_branches[2*halflen - i + 1]
                error("The negative of each index must also appear in the list.")
            end
        end
        for i in 2:halflen+1
            if all_branches[i] == all_branches[i-1]
                error("Every index should appear in the gluing list at most once.")
            end
        end

        branch_arr_size = maximum(maximum(abs(x) for x in y) for y in gluinglist)
        switch_arr_size = div(length(gluinglist), 2)

        branches = [Branch(Int[0, 0], i in twisted_branches) for i in 1:branch_arr_size]
        switches = [Switch([fill(0, branch_arr_size),
                            fill(0, branch_arr_size)],
                           Int[0, 0]) for i in 1:switch_arr_size]

        for i in 1:switch_arr_size
            for step in (FORWARD, BACKWARD)
                sgn = step == FORWARD ? 1 : -1
                ls = gluinglist[2*i - 2 + step]
                for br_idx in ls
                    # br_idx < 0 ?
                    # branches[-br_idx].endpoint[END] = sgn*i :
                    # branches[br_idx].endpoint[START] = sgn*i
                    _setend!(-br_idx, sgn*i, branches)
                end
                switches[i].numoutgoing_branches[step] = length(ls)
                switches[i].outgoing_branch_indices[step][1:length(ls)] = ls
            end
        end

        new(branches, switches)
    end
end

_setend!(br_idx::Int, sw_idx::Int, branch_array::Array{Branch}) = br_idx > 0 ?
    branch_array[br_idx].endpoint[END] = sw_idx :
    branch_array[-br_idx].endpoint[START] = sw_idx



branch_endpoint(tt::TrainTrack, branch::Int) = tt.branches[abs(branch)].endpoint[
    branch > 0 ? END : START]


numoutgoing_branches(tt::TrainTrack, switch::Int) =
    tt.switches[abs(switch)].numoutgoing_branches[switch > 0 ? FORWARD : BACKWARD]


function outgoing_branches(tt::TrainTrack, switch::Int, start_side::Int=LEFT)
    n = numoutgoing_branches(tt, switch)
    direction = switch > 0 ? FORWARD : BACKWARD
    arr_view = view(tt.switches[abs(switch)].outgoing_branch_indices[direction], 1:n)
    return start_side == LEFT ? arr_view : reverse(arr_view)
end

function outgoing_branch(tt::TrainTrack, switch::Int, index::Int, start_side::Int=LEFT)
    n = numoutgoing_branches(tt, switch)
    if index <= 0 || index > n
        error("Index $(index) is invalid at switch $(switch). The number of outgoing branches is $(n).")
    end
    branches = outgoing_branches(tt, switch, start_side)
    branches[index]
end

function outgoing_branch_index(tt::TrainTrack, switch::Int, branch::Int, start_side::Int=LEFT)
    branches = outgoing_branches(tt, switch, start_side)
    index = findfirst(isequal(branch), branches)
    if index == nothing
        error("Branch $(branch) is not outgoing from switch $(switch).")
    end
    index
end

istwisted(tt::TrainTrack, branch::Int) = tt.branches[abs(branch)].istwisted







function isswitch(tt::TrainTrack, switch::Int)
    if abs(switch) == 0 || abs(switch) > length(tt.switches)
        return false
    end
    tt.switches[abs(switch)].numoutgoing_branches[1] > 0
end


function isbranch(tt::TrainTrack, branch::Int)
    if abs(branch) == 0 || abs(branch) > length(tt.branches)
        return false
    end
    tt.branches[abs(branch)].endpoint[START] != 0
end




# TODO: This could return an interator instead.
switches(tt::TrainTrack) = [i for i in 1:length(tt.switches) if isswitch(tt, i)]

# TODO: This could return an interator instead.
branches(tt::TrainTrack) = [i for i in 1:length(tt.branches) if isbranch(tt, i)]

switchvalence(tt::TrainTrack, switch::Int) = numoutgoing_branches(tt, switch) + numoutgoing_branches(tt, -switch)







# TODO: possibly
# num_branches(tt)
# num_switches(tt)
# copy(tt)
# change_switch_orientation(tt, switch)
# swap_branch_numbers(tt, br1, br2)
