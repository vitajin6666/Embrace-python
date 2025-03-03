**********************************************************************************************************************************
*** Date:    December 2009
*** Authors: Beck, Levine, and Levkov
*** Purpose: Create Table I in "Big Bad Banks? The Winners and Losers from Bank Deregulation in the United States"
*** Note:    Please change the working directories below 
**********************************************************************************************************************************


clear
set mem 100m
set more off

cd "D:\python\learn_python\7.paper_code\DID\BBB\replication_thesis"

log using TableI.log, replace

use "D:\python\learn_python\7.paper_code\DID\BBB\replication_thesis\data\macro_workfile.dta" , clear




keep if ks99==1  // 用Kroszner and Strahan (1999)中的数据

drop if inter1 == . | inter2 == .  //保证关键变量完整

replace gini = gini * 100 // 将 Gini 系数从 0-1 的小数形式转换为 0-100 的百分比形式（例如，从 0.3 变成 30），数值变化会更直观, 增强计算精度或解释

label var gini "Gini coefficient of income inequality"

replace wrkyr = wrkyr - 1975 // 转换为以 1975 年为基准的相对年份

*****************************定义控制变量

* Controls
local laborXs gsp_pc_growth prop_blacks prop_dropouts prop_female_headed unemploymentrate
* Political-economy factors
local financialXs ass4_ass cap_dif4 inter1 ins_dum inter2 e_interp dem uniform lncon1 unit bankpow
* Regional indicators
local regionalXs reg1 reg2 reg3 



*****************************设置生存分析
* 生存分析的目标通常是估计某一事件（如管制解除）发生的时间与某些因素的关系

* 因变量 = 生存时间（wrkyr） + 事件是否发生（death）
stset wrkyr death, id(statefip)

* Weibull 回归模型
streg gini, robust cluster(statefip) dist(weibull) time
estimates store m1, title((1))

streg gini `laborXs', robust cluster(statefip) dist(weibull) time
estimates store m2, title((2))

streg gini `financialXs', robust cluster(statefip) dist(weibull) time
estimates store m3, title((3))

streg gini `laborXs' `financialXs', robust cluster(statefip) dist(weibull) time
estimates store m4, title((4))


streg gini `laborXs' `financialXs' `regionalXs' , robust cluster(statefip) dist(weibull) time
estimates store m5, title((5))

* 输出结果
estout m1 m2 m3 m4 m5 using TableI_output.txt, replace ///
	keep(gini) ///
	cells(b(star fmt(2)) se(par)) stats(N, labels(Observations) fmt(0)) ///
	legend label collabel(none)  ///
	prehead("Table I" "Timing of Bank Deregulation and Pre-Existing Income Inequality: The Duration Model") ///
	posthead("") prefoot("") postfoot("") ///
	starlevel(* 0.10 ** 0.05 *** 0.01) nolz nolegend

* b：估计系数，带星号（*）表示显著性，保留两位小数（fmt(2)）。
* se：标准误，在括号中显示（par）

log close
