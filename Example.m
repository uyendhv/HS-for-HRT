clc;
clear all;
close all;
res_rank_list = [1 0 2 0; 
                 1 0 0 1; 
                 1 2 0 0; 
                 0 1 1 1; 
                 1 1 2 0; 
                 0 2 3 1;
                 1 2 0 0;
                 1 1 0 0];
%
hos_rank_list = [3 2 1 0 2 0 3 3; 
                 0 3 1 5 3 3 4 2; 
                 1 0 0 1 2 1 0 0
                 0 1 0 3 0 2 0 0];
hos_caps_list = [2; 2; 2; 2];
M = [1 1 2 3 0 4 2 0];
[f_time,f_cost,f_stable,f_iter,f_reset]= HS_HRT(res_rank_list,hos_rank_list,hos_caps_list,M)