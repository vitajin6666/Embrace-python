************************************************************************************************************************************
*** Date:    December 2009
*** Authors: Beck, Levine, and Levkov
*** Purpose: Create Appendix Tables XA and XB in "Big Bad Banks? The Winners and Losers from Bank Deregulation in the United States"
*** Note:    Please change the working directories below 
************************************************************************************************************************************

clear
set mem 100m
set matsize 10000
set more off

cd "D:\python\learn_python\7.paper_code\DID\BBB\replication_thesis"

log using Appendix_TableX.log, replace

use "D:\python\learn_python\7.paper_code\DID\BBB\replication_thesis\data\macro_workfile.dta" , clear

generate base=1
sort statefip wrkyr
save temp, replace


*************************
*** unemployment rate ***
*************************
use "D:\python\learn_python\7.paper_code\DID\BBB\replication_thesis\data\BLS.dta" , clear

rename year wrkyr
keep statefip wrkyr unemploymentrate
sort statefip wrkyr

* 计算5期滞后
bysort statefip: generate unemploymentrate_1=unemploymentrate[_n-1]
bysort statefip: generate unemploymentrate_2=unemploymentrate[_n-2]
bysort statefip: generate unemploymentrate_3=unemploymentrate[_n-3]
bysort statefip: generate unemploymentrate_4=unemploymentrate[_n-4]
bysort statefip: generate unemploymentrate_5=unemploymentrate[_n-5]

sort statefip wrkyr
merge statefip wrkyr using temp
drop _merge*
keep if base==1

label var _intra "Bank deregulation"

local Xs gsp_pc_growth prop_blacks prop_dropouts prop_female_headed unemploymentrate

generate logistic_gini = log(gini/(1-gini))
generate log_gini      = log(gini)


****************
*** LOG GINI ***
****************

xtset statefip wrkyr

xtreg log_gini i._intra   i.wrkyr, fe vce(cluster statefip) 
estimates store m1, title((1))

xtreg log_gini i._intra  `Xs' i.wrkyr, fe vce(cluster statefip)
estimates store m2, title((2))

xtreg log_gini i._intra  `Xs' unemploymentrate_1 i.wrkyr, fe vce(cluster statefip)
estimates store m3, title((3))

xtreg log_gini i._intra `Xs' unemploymentrate_1 unemploymentrate_2 i.wrkyr, fe vce(cluster statefip)
estimates store m4, title((4))

xtreg log_gini i._intra `Xs' unemploymentrate_1 unemploymentrate_2 unemploymentrate_3 i.wrkyr, fe vce(cluster statefip)
estimates store m5, title((5))

xtreg log_gini i._intra `Xs' unemploymentrate_1 unemploymentrate_2 unemploymentrate_3 unemploymentrate_4 i.wrkyr, fe vce(cluster statefip)
estimates store m6, title((6))

xtreg log_gini i._intra `Xs' unemploymentrate_1 unemploymentrate_2 unemploymentrate_3 unemploymentrate_4 unemploymentrate_5  i.wrkyr, fe vce(cluster statefip)
estimates store m7, title((7))


estout m1 m2 m3 m4 m5 m6 m7 using Appendix_TableXA.txt, replace ///
	keep(1._intra  `Xs' unemploymentrate_1 unemploymentrate_2 unemploymentrate_3 unemploymentrate_4 unemploymentrate_5) ///
	cells(b(star fmt(3)) se(par)) stats(r2 N, labels("R-squared" "Observations") fmt(2 0)) ///
	legend label collabel(none) ///
	prehead("") ///
	posthead("") ///
	postfoot("") ///
	starlevel(* 0.10 ** 0.05 *** 0.01)


*********************
*** LOGISTIC GINI ***
*********************
xtreg logistic_gini i._intra  i.wrkyr, fe vce(cluster statefip) 
estimates store m1, title((1))

xtreg logistic_gini i._intra `Xs' i.wrkyr, fe vce(cluster statefip)
estimates store m2, title((2))

xtreg logistic_gini i._intra `Xs' unemploymentrate_1 i.wrkyr, fe vce(cluster statefip)
estimates store m3, title((3))

xtreg logistic_gini i._intra `Xs' unemploymentrate_1 unemploymentrate_2 i.wrkyr, fe vce(cluster statefip)
estimates store m4, title((4))

xtreg logistic_gini i._intra `Xs' unemploymentrate_1 unemploymentrate_2 unemploymentrate_3 i.wrkyr, fe vce(cluster statefip)
estimates store m5, title((5))

xtreg logistic_gini i._intra `Xs' unemploymentrate_1 unemploymentrate_2 unemploymentrate_3 unemploymentrate_4 i.wrkyr, fe vce(cluster statefip)
estimates store m6, title((6))

xtreg logistic_gini i._intra `Xs' unemploymentrate_1 unemploymentrate_2 unemploymentrate_3 unemploymentrate_4 unemploymentrate_5  i.wrkyr, fe vce(cluster statefip)
estimates store m7, title((7))

estout m1 m2 m3 m4 m5 m6 m7 using Appendix_TableXB.txt, replace ///
	keep(1._intra  `Xs' unemploymentrate_1 unemploymentrate_2 unemploymentrate_3 unemploymentrate_4 unemploymentrate_5) ///
	cells(b(star fmt(3)) se(par)) stats(r2 N, labels("R-squared" "Observations") fmt(2 0)) ///
	legend label collabel(none) ///
	prehead("") ///
	posthead("") ///
	postfoot("") ///
	starlevel(* 0.10 ** 0.05 *** 0.01) ///


erase temp.dta
log close
