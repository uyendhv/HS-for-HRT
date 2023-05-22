function [f_time,f_cost,f_stable,f_iter,f_reset]= AS_HRT(res_rank_list,hos_rank_list,hos_caps_list,M)
%==========================================================================
n = size(res_rank_list,1);
f = n;
%
%initialize the best matching
M_best = M;
f_best = f;
f_stable = 0;
f_reset = 0;
%
MAX_ITERS = 5000;
iter = 0;
p = 0.98;
tic
while (iter <= MAX_ITERS)
    iter = iter + 1;
    [f,~,~,X] = find_undominated_residents(res_rank_list,hos_rank_list,hos_caps_list,M);
    %
    if isempty(X)
        f_stable = 1;
        if (f_best > f)
            M_best = M;
            f_best = f;
        end
        %if a perfect matching is found
        if (f_best == 0)
            break;
        else
            %perform a random restart
            f_reset = f_reset + 1;
            [M] = reset(res_rank_list,hos_rank_list,hos_caps_list,M,p);
            continue;
        end
    end
    [~,idx] = max(X(:,5));
    ri = X(idx,1);
    hj = X(idx,4);
    %remove undominated blocking pair (ri,hj) in M
    M(ri) = hj;
    if (sum(M == hj) > hos_caps_list(hj))
        rj = find_worst_resident(hos_rank_list,hj,M);
        %rj become single
        M(rj) = 0;
    end
    f_last = f;
    [f,~] = find_undominated_residents(res_rank_list,hos_rank_list,hos_caps_list,M);
    if (f >= f_last)
        %invoke a reset procedure to alter the current configuration
        f_reset = f_reset + 1;
        [M] = reset(res_rank_list,hos_rank_list,hos_caps_list,M,p);
    end
    
end
M_best;
f_time = toc;
f_cost = f_best;
f_iter = iter;
%
%verify the result matching
% verify_result_matching(res_rank_list,hos_rank_list,hos_caps_list,M_best);
end
%==========================================================================
%find undominated blocking pairs (ri,hj) from resident's point of view
%==========================================================================
function [f,nbp,nsg,X] = find_undominated_residents(res_rank_list,hos_rank_list,hos_caps_list,M)
%X: a set of undominated blocking pairs
%
n = size(res_rank_list,1);
m = size(hos_rank_list,1);
nbp = 0;
nsg = 0;
X = [];
for ri = 1:n
    %
    hi = M(ri);
    if (hi > 0)
        rank_ri_hi = res_rank_list(ri,hi);
    else
        rank_ri_hi = n+1;
    end
    check_bp = false;
    %find an undominated blocking pair (ri,hj)
    x = res_rank_list(ri,:);
    [ri_rank_list,hospitals] = sort(x);
    for j = 1:m
        rank_ri_hj = ri_rank_list(j);
        if (rank_ri_hj > 0) && (rank_ri_hj < rank_ri_hi)
            hj = hospitals(j);
            if (check_blocking_pair(res_rank_list,hos_rank_list,hos_caps_list,ri,hj,M) == true)
                nbp = nbp + 1;
                [rj,er] = error(hos_rank_list,ri,hj,hos_caps_list,M);
                X(end+1,:) = [ri,hi,rj,hj,er];
                check_bp = true;
                break;
            end
        end
    end
    %count the number of singles which are not in blocking pairs
    if (check_bp == false) && (hi == 0)
        nsg = nsg + 1;
    end
end
f = nbp*n + nsg;
end
%==========================================================================
function [rj,f] = error(hos_rank_list,ri,hj,hos_caps_list,M)
rj = 0;
slot = sum(M == hj);
if (slot < hos_caps_list(hj))
    f = 1;
    return
end
rj = find_worst_resident(hos_rank_list,hj,M);
rank_ri_hj = hos_rank_list(hj,ri);
rank_rj_hj = hos_rank_list(hj,rj);
f = rank_rj_hj - rank_ri_hj;
end
%==========================================================================
%==========================================================================
function [M] = reset(res_rank_list,hos_rank_list,hos_caps_list,M,p)
[~,nbp,nsg,blocking_pairs] = find_undominated_residents(res_rank_list,hos_rank_list,hos_caps_list,M);
%
%check for the number of blocking pairs
if (nbp >= 1)
    %
    %find the first worst variable
    [~,idx1] = max(blocking_pairs(:,5));
    %
    ri = blocking_pairs(idx1,1);
    hj = blocking_pairs(idx1,4);
    %
    %find the second worst variable
    blocking_pairs(idx1,5) = 0;
    [~,idx2] = max(blocking_pairs(:,5));
    %
    %swap Xm and Xm', i.e. swap (ri,hi) and (rj,hj)    
    %
    M(ri) = hj;
    if (sum(M == hj) > hos_caps_list(hj))
        rj = find_worst_resident(hos_rank_list,hj,M);
        %rj become single
        M(rj) = 0;
    end
    %
    %fix the second worst variable with a probability p
    if (nbp >=2) && (rand() <=p)
        %
        ri = blocking_pairs(idx2,1);
        hj = blocking_pairs(idx2,4);
        %
        %swap Xm and Xm', i.e. swap (ri,hi) and (rj,hj)    
        %
        %M is change when #BP >=1, but blocking_pairs are not changed
        %so we have to find the position of pair (ri,hi) in M
        M(ri) = hj;
        if (sum(M == hj) > hos_caps_list(hj))
            rj = find_worst_resident(hos_rank_list,hj,M);
            %rj become single
            M(rj) = 0;
        end
        return;
    end
end
%
%check for the number of singles
if (nsg >= 1)
    %find the positions of the single residents
    idxr = find(M == 0);
    %select randomly a single res, ri
    r = randi(size(idxr,2),1,1);
    ri = idxr(r);
    %
    %
    idxh = find(res_rank_list(ri,:) ~=0);
    %select randomly a single hospital, hi
    r = randi(size(idxh,2),1,1);
    hj = idxh(r);
    %check acceptable
    rj = find_worst_resident(hos_rank_list,hj,M);
    M(rj) = 0;
    M(ri) = hj;
else
    %there are no a single res and a single hospital
    %
    %find the positions of all of  pairs in M
    %select randomly a pair (ri,hi) in M
    ri = randi(size(M,2),1,1);
    %
    %select randomly a pair (rj,hj) in M
    rj = randi(size(M,2),1,1);
    hj = M(rj);
    if (hj ~= 0)
    %swap ri's partner and rj's a partner
    if (res_rank_list(ri,hj) >0)
        %assign hj to be a partner of ri
        M(ri) = hj;
        %
        %rj become single
        M(rj) = 0;
    end
    end
end
end
