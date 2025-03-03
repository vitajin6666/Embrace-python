**********************************************************************************************************************************
*** Date:    December 2009
*** Authors: Beck, Levine, and Levkov
*** Purpose: Create Figure 2 in "Big Bad Banks? The Winners and Losers from Bank Deregulation in the United States"
*** Note:    Please change the working directories below 
**********************************************************************************************************************************

clear
set mem 100m
set more off

cd "D:\python\learn_python\7.paper_code\DID\BBB\replication_thesis"

log using Figure2.log, replace

use "D:\python\learn_python\7.paper_code\DID\BBB\replication_thesis\data\macro_workfile.dta" , clear

* 百分位（percentile）是将收入分布分成 100 等份
* 第 5 百分位是最低 5% 的收入，第 95 百分位是最高 5% 的收入


* 计算收入分布中第 i 个百分位（ith percentile）的收入对数,测试的百分位包括 5、10、15、…、90、95（共 19 个点）
replace p5=log(p5)
replace p10=log(p10)
replace p15=log(p15)
replace p20=log(p20)
replace p25=log(p25)
replace p30=log(p30)
replace p35=log(p35)
replace p40=log(p40)
replace p45=log(p45)
replace p50=log(p50)
replace p55=log(p55)
replace p60=log(p60)
replace p65=log(p65)
replace p70=log(p70)
replace p75=log(p75)
replace p80=log(p80)
replace p85=log(p85)
replace p90=log(p90)
replace p95=log(p95)


* 对每个百分位（i 从 5 到 95）分别运行了 19 个回归, 每个回归独立分析一个百分位的收入如何受放松管制影响
xtset statefip wrkyr


xtreg p5 i._intra  i.wrkyr, fe vce(cluster statefip) 
gen   b5=_b[1._intra] // 将系数和标准差保存下来
gen   s5=_se[1._intra]

xtreg p10 i._intra  i.wrkyr, fe vce(cluster statefip)
gen   b10=_b[1._intra]
gen   s10=_se[1._intra]

xtreg p15 i._intra  i.wrkyr, fe vce(cluster statefip)
gen   b15=_b[1._intra]
gen   s15=_se[1._intra]

xtreg p20 i._intra  i.wrkyr, fe vce(cluster statefip)
gen   b20=_b[1._intra]
gen   s20=_se[1._intra]

xtreg p25 i._intra  i.wrkyr, fe vce(cluster statefip)
gen   b25=_b[1._intra]
gen   s25=_se[1._intra]

xtreg p30 i._intra  i.wrkyr, fe vce(cluster statefip)
gen   b30=_b[1._intra]
gen   s30=_se[1._intra]

xtreg p35 i._intra  i.wrkyr, fe vce(cluster statefip)
gen   b35=_b[1._intra]
gen   s35=_se[1._intra]

xtreg p40 i._intra  i.wrkyr, fe vce(cluster statefip)
gen   b40=_b[1._intra]
gen   s40=_se[1._intra]

xtreg p45 i._intra  i.wrkyr, fe vce(cluster statefip)
gen   b45=_b[1._intra]
gen   s45=_se[1._intra]

xtreg p50 i._intra  i.wrkyr, fe vce(cluster statefip)
gen   b50=_b[1._intra]
gen   s50=_se[1._intra]

xtreg p55 i._intra  i.wrkyr, fe vce(cluster statefip)
gen   b55=_b[1._intra]
gen   s55=_se[1._intra]

xtreg p60 i._intra  i.wrkyr, fe vce(cluster statefip)
gen   b60=_b[1._intra]
gen   s60=_se[1._intra]

xtreg p65 i._intra  i.wrkyr, fe vce(cluster statefip)
gen   b65=_b[1._intra]
gen   s65=_se[1._intra]

xtreg p70 i._intra  i.wrkyr, fe vce(cluster statefip)
gen   b70=_b[1._intra]
gen   s70=_se[1._intra]

xtreg p75 i._intra  i.wrkyr, fe vce(cluster statefip)
gen   b75=_b[1._intra]
gen   s75=_se[1._intra]

xtreg p80 i._intra  i.wrkyr, fe vce(cluster statefip)
gen   b80=_b[1._intra]
gen   s80=_se[1._intra]

xtreg p85 i._intra  i.wrkyr, fe vce(cluster statefip)
gen   b85=_b[1._intra]
gen   s85=_se[1._intra]

xtreg p90 i._intra  i.wrkyr, fe vce(cluster statefip)
gen   b90=_b[1._intra]
gen   s90=_se[1._intra]

xtreg p95 i._intra  i.wrkyr, fe vce(cluster statefip)
gen   b95=_b[1._intra]
gen   s95=_se[1._intra]


keep b* s*
drop bankpow branch_reform sell_insurance small_banks small_firms state state_name statefip // 把多余的b和s开头的变量去掉
duplicates drop // 提取出b* s*放一行
save temp, replace

use temp, clear
keep b5 b10 b15 b20 b25 b30 b35 b40 b45 b50 b55 b60 b65 b70 b75 b80 b85 b90 b95 
xpose, clear //转置
rename v1 b 
gen percentile=_n*5
sort percentile
save betas, replace

use temp, clear
keep  s5 s10 s15 s20 s25 s30 s35 s40 s45 s50 s55 s60 s65 s70 s75 s80 s85 s90 s95 
xpose, clear
rename v1 se
gen percentile=_n*5
sort percentile

merge percentile using betas
drop _merge*


twoway (bar b percentile if percentile<=35, sort fcolor(navy) lcolor(navy) barwidth(3)) ///
       (bar b percentile if percentile>=40, sort fcolor(navy) lcolor(navy) barwidth(3) fintensity(30)), ///
       ytitle(Percentage change) ytitle(, size(small)) ylabel(, labsize(small) angle(horizontal) nogrid)  ///
       xtitle(Percentile of income distribution) xtitle(, size(small)) xlabel(5(5)95, labsize(small)) ///
       legend(order(1 "Significant at 5%" 2 "Not significant") size(small)) ///
       graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) 

	   
// 图像X轴区分显著的两组，是看的回归的系数显著性
// 图像Y州显示的就是b值（即Percentage change）
graph save Figure2, asis replace






erase temp.dta
erase betas.dta
     
log close
