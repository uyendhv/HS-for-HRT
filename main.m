function main
clc
clear vars
clear all
close all
%
num_instances = 0;
num_perfects = 0;
total_time = 0;
%run algorithms
alg = 1;
%number of instances has the same (n,m,p1,p2)
folder = '..\datasets\hs-vs-hp-test5-5000-50-100-150-iter-25000';
%
k = 100;
for n = 5000
    for m = 50:100:150
        for p1 = 0.95 %0.7:0.1:0.9
            for p2= 0.0:0.1:1.0
                f_results= [];
                i = 1;
                while (i <= k)
                    %load the preference matrices and the matching from file
                    filename = [folder,'\I(',num2str(n),',',num2str(m),',',num2str(p1,'%.2f'),',',num2str(p2,'%.1f'),')-',num2str(i),'.mat'];
                    load(filename,'res_rank_list','hos_rank_list','hos_caps_list','M');
                    %run algorithms
                    if (alg == 1)
                        [f_time,f_cost,f_stable,f_iter,f_reset] = HS_HRT(res_rank_list,hos_rank_list,hos_caps_list, M);
                    end
                    if (alg == 2)
                        [f_time,f_cost,f_stable,f_iter,f_reset] = HP_HRT(res_rank_list,hos_rank_list,hos_caps_list);
                    end
                    if (alg == 3)
                        [f_time,f_cost,f_stable,f_iter,f_reset] = AS_HRT(res_rank_list,hos_rank_list,hos_caps_list,M);
                    end
                    if (alg == 4)
                        [f_time,f_cost,f_stable,f_iter,f_reset] = HSM(res_rank_list,hos_rank_list,hos_caps_list,M);
                    end
                    if (f_cost == 0) && (f_stable == 1)
                        num_perfects = num_perfects + 1;
                    end
                    %
                    f_results = [f_results; f_time,f_cost,f_stable,f_iter,f_reset];
                    %
                    fprintf('\nI(%d,%d,%0.2f,%0.1f)-%d: time = %3.5f, f(M)=%d, stable=%d, iters=%d, reset=%d',n,m,p1,p2,i,f_time,f_cost,f_stable,f_iter,f_reset);
                    %
                    i = i + 1;
                    total_time = total_time + f_time;
                    num_instances = num_instances + 1;
                end
                %save to file for averaging results
                if (alg == 1)
                    filename2 = [folder,'\HS-HRT(',num2str(n),',',num2str(m),',',num2str(p1,'%.2f'),',',num2str(p2,'%.1f'),').mat'];
                    %save(filename2,'f_results');
                end
                if (alg == 2)
                    filename2 = [folder,'\HP-HRT(',num2str(n),',',num2str(m),',',num2str(p1,'%.2f'),',',num2str(p2,'%.1f'),').mat'];
                    %save(filename2,'f_results');
                end
                if (alg == 3)
                    filename2 = [folder,'\AS-HRT(',num2str(n),',',num2str(m),',',num2str(p1,'%.2f'),',',num2str(p2,'%.1f'),').mat'];
                    %save(filename2,'f_results');
                end
            end
        end
    end
end
fprintf('\n\nnumber of instances = %d, number of perfects = %d, total time = %f\n',num_instances,num_perfects,total_time);
end
%==========================================================================