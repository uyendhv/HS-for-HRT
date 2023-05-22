function [f] = check_blocking_pair(res_rank_list,hos_rank_list,hos_caps_list,ri,hj,M)
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
hi = M(ri);
if (hi ~= 0)
    rank_ri_hi = res_rank_list(ri,hi);
end
f2 = (hi == 0)||(rank_ri_hj < rank_ri_hi);
%
%(3) hj either is undersubscribed or strictly prefers ri to the worst resident assigned to it in M.
cj = hos_caps_list(hj);
if (sum(M == hj) >= cj)
    rj = find_worst_resident(hos_rank_list,hj,M);
    rank_hj_rj = hos_rank_list(hj,rj);
end
f3 = (sum(M == hj) < cj) || (rank_hj_ri < rank_hj_rj);
%
%return the blocking pair definition 
f = f1 && f2 && f3;
end