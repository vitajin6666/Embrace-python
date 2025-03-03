********************************************************************************************
*** THIS PROGRAM: summary statistics with micro_workfile
******************************************************************************************** 

use "D:\python\learn_python\7.paper_code\DID\BBB\replication_thesis\data\micro_workfile.dta", clear

******************************************************************************************** 

****************************************************************
*** 1. 筛选数据 ***
****************************************************************
keep if main_sample == 1

count

****************************************************************
*** 2. 生成新变量 ***
****************************************************************
gen _high_dropout = 0
replace _high_dropout = 1 if _hsd08== 1 | _hsd911== 1

gen _cgorad = 0
replace _cgorad = 1 if _cg== 1 | _ad == 1

****************************************************************
*** 3. 统计 ***
****************************************************************

preserve

collapse /// 
(mean) mean_age=_agelyr mean_female=_female mean_white=_white mean_black=_black mean_hispanic=_hispanic ///
		mean_high_dropout=_high_dropout mean_hsg=_hsg mean_sc=_sc mean_cgorad=_cgorad ///
		mean_wageworker=_wageworker mean_self_employed=_self_employed mean_inctot_cpi=_inctot_cpi ///
(min) min_age=_agelyr min_female=_female min_white=_white min_black=_black min_hispanic=_hispanic ///
       min_high_dropout=_high_dropout min_hsg=_hsg min_sc=_sc min_cgorad=_cgorad ///
       min_wageworker=_wageworker min_self_employed=_self_employed min_inctot_cpi=_inctot_cpi ///
(max) max_age=_agelyr max_female=_female max_white=_white max_black=_black max_hispanic=_hispanic ///
       max_high_dropout=_high_dropout max_hsg=_hsg max_sc=_sc max_cgorad=_cgorad ///
       max_wageworker=_wageworker max_self_employed=_self_employed max_inctot_cpi=_inctot_cpi ///
[pw=_perwt]

list 

restore


