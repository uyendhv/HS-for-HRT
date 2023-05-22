function [M] = make_random_matching(res_rank_list,hos_rank_list,hos_caps_list)
%create a random matching M in which r and h find each other acceptable
n = size(res_rank_list,1);
while (true)
    %initialize M, where idx is residents and M(idx) is hospitals
    M = zeros(1,n);
    %make random residents
    X = rand(1,n);
    [~,residents] = sort(X);
    %assign hospitals to residents
    for i = 1:size(residents,2)
        ri = residents(i);
        ri_hospitals = find(res_rank_list(ri,:) > 0);
        if(isempty(ri_hospitals))
            continue;
        end
        %find a random hospital hj ranked by resident ri
        idx = randi(size(ri_hospitals,2),1,1);
        hj = ri_hospitals(idx);
        cj = hos_caps_list(hj);
        %check project capacity
        if (sum(M == hj) < cj) && (hos_rank_list(hj,ri) > 0)
            M(ri) = hj;      
        end
    end
    %check if M = zeros
    if (any(M))
       break;
    end
end
end
%==========================================================================