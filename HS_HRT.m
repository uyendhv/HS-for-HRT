function [f_time,f_cost,f_stable,f_iter,f_reset]= HS_HRT(res_rank_list,hos_rank_list,hos_caps_list,M)
%==========================================================================
%
n = size(res_rank_list,1);
m = size(hos_rank_list,1);
f = n;
repair_res = zeros(1,n);
repair_hos = zeros(1,m);
%
%copy the original residents' rank lists
res_rank_copy = res_rank_list;
%initialize the best matching
M_best = M;
f_best = f;
f_stable = 0;
f_reset = 0;
act = ones(1,n);
wait = zeros(n,m);
%n = 200,  MAX_ITERS = 2000
%n = 1000, MAX_ITERS = 10000
%n = 5000, MAX_ITERS = 25000
MAX_ITERS = 25000; 
iter = 0;
tic
%copy act list
l = act;
ri = 0;
%
while (iter <= MAX_ITERS)
    iter = iter + 1;
    %find the next active resident of ri
    ri =  ri + find(l((ri+1):size(act,2)) == 1,1,'first');
    %stable matching
    if isempty(ri)
        if sum(act == 0) == n
            f_stable = 1;
            f = find_cost_of_matching(M);
            if (f_best > f)
                M_best = M;
                f_best = f;
                %if a perfect matching is found
                if (f_best == 0)
                    break;
                end
            end
            %improve matching
            f_reset = f_reset + 1;
            M_old = M;
            %
            [M,repair_res,repair_hos,act,res_rank_list] = improve_matching(res_rank_list,hos_rank_list,hos_caps_list,M,repair_res,repair_hos,wait,act,res_rank_copy);
            %unchange
            if M == M_old
                break;
            end
            continue;
        else
            %new loop
            ri = 0;
            l = act;
            continue;
        end
    end
    %for each active resident
    [hk,wait,res_rank_list] = find_undominated_residents(res_rank_list,hos_rank_list,hos_caps_list,ri,M,wait);
    if (hk ~= 0)
        hj = M(ri);
        M(ri) = hk;
        act(ri) = 0;
        if (hj ~= 0)
            %find res wait hj and reactive
            rl = find(wait(:,hj));
            if ~isempty(rl)
                res_rank_list(rl,hj) = res_rank_copy(rl,hj);
                act(rl) = 1;
            end
        end
        if (sum(M == hk) > hos_caps_list(hk))
            rw = find_worst_resident(hos_rank_list,hk,M);
            %rw become unassign and reactive rw
            M(rw) = 0;
            act(rw) = 1;
        end
    else
        %ri become inactive
        act(ri) = 0;
    end
end
%M_best
f_time = toc;
f_cost = f_best;
f_iter = iter;
%
%verify the result matching
%verify_result_matching(res_rank_copy,hos_rank_list,hos_caps_list,M_best);
end
%==========================================================================
function [hk,wait,res_rank_list] = find_undominated_residents(res_rank_list,hos_rank_list,hos_caps_list,ri,M,wait)
%hk is a hospital making an undominated blocking pair with ri
%
m = size(hos_rank_list,1);
%find |M(ht)| for all ht in H
s = histc(M,1:m);  
%y(ht) = rank(ri,ht) + s(ht)/(ct + 1)
y = res_rank_list(ri,:) + s./(hos_caps_list' +1);
%
hk = 0;
while (sum(res_rank_list(ri,:) == 0) < m)
    %finding only acceptance pairs, (y >= 1), (ri,hl) with minimum rank
    rank_hl = min(y(find(y >= 1)));
    hl = find(y == rank_hl,1,'first');
    %rank(ri,hl) = rank(ri,M(ri))
    if (M(ri) > 0) && (res_rank_list(ri,hl) == res_rank_list(ri,M(ri)))
        break;
    end
    %check blocking pair
    if (check_blocking_pair(res_rank_list,hos_rank_list,hos_caps_list,ri,hl,M) == true)
        hk = hl;
        break;
    else
        %ri prefers hl to hi but (ri,hl) isn't blocking pair, ri wait hl
        wait(ri,hl) = 1;
        res_rank_list(ri,hl) = 0;
        y(hl) = 0;
    end
end
end
%==========================================================================
%find the cost of a matching M
%==========================================================================
function [f] = find_cost_of_matching(M)
%f: the number of singles in M
f = size(find(M == 0),2);
end
%==========================================================================