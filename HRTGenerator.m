%======================================================================================
%Adopt from: Ian Philip Gent, Patrick Prosser. An Empirical Study of the Stable Marriage Problem with
%Ties and Incomplete Lists
%======================================================================================
function HRTGenerator()
clc
clear vars
clear all
close all
%number of instances has the same (n,m,p1,p2)
folder = '..\datasets\hs-vs-hp-test5-5000-50-100-150-iter-25000';
%
k = 100;
for n = 5000
    for m = 50:100:150
        for p1 = 0.95
            for p2 = 0.0:0.1:1.0
                i = 1;
                while (i <= k)
                    R = rand(n,m);
                    H = rand(m,n);
                    %generate residents' and hospitals' preference lists
                    [~,res_pref_list] = sort(R,2);
                    [~,hos_pref_list] = sort(H,2);
                    %generate an HRT instance
                    [res_rank_list,hos_rank_list,hos_caps_list] = make_rank_lists(res_pref_list,hos_pref_list,p1,p2);
                    %
                    if (~isempty(res_rank_list)) 
                        %create a random matching
                        M = make_random_matching(res_rank_list,hos_rank_list,hos_caps_list);
                        %save preference matrices and the matching to file
                        filename = [folder,'\I(',num2str(n),',',num2str(m),',',num2str(p1,'%.2f'),',',num2str(p2,'%.1f'),')-',num2str(i),'.mat'];
                        %save(filename,'res_rank_list','hos_rank_list','hos_caps_list','M');
                        %res_pref_list
                        %hos_rank_list
                        %
                        %res_pref_list
                        %hos_rank_list
                        i = i + 1;
                    end
                end
            end
        end
    end
end
end
%============================================================================================
function [res_rank_list,hos_rank_list,hos_caps_list] = make_rank_lists(res_pref_list,hos_pref_list,p1,p2)
%size of HRT instance
n = size(res_pref_list,1);
m = size(hos_pref_list,1);
%
%1. generate an instance of HRP with incomplete lists
%
%generate randomly using a probability 
for i = 1:n
    %check any resident has not an empty preference list
    while (true)
        y = (rand(1,m) <=p1);
        if ~all(y)
            break;
        end
    end
    %
    for r1 = 1:m
        if (y(r1) == 1)
            %delete hospital j from resident i's list
            j = res_pref_list(i,r1);
            res_pref_list(i,r1) = 0;
            %delete resident i from hospital j's list
            r2 = find(hos_pref_list(j,:) == i,1,'first');
           hos_pref_list(j,r2) = 0;
        end
    end
end
%
%2. generate an instance of HRP with Ties, i.e. HRT
%
res_rank_list = zeros(n,m);
hos_rank_list = zeros(m,n);
hos_caps_list = zeros(m,1);
%check if any resident has an empty preference list, discard the instance
for i = 1:n
    if ~any(res_pref_list(i,:))
        res_rank_list = [];
        return;
    end
end
%check if any hospital has an empty preference list, discard the instance
for i = 1:m
    if ~any(hos_pref_list(i,:))
        res_rank_list = [];
        return;
    end
end
%
%create ties in residents' rank list
for i = 1:n
    %
    idx = find(res_pref_list(i,:) ~=0,1,'first');
    res_rank_list(i,res_pref_list(i,idx)) = 1;
    cj = 1;
    for j = idx+1:m
        if (res_pref_list(i,j) > 0)
            if (rand() >= p2)
                cj = cj + 1;
            end
            res_rank_list(i,res_pref_list(i,j)) = cj;
        end
    end
end
%
%create ties in hospitals' rank list
for i = 1:m
    %
    idx = find(hos_pref_list(i,:) ~=0,1,'first');
    hos_rank_list(i,hos_pref_list(i,idx)) = 1;
    cj = 1;
    for j = idx+1:n
        if (hos_pref_list(i,j) > 0)
            if (rand() >= p2)
                cj = cj + 1;
            end
            hos_rank_list(i,hos_pref_list(i,j)) = cj;
        end
    end
end
%
%3. generate capacity for hospitals
%hos_caps_list = randi([2,25],m,1);
for i = 1:m
    %for average capacity
    q = ceil(n/m);
    hos_caps_list(i) = q;
    %for random capacity
    %res_idxs = find(hos_rank_list(i,:) > 0);
    %q1 = 30;
    %q2 = 55;
    %hos_caps_list(i) = randi([q1,q2],1,1);
end    
end
%==========================================================================