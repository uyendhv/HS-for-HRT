function [rj] = find_worst_resident(hos_rank_list,hj,M)
%find the worst resident, rj, assigned to hj in M
%
residents = find(M == hj);
rank_hj_rj = zeros(1,size(residents,2));
for j = 1:size(residents,2)
    rj = residents(j);
    rank_hj_rj(j) = hos_rank_list(hj,rj);
end
[~,idx] = max(rank_hj_rj);
rj = residents(idx);
end
%==========================================================================