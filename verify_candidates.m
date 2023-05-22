clc
clear all
close all
n = 200;
m = 20;
k = 1; 
folder = '..\datasets\hs-vs-as-hp-test1-200-20';
for p1 = 0.6:0.1:0.8
    for p2= 0.0:0.1:1.0
        f_results= [];
        i = 1;
        v1 = [];
        v2 = [];
        while (i <= k)
            %load the preference matrices and the matching from file
            filename = [folder,'\I(',num2str(n),',',num2str(m),',',num2str(p1,'%.1f'),',',num2str(p2,'%.1f'),')-',num2str(i),'.mat'];
            load(filename,'res_rank_list','hos_rank_list','hos_caps_list','M');
            %
            s1 = 0;
            for t1 = 1:n
                x = find(res_rank_list(t1,:) > 0);
                s1 = s1 + size(x,2);
            end
            s2 = 0;
            for t2 = 1:m
                y = find(hos_rank_list(t2,:) > 0);
                s2 = s2 + size(y,2);
            end
            n*m*(1-p1)
            v1 = [v1,s1];
            v2 = [v2,s2];
            i = i + 1;
        end
        v1
        v2
    end
end
