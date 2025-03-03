**********************************************************************************************************************************
*** Date:    December 2009
*** Authors: Beck, Levine, and Levkov
*** Purpose: Create Table II in "Big Bad Banks? The Winners and Losers from Bank Deregulation in the United States"
*** Note:    Please change the working directories below 
**********************************************************************************************************************************

clear
set mem 100m
set more off

cd "D:\python\learn_python\7.paper_code\DID\BBB\replication_thesis"

log using TableII.log, replace

use "D:\python\learn_python\7.paper_code\DID\BBB\replication_thesis\data\macro_workfile.dta" , clear


label var _intra "Bank deregulation"

replace p10 = 1 if p10==0

generate logistic_gini = log(gini/(1-gini))
generate log_gini      = log(gini)
generate log_theil     = log(theil)
generate log_9010      = log(p90)-log(p10)
generate log_7525      = log(p75)-log(p25)

*****************************Panel A
xtset statefip wrkyr

xtreg logistic_gini i._intra  i.wrkyr, fe vce(cluster statefip) 
estimates store m1, title(Logistic Gini)

* 去掉处置行为，只看州和时间固定效应的R方（解释力）
xtreg logistic_gini i.wrkyr, fe vce(cluster statefip) 


xtreg log_gini i._intra  i.wrkyr, fe vce(cluster statefip) 
estimates store m2, title(Log Gini)

xtreg log_theil i._intra  i.wrkyr, fe vce(cluster statefip) 
estimates store m3, title(Log Theil)

xtreg log_9010 i._intra  i.wrkyr, fe vce(cluster statefip) 
estimates store m4, title(Log 90/10)

xtreg log_7525 i._intra  i.wrkyr, fe vce(cluster statefip) 
estimates store m5, title(Log 75/25)

estout m1 m2 m3 m4 m5 using TableII.txt, replace /// 
	keep(1._intra) ///
	cells(b(star fmt(3)) se(par) p(fmt(3) par({ }))) stats(r2 N, labels("R-squared" "Observations") fmt(2 0)) ///
	legend label collabel(none) ///
	prehead("Table II" "The Impact of Deregulation on Income Inequality") ///
	posthead("Panel A: No controls") ///
	postfoot("") ///
	starlevel(* 0.10 ** 0.05 *** 0.01)

	
	
*****************************Panel B

local Xs gsp_pc_growth prop_blacks prop_dropouts prop_female_headed unemploymentrate

xtreg logistic_gini i._intra `Xs' i.wrkyr, fe vce(cluster statefip)
estimates store m1, title(Logistic Gini)

xtreg log_gini i._intra `Xs' i.wrkyr, fe vce(cluster statefip)
estimates store m2, title(Log Gini)

xtreg log_theil i._intra `Xs' i.wrkyr, fe vce(cluster statefip)
estimates store m3, title(Log Theil)

xtreg log_9010 i._intra `Xs' i.wrkyr, fe vce(cluster statefip)
estimates store m4, title(Log 90/10)

xtreg log_7525 i._intra `Xs' i.wrkyr, fe vce(cluster statefip)
estimates store m5, title(Log 75/25)


estout m1 m2 m3 m4 m5 using TableII.txt, append ///
	keep(1._intra `Xs') ///
	cells(b(star fmt(3)) se(par) p(fmt(3) par({ }))) stats(r2 N, labels("R-squared" "Observations") fmt(2 0)) ///
	legend label collabel(none) ///
	posthead("Panel B: With controls") ///
	postfoot("") ///
	starlevel(* 0.10 ** 0.05 *** 0.01)

log close

