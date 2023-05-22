function [f] = verify_result_matching(res_rank_list,hos_rank_list,hos_caps_list,M)
%find all blocking pair in M
f = 1;
X = [];
for ri = 1:size(M,2)
    hi = M(ri);
    for rj = 1:size(M,2)
        hj = M(rj);
        if (hj == 0)
            continue;
        end
        if (check_blocking_pair(res_rank_list,hos_rank_list,hos_caps_list,ri,hj,M) == true)
            %add mr_wj,wr_mi to the last columns of blocking_pairs
            X(end+1,:) = [ri,hi,rj,hj];
        end
    end
end
if isempty(X)
    %fprintf("\n\nThe matching of the following instance is stable !!!!");
else
    f = 0;
    fprintf("\n\nThe matching of the following instance is NOT STABLE !!!!");
    X
end
%
%check for capacity
m = size(hos_rank_list,1);
for hi = 1:m
    if (sum(M == hi) > hos_caps_list(hi))
        fprintf("\n %d is over capacity!",hi);
    end
    if (sum(M == hi) == 0)
        fprintf("\n %d is not matched!",hi);
    end
end
%
%check acceptable pairs
for ri = 1:size(M,2)
    hi = M(ri);
    if (hi > 0)
        if (res_rank_list(ri,hi) == 0) || (hos_rank_list(hi,ri) == 0)
            fprintf("\nThere exist unaceptable pairs");
        end
    end
end
end
%====================================================================