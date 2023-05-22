function [f_time,f_cost,f_stable,f_iter,f_reset] = HP_HRT(res_rank_list,hos_rank_list,hos_caps_list)
%
n_res = size(res_rank_list,1);
n_hos = size(hos_rank_list,1);
hos_rank_list_c = hos_rank_list;
res_rank_list_c = res_rank_list;
hos_caps_list_c = hos_caps_list;
%
M = zeros(1,n_res);
pair = zeros(n_res,n_hos);
%
f_reset = 0;
f_stable = 0;
iter = 0;
act_hos = ones(1,n_hos);
%
adv_hos = zeros(1,n_hos);
tic
while(sum(act_hos==0) ~= n_hos)
    iter = iter + 1;
    %find hospital is active
    hos = find(act_hos);
    if isempty(hos)
        break;
    end
    %
    if isempty(find(hos_rank_list(hos,:)))
        if isempty(find(adv_hos(hos)==0))
            break;
        end
    end
    for r = 1:size(hos,2)
        hi = hos(r);
        %find res are assgin with hi
        x = hos_rank_list(hi,:);
        hp = find(pair(:,hi));
        if ~isempty(hp)
            x(hp') = 0;
        end
        %find min rank in hos rank list
        rank = min(x(find(x)));
        if isempty(rank)
            if (adv_hos(hi) == 0)
                hos_rank_list(hi,:) = hos_rank_list_c(hi,:);
                adv_hos(hi) = 1;
            else
                %empty second time
                act_hos(hi) = 0; 
            end
            continue;
        end
        %find residents have min rank
        res = find(x == rank);
        ri = res(1);
        %find res unoffer
        if M(ri) ~= 0
            for i = 2:size(res,2)
                if M(res(i)) == 0
                    ri = res(i);
                    break;
                end
            end
        end
        assign = 0;
        if (M(ri) == 0)
            M(ri) = hi;
            assign = 1;
            pair(ri,hi) = 1;
        else
            %if res is currently engaged to hj
            hj = M(ri);
            %
            rank_hj_ri = hos_rank_list(hj,ri);
            rk = find(hos_rank_list(hj,:) == rank_hj_ri);
            %check hj is uncertain about the offer for ri
            unc = 0;
            if hos_caps_list(hj) == sum(M==hj) && adv_hos(hj) == 0
                for i = 1:size(rk,2)
                    if M(rk(i)) == 0
                        unc = 1;
                        break;
                    end
                end
            end
            if unc ~= 0
                M(ri) = hi;
                assign = 1;
                act_hos(hj) = 1;
                pair(ri,hi) = 1;
                pair(ri,hj) = 0;
            else
                hj_rank = res_rank_list(ri,hj);
                hi_rank = res_rank_list(ri,hi);
                %compare the ranks of hi and hj
                if (hi_rank < hj_rank) || (hi_rank == hj_rank && adv_hos(hi) > adv_hos(hj))
                    M(ri) = hi;
                    assign = 1;
                    hos_rank_list(hj,ri) = 0;
                    act_hos(hj) = 1;
                    pair(ri,hi) = 1;
                    pair(ri,hj) = 0;
                else
                    %res rejects hi
                    hos_rank_list(hi,ri) = 0;
                end
            end
        end
        if assign == 1
            %check full cap
            if sum(M==hi) == hos_caps_list(hi)
                act_hos(hi) = 0;
            end
        end
    end
end
M;
f_time = toc;
f_iter = iter;
[f_cost,nbp] = find_cost_and_blocking_pairs(res_rank_list_c,hos_rank_list_c,hos_caps_list_c,M);
if nbp == 0
    f_stable = 1;
end
% verify_result_matching(res_rank_list_c,hos_rank_list_c,hos_caps_list,M)
end
%==========================================================================
function [f,nbp] = find_cost_and_blocking_pairs(res_rank_list,hos_rank_list,hos_caps_list,M)
%f: the cost function of M
%X: a set of blocking pairs in M
%nbp: the numer of blocking pairs in M
%nsg: the number of singles which are not in blocking pairs
%
n = size(res_rank_list,1);
m = size(hos_rank_list,1);
%
%initalize variables
X = [];
nbp = 0;
nsg = 0;
%
for ri = 1:size(M,2)
    hi = M(ri);
    check_bp = false;
    %
    if (hi > 0)
        rank_ri_hi = res_rank_list(ri,hi);
    else
        rank_ri_hi = n+1;
    end
    %find blocking pairs (ri,hj)
    x = res_rank_list(ri,:);
    [ri_rank_list,idxs] = sort(x);
    for j = 1:m
        rank_ri_hj = ri_rank_list(j);
        if (rank_ri_hj > 0) && (rank_ri_hj < rank_ri_hi)
            hj = idxs(j);
            cj = hos_caps_list(hj);
            rj = find_worst_resident(hos_rank_list,hj,cj,M);
            if (check_blocking_pair(res_rank_list,hos_rank_list,ri,hi,hj,cj,M) == true)
                %add (ri,hi) and (rj,hj) to X
                rank_hj_ri = hos_rank_list(hj,ri);
                X(end+1,:) = [ri,hi,rj,hj,rank_hj_ri];
                %increase the number of blocking pairs
                nbp = nbp + 1;
                %find an undominated blocking pair
                check_bp = true;
                break;
            end
        end
    end
    %increase the number of singles which are not in blocking pairs
    if ((check_bp == false) && (hi == 0))
        nsg = nsg + 1;
    end
end
nbp;
%cost of matching M
f = nbp + nsg;
end
%==========================================================================
function [f] = check_blocking_pair(res_rank_list,hos_rank_list,ri,hi,hj,cj,M)
% A pair (ri,hj) is a blocking pair in M iif
%(1) ri and hj find acceptable each other, and
%(2) ri either is unassigned or strictly prefers hj to his assigned hospital in M
%(3) hj either is undersubscribed or strictly prefers ri to the worst resident assigned to it in M.
%cj - capacity of hj
%
%(1) ri and hj find acceptable each other
rank_ri_hj = res_rank_list(ri,hj);
rank_hj_ri = hos_rank_list(hj,ri);
f1 = (rank_ri_hj > 0)&&(rank_hj_ri > 0);
%
%(2) ri either is unassigned or strictly prefers hj to his assigned hospital in M
if (hi ~= 0)
    rank_ri_hi = res_rank_list(ri,hi);
end
f2 = (hi == 0)||(rank_ri_hj < rank_ri_hi);
%
%(3) hj either is undersubscribed or strictly prefers ri to the worst resident assigned to it in M.
if (sum(M == hj) >= cj)
    rj = find_worst_resident(hos_rank_list,hj,cj,M);
    rank_hj_rj = hos_rank_list(hj,rj);
end
f3 = (sum(M == hj) < cj) || (rank_hj_ri < rank_hj_rj);
%
%return the blocking pair definition
f = f1 && f2 && f3;
end
%==========================================================================
function [rw] = find_worst_resident(hos_rank_list,hj,cj,M)
%find the worst resident, rw, assigned to hj in M
%cj - capacity of hj
%
if (sum(M == hj) >= cj)
    idxs = find(M == hj);
    rank_hj_ri = zeros(1,size(idxs,2));
    for i = 1:size(idxs,2)
        ri = idxs(i);
        rank_hj_ri(i) = hos_rank_list(hj,ri);
    end
    [~,idx] = max(rank_hj_ri);
    rw = idxs(idx);
else
    rw = 0;
end
end
