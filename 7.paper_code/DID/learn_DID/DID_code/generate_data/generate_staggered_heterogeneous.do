*使用的基础数据结构为300个体×15时期=4500个观察值的平衡面板数据

clear all
timer clear

*设定随机数种子,设置4500个样本观测值
set seed 10
global T=15
global I=300
set obs `=$I*$T'

*生成id与时间
gen id = int((_n-1)/$T)+1
gen t = mod((_n-1),$T)+1
xtset id t

*随机生成每个id 首次接受处理的时间标志, treat_time的取值在10和16之间
gen treat_time = ceil(runiform()*7)+$T -6 if t==1
bys i(t):replace treat_time = treat_time[1]

*生成处理变量,relative_time 为相对处理时间, D为处理时间哑变量
gen relative_time = t-treat_time
gen D = relative_time>=0 & treat_time!=.

*生成时间上的异质性处理效应
gen tau = cond(D==1,(t-12.5),0)

*生成误差项
gen eps = rnormal()

*生成结果变量Y
gen Y = id + 3*t + tau*D +eps

save staggered_heterogeneous.dta, replace