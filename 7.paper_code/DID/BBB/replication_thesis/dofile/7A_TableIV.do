**********************************************************************************************************************************
*** Date:    December 2009
*** Authors: Beck, Levine, and Levkov
*** Purpose: Create Table IV in "Big Bad Banks? The Winners and Losers from Bank Deregulation in the United States"
*** Note:    Please change the working directories below
*** Note:    The calculation of Theil index is very time consuming
**********************************************************************************************************************************



clear
set mem 2g
set more off

cd "D:\python\learn_python\7.paper_code\DID\BBB\replication_thesis"

log using TableIV.log, replace


*******************************************
*** CALCULATING THEIL INDEX FOR PANEL A ***
*******************************************
use "D:\python\learn_python\7.paper_code\DID\BBB\replication_thesis\data\micro_workfile.dta" , clear
keep if main_sample == 1

*** 定义群体
generate group = .
replace group = 1 if classwly == 13 | classwly == 14 // Group 1 -- self-employed
replace group = 2 if classwly >= 22 & classwly <= 28 // Group 2 -- wage and salary workers

drop if group == .
tab group, missing



*** 计算 1976-2006 年所有州的 Theil 指数


levels statefip, local(state) // 获取所有州的唯一值，存入本地宏 state
levels wrkyr, local(time) // // 获取所有年份的唯一值，存入本地宏 time
foreach s of local state {
    foreach t of local time {
        quietly ineqdeco Y [aw = _perwt]          if statefip == `s' & wrkyr == `t', bygroup(group)
        quietly replace total    = r(ge1)         if statefip == `s' & wrkyr == `t'
        quietly replace between  = r(between_ge1) if statefip == `s' & wrkyr == `t'
        quietly replace within   = r(within_ge1)  if statefip == `s' & wrkyr == `t'
        quietly replace within_1 = r(ge1_1)       if statefip == `s' & wrkyr == `t'
        quietly replace within_2 = r(ge1_2)       if statefip == `s' & wrkyr == `t'
        display "Now running year " `t' " and state... " `s'
    }
}

* 使用 ineqdeco 命令（Stata 的不平等分解工具）计算收入 Y 的 Theil 指数，加权变量为 _perwt，按 group（自雇者 vs. 工薪阶层）分解
	* total = r(ge1)：总 Theil 指数（GE(1) 形式）。
	* between = r(between_ge1)：组间 Theil 指数。
	* within = r(within_ge1)：组内总 Theil 指数。
	* within_1 = r(ge1_1)：组 1（自雇者）内部 Theil 指数。
	* within_2 = r(ge1_2)：组 2（工薪阶层）内部 Theil 指数。
	
keep statefip wrkyr total between within within_1 within_2
duplicates drop
sort statefip wrkyr
save "TableIVpanelA", replace



*******************************************
*** CALCULATING THEIL INDEX FOR PANEL B ***
*******************************************
use "D:\python\learn_python\7.paper_code\DID\BBB\replication_thesis\data\micro_workfile.dta" , clear
keep if main_sample == 1
keep if classwly>=22 & classwly<=28 // 只保留wage and salary workers

generate group=.
replace  group=1 if _hsd08==1 | _hsd911==1 | _hsg==1 // *** Group 1 -- education 0-12
replace  group=2 if _sc==1 | _cg==1 | _ad==1 // *** Group 2 -- education 13+
replace  group=2 if educrec==9
tab group, missing

keep statefip wrkyr _inctot_cpi_tr0199 _perwt serial group

generate Y = _inctot_cpi_tr0199

generate total    = .
generate between  = .
generate within   = .
generate within_1 = .
generate within_2 = .

*** 计算 1976-2006 年所有州的 Theil 指数
	* 使用 ineqdeco 命令（Stata 的不平等分解工具）计算收入 Y 的 Theil 指数，加权变量为 _perwt，按 group（自雇者 vs. 工薪阶层）分解

	* total = r(ge1)：总 Theil 指数（GE(1) 形式）。
	* between = r(between_ge1)：组间 Theil 指数。
	* within = r(within_ge1)：组内总 Theil 指数。
	* within_1 = r(ge1_1)：组 1（自雇者）内部 Theil 指数。
	* within_2 = r(ge1_2)：组 2（工薪阶层）内部 Theil 指数。

levels statefip, local(state) // 获取所有州的唯一值，存入本地宏 state
levels wrkyr, local(time) // // 获取所有年份的唯一值，存入本地宏 time
foreach s of local state {
    foreach t of local time {
        quietly ineqdeco Y [aw = _perwt]          if statefip == `s' & wrkyr == `t', bygroup(group)
        quietly replace total    = r(ge1)         if statefip == `s' & wrkyr == `t'
        quietly replace between  = r(between_ge1) if statefip == `s' & wrkyr == `t'
        quietly replace within   = r(within_ge1)  if statefip == `s' & wrkyr == `t'
        quietly replace within_1 = r(ge1_1)       if statefip == `s' & wrkyr == `t'
        quietly replace within_2 = r(ge1_2)       if statefip == `s' & wrkyr == `t'
        display "Now running year " `t' " and state... " `s'
    }
}

keep statefip wrkyr total between within within_1 within_2
duplicates drop
sort statefip wrkyr
save "TableIVpanelB", replace


*******************************************************
*** DECOMPOSING THE IMPACT OF DEREGULATION, PANEL A ***
*******************************************************
use "/home/alevkov/BeckLevineLevkov2010/data/macro_workfile.dta", clear

sort statefip wrkyr
merge statefip wrkyr using TableIVpanelA
drop _merge*

drop if statefip==10
drop if statefip==46

xtset statefip wrkyr

xtreg total _intra i.wrkyr, fe vce(cluster statefip)
estimates store m1, title(Total)

xtreg between _intra i.wrkyr, fe vce(cluster statefip)
estimates store m2, title(Between Groups)

xtreg within _intra i.wrkyr, fe vce(cluster statefip)
estimates store m3, title(Within Groups)

xtreg within_1 _intra i.wrkyr, fe vce(cluster statefip)
estimates store m4, title(Self Employed)

xtreg within_2 _intra i.wrkyr, fe vce(cluster statefip)
estimates store m5, title(Salaried)

estout m1 m2 m3 m4 m5 using TableIV.txt, replace ///
	keep(_intra) ///
	cells(b(star fmt(4)) se(par) p(fmt(4) par({ }))) stats(r2 N, labels("R-squared" "Observations") fmt(2 0)) /// 
	legend label collabel(none) ///
	prehead("Table 2" "Decomposing the Impact of Deregulation on Income Inequality to Between- and Within-Groups") ///
	posthead("Panel A: All Workers") prefoot("")  ///
	postfoot("Note:") ///
	starlevel(* 0.10 ** 0.05 *** 0.01) nolz nolegend



*******************************************************
*** DECOMPOSING THE IMPACT OF DEREGULATION, PANEL B ***
*******************************************************
use "D:\python\learn_python\7.paper_code\DID\BBB\replication_thesis\data\macro_workfile.dta" , clear

sort statefip wrkyr
merge statefip wrkyr using TableIVpanelB
drop _merge*

drop if statefip==10
drop if statefip==46

xtset statefip wrkyr

xtreg total _intra i.wrkyr, fe vce(cluster statefip)
estimates store m1, title(Total)

xtreg between _intra i.wrkyr, fe vce(cluster statefip)
estimates store m2, title(Between Groups)

xtreg within _intra i.wrkyr, fe vce(cluster statefip)
estimates store m3, title(Within Groups)

xtreg within_1 _intra i.wrkyr, fe vce(cluster statefip)
estimates store m4, title(High School or Less)

xtreg within_2 _intra i.wrkyr, fe vce(cluster statefip)
estimates store m5, title(Some College or More)

estout m1 m2 m3 m4 m5 using TableIV.txt, append ///
	keep(_intra) ///
	cells(b(star fmt(4)) se(par) p(fmt(4) par({ }))) stats(r2 N, labels("R-squared" "Observations") fmt(2 0)) ///
	legend label collabel(none) ///
	prehead("") ///
	posthead("Panel B: Salaried Workers") prefoot("")  ///
	postfoot("Note:") ///
	starlevel(* 0.10 ** 0.05 *** 0.01) nolz nolegend

erase temporary.dta
log close
