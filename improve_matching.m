function [M,repair_res,repair_hos,act,res_rank_list] = improve_matching(res_rank_list,hos_rank_list,hos_caps_list,M,repair_res,repair_hos,wait,act,res_rank_copy)
n = size(res_rank_list,1);
m = size(hos_rank_list,1);
%
unassigned = find(M == 0);
for u = 1:size(unassigned,2)
    ru = unassigned(u);
    %find (ri,hk) in M, such that rank(hk,ri) = rank(hk,ru)
    for hk = 1:m
        %find residents ri assigned to hk in M
        res = find(M == hk);
        for i = 1:size(res,2)
            ri = res(i);
            %check if ri has same ties with ru in hk rank list and repair_res(ru) >= repair_res(ri)
            if hos_rank_list(hk,ri) == hos_rank_list(hk,ru) && repair_res(ru) >= repair_res(ri)
                %M = M \ {(ri,hk)} U {(ru,hk)}
                M(ru) = hk;
                M(ri) = 0;
                %ru is repaired one more times
                repair_res(ru) = repair_res(ru) + 1;
                %recover hk in ru's rank list
                res_rank_list(ru,hk) = res_rank_copy(ru,hk);
                %set ru to become inactive and ri to become active 
                act(ru) = 0;
                act(ri) = 1;
                break;
            end
        end
        if M(ru) ~= 0
            break;
        end
    end
end
%
under_subscribed = [];
for ht = 1:m
    if sum(M == ht) < hos_caps_list(ht)
        under_subscribed = [under_subscribed, ht];
    end
end 
for t = 1:size(under_subscribed,2)
    ht = under_subscribed(t);
    for ri = 1:n
        hk = M(ri);
        if (ht ~= hk) && (hk ~= 0)
            %ht has same ties with hk in ri rank list and repair_hos(ht) >= repair_hos(hk)
            if res_rank_copy(ri,hk) == res_rank_copy(ri,ht) && repair_hos(ht) >= repair_hos(hk)
                M(ri) = ht;
                repair_hos(ht) = repair_hos(ht) + 1;
                %recover ht in ri's rank list
                res_rank_list(ri,ht) = res_rank_copy(ri,ht);
                %find rw who is waiting in hk
                rw = find(wait(:,hk));
                if ~isempty(rw)
                    res_rank_list(rw,hk) = res_rank_copy(rw,hk);
                    act(rw) = 1;
                end
                break;
            end
        end
    end
end
end
