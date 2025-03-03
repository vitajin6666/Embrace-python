**********************************************************************************************************************************
*** Date:    December 2009
*** Authors: Beck, Levine, and Levkov
*** Purpose: Create Figure 1 in "Big Bad Banks? The Winners and Losers from Bank Deregulation in the United States"
*** Note:    Please change the working directories below 
**********************************************************************************************************************************



clear
set more off
set memory 100m

cd "D:\python\learn_python\7.paper_code\DID\BBB\replication_thesis"

log using Figure1.log, replace

**************
*** LEVELS ***
**************

use "D:\python\learn_python\7.paper_code\DID\BBB\replication_thesis\data\macro_workfile.dta" , clear

generate log_gini = log(gini)

**************
* 当我们在回归中控制某些变量时，残差代表了排除这些变量影响后的部分。
* 作者用年份虚拟变量（i.wrkyr）对log_gini进行了回归，得到残差r。
* 这个步骤实际上是在去除log_gini中的时间趋势或年份效应，使得残差r表示的是排除了年份影响后的基尼系数 
**************

* 抽离出所有州共同经历的全国性时间趋势（如经济周期、联邦政策变化等）对log_gini的影响
xi: regress log_gini i.wrkyr // 回归中自动为wrkyr生成虚拟变量

* 残差r的含义：表示各州基尼系数中无法被年份解释的部分（即各州自身独特的基尼系数波动）
predict r, residual // r是我对残差的命名

**************
* 检验政策实施时间是否与各州政策前的基尼系数水平相关。若回归系数不显著，说明政策时间外生
**************

keep if wrkyr<branch_reform

bysort statefip: egen mean_gini = mean(r) // 按照 statefip（州）分组，并计算每个州的残差平均值，结果保存在 mean_gini 中
keep statefip state mean_gini branch_reform
duplicates drop

regress branch_reform mean_gini, robust

**************
* 绘图
**************
twoway (scatter branch_reform mean_gini, msymbol(circle_hollow) mcolor(navy) mlabel(state) mlabcolor(navy)), subtitle("(A)", size(small)) ///
       ytitle("Year of bank deregulation") ytitle(, size(small)) ylabel(, labsize(small) angle(horizontal) nogrid)  ///
       xtitle(Average Gini coefficient prior to bank deregulation) xtitle(, size(small) margin(medsmall)) xlabel(, labsize(small)) ///
       legend(off) graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) 
	   
graph save Figure1A, asis replace

       
***************       
*** CHANGES ***
***************
use "D:\python\learn_python\7.paper_code\DID\BBB\replication_thesis\data\macro_workfile.dta" , clear

generate log_gini = log(gini)

sort statefip wrkyr
bysort statefip: generate log_gini_lag = log_gini[_n-1]  // 当前观察的前一行数据，即前一期数据
generate d = log_gini - log_gini_lag // 当期-前一期的对数差分近似于增长率


xi: regress d i.wrkyr
predict r, residual

keep if wrkyr<branch_reform

bysort statefip: egen growth = mean(r)
keep statefip state branch_reform growth
duplicates drop

regress branch_reform growth, robust

twoway (scatter branch_reform growth, msymbol(circle_hollow) mcolor(navy) mlabel(state) mlabcolor(navy)), subtitle("(B)", size(small)) ///
       ytitle("Year of bank deregulation") ytitle(, size(small)) ylabel(, labsize(small) angle(horizontal) nogrid)  ///
       xtitle(Average change in the Gini coefficient prior to bank deregulation) xtitle(, size(small) margin(medsmall)) xlabel(, labsize(small)) ///
       legend(off) graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white))
	   
graph save Figure1B, asis replace
       
log close



