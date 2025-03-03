* #delimit // 将行分隔符改为分号(我不喜欢这么操作，直接去掉源代码分号吧)

****************************************************************
*** 1.处理时间变量和权重 ***
****************************************************************


use "D:\python\learn_python\7.paper_code\DID\BBB\replication_thesis\data\cps_to_stata.dta" , clear

*****************************生成wrkyr和_agelyr***************************
tabulate year, missing // 对 year 变量进行频率统计（生成频数表），并且包括所有缺失值（missing values），看一下下载的年份对不对

generate wrkyr = year - 1 // 因为ASEC统计的收入数据是前一年的，所以需要减去一年，指向收入数据的当年
label variable wrkyr "survey year - 1"

gen _agelyr = age-1 // 用wrkyr当做时间变量的话，需要将年龄-1，指代wrkyr对应的年龄
label variable _agelyr "Age last year" 

*****************************Sampling weights***************************
* 这个操作是常规操作，尤其是涉及到04年的数据的时候，需要replace一下
* 添加 _ 通常是为了理解这个变量是 计算中间结果 或 临时处理的变量，而不是数据集的原本变量。这有助于在后期清理数据时，明确哪些变量是为了中间步骤创建的，可以被删除或替换。
generate _perwt = asecwt 
replace  _perwt = asecwt04 if year == 2004
label variable _perwt "Personal sampling weight"

generate _hhwt = asecwth
replace  _hhwt = asecwth04 if year == 2004
label variable _hhwt "Household sampling weight"

****************************************************************
*** 2.变量重新编码（按照cps的codebook改） ***
****************************************************************

****************************************************************
*** 2.1生成用于筛选和清洗数据的变量 ***
****************************************************************

*****************************Gender and athnicity***************************
gen     _female = 0 // male
replace _female = 1 if sex == 2  // female
replace _female = . if sex == . 

gen     _hispanic = 0 
replace _hispanic = 1 if hispan >=100 & hispan <=612 
replace _hispanic = . if hispan == 901 | hispan == 902 

gen _white = 0 
gen _black = 0

replace _white = 1 if race == 100 
replace _black = 1 if race == 200 

replace _white = 0 if _hispanic == 1 
replace _black = 0 if _hispanic == 1 

label variable _white "1 if person is white and not a Hispanic" 
label variable _black "1 if person is black and not a Hispanic" 



*****************************Years of completed education for all years (categorical version)***************************

gen _hsd08  = 0  // High school dropout: 未完成高中8年级及以下
gen _hsd911 = 0  // High school dropout: 未完成高中9-11
gen _hsg    = 0  // High school graduate: 完成高中
gen _sc     = 0  // Some college: 有些大学教育
gen _cg     = 0  // College graduate: 大学毕业
gen _ad     = 0  // Advanced degree: 高级学位

// 根据educ给定的编码规则进行重新编码
replace _hsd08 = 1 if inlist(educ, 002, 010, 011, 012, 013, 014, 020, 021, 022, 030, 031, 032)
replace _hsd911 = 1 if inlist(educ, 040, 050, 060 )
replace _hsg = 1 if inlist(educ, 070, 071, 072, 073)
replace _sc = 1 if inlist(educ, 080, 081, 090, 091, 092, 100)
replace _cg = 1 if inlist(educ, 110, 111)
replace _ad = 1 if inlist(educ, 120, 121, 122, 123, 124, 125)

replace _hsd08  = . if (educ ==. | educ == 999)
replace _hsd911 = . if (educ ==. | educ == 999)
replace _hsg    = . if (educ ==. | educ == 999)
replace _sc     = . if (educ ==. | educ == 999)
replace _cg     = . if (educ ==. | educ == 999)
replace _ad     = . if (educ ==. | educ == 999)

gen     _education = . 
replace _education = 1 if _hsd08  == 1 
replace _education = 2 if _hsd911 == 1 
replace _education = 3 if _hsg    == 1 
replace _education = 4 if _sc     == 1 
replace _education = 5 if _cg     == 1 
replace _education = 6 if _ad     == 1 
replace _education = . if (educ ==. | educ == 999)
replace _education = 0 if (educ ==000 | educ == 001)

label define _education 0 "NIU" 1 "HSD08" 2 "HSD911" 3 "HSG" 4 "SC" 5 "CG" 6 "AD" 
label values _education _education 

label variable _education "6 _education categories, hsd08 hsd911 hsg sc cg ad (IPUMS)" 



*****************************Income***************************
*** a. adjusting for missing values
generate _inctot = inctot 
replace  _inctot = . if inctot == 999999998 | inctot == 999999999
label variable _inctot "Total personal income"

generate _incwage = incwage 
replace  _incwage = . if incwage == 99999998 | incwage == 99999999
replace  _incwage = . if gq~=1 // 1=Households；此外所有值表示住集体宿舍
label variable _incwage "Wage and salary income"

generate _incbus = incbus 
replace  _incbus = . if incbus == 99999998 | incbus == 99999999
replace  _incbus = . if gq~=1
label variable _incbus "Business income"

generate _hhincome = hhincome 
replace  _hhincome = . if hhincome == 99999999
replace  _hhincome = . if hhincome <= 0 
label variable _hhincome "Total household income"


*** b. adjusting for inflation
* 将收入数据调整为以2000年的物价水平为基准，消除通货膨胀的影响
generate _cpi = . 
replace  _cpi =	56.9	if wrkyr == 	1976	
replace  _cpi =	60.6	if wrkyr == 	1977	
replace  _cpi =	65.2	if wrkyr == 	1978	
replace  _cpi =	72.6	if wrkyr == 	1979	
replace  _cpi =	82.4	if wrkyr == 	1980	
replace  _cpi =	90.9	if wrkyr == 	1981	
replace  _cpi =	96.5	if wrkyr == 	1982	
replace  _cpi =	99.6	if wrkyr == 	1983	
replace  _cpi =	103.9	if wrkyr == 	1984	
replace  _cpi =	107.6	if wrkyr == 	1985	
replace  _cpi =	109.6	if wrkyr == 	1986	
replace  _cpi =	113.6	if wrkyr == 	1987	
replace  _cpi =	118.3	if wrkyr == 	1988	
replace  _cpi =	124	    if wrkyr == 	1989	
replace  _cpi =	130.7	if wrkyr == 	1990	
replace  _cpi =	136.2	if wrkyr == 	1991	
replace  _cpi =	140.3	if wrkyr == 	1992	
replace  _cpi =	144.5	if wrkyr == 	1993	
replace  _cpi =	148.2	if wrkyr == 	1994	
replace  _cpi =	152.4	if wrkyr == 	1995	
replace  _cpi =	156.9	if wrkyr == 	1996	
replace  _cpi =	160.5	if wrkyr == 	1997	
replace  _cpi =	163	    if wrkyr == 	1998	
replace  _cpi =	166.6	if wrkyr == 	1999	
replace  _cpi =	172.2	if wrkyr == 	2000	
replace  _cpi =	177.1	if wrkyr == 	2001	
replace  _cpi =	179.9	if wrkyr == 	2002	
replace  _cpi =	184	    if wrkyr == 	2003	
replace  _cpi =	188.9	if wrkyr == 	2004	
replace  _cpi =	195.3	if wrkyr == 	2005	
replace  _cpi =	201.6	if wrkyr == 	2006	
replace  _cpi =	207.342 if wrkyr == 	2007	

generate _cpi_deflator2000 = 172.2 / _cpi  //计算2000年基准下的CPI调节因子

generate  _inctot_cpi = _inctot * _cpi_deflator2000 
label variable _inctot_cpi "Total personal income, in 2000 dollars"

//基于 2000 年物价水平调整后的个人总收入（通胀调整后的收入）

generate  _incwage_cpi  =  _incwage  * _cpi_deflator2000 
label variable _incwage_cpi  "Wage and salary income, in 2000 dollars"

generate  _incbus_cpi   =  _incbus   * _cpi_deflator2000 
label variable _incbus_cpi   "Business income, in 2000 dollars"

generate  _hhincome_cpi =  _hhincome * _cpi_deflator2000 
label variable _hhincome_cpi "Total household income, in 2000 dollars"

sort wrkyr

save temp, replace

*** c. cutting outliers
use temp, clear


keep if _agelyr >= 25 & _agelyr <= 54
keep if _inctot_cpi >= 0

*可计算不同年份下的 收入分布极值 (第1与第99百分位)
collapse ///
(p1)  pct01 = _inctot_cpi ///
(p99) pct99 = _inctot_cpi ///
[pw=_perwt], by(wrkyr)
sort wrkyr

merge wrkyr using temp //将当前数据集与 temp.dta 文件中的数据按 wrkyr 变量合并

drop _merge* //_merge，表示匹配状态:3 = 在两个数据集中均出现（匹配成功）

erase temp.dta


generate _inctot_cpi_tr01   = _inctot_cpi
generate _inctot_cpi_tr99   = _inctot_cpi
generate _inctot_cpi_tr0199 = _inctot_cpi

replace  _inctot_cpi_tr01   = . if _inctot_cpi <= pct01
replace  _inctot_cpi_tr99   = . if _inctot_cpi >= pct99
replace  _inctot_cpi_tr0199 = . if _inctot_cpi <= pct01
replace  _inctot_cpi_tr0199 = . if _inctot_cpi >= pct99
replace  _inctot_cpi_tr0199 = . if _inctot_cpi_tr0199 < 0

label variable _inctot_cpi_tr01   "Total personal income, in 2000 dollars, w/o 01 prc. outliers"
label variable _inctot_cpi_tr99   "Total personal income, in 2000 dollars, w/o 99 prc. outliers"
label variable _inctot_cpi_tr0199 "Total personal income, in 2000 dollars, w/o 01 and 99 prc. outliers"
drop pct01 pct99

****************************************************************
*** 2.2 编码其他控制变量 ***
****************************************************************

*****************************Female-headed household indicator***************************

generate temp = 0
replace  temp = 1 if _female == 1 & relate == 101

bysort statefip wrkyr serial: egen _female_headed = max(temp)
drop temp
label variable _female_headed "1 if female_headed household"

*****************************Labor supply ***************************

gen     _wageworker = 0 
replace _wageworker = 1 if classwly >=20 & classwly <=28 
label variable _wageworker "1 if wage/salary worker last year" 

gen     _self_employed = 0 
replace _self_employed = 1 if classwly >=10 & classwly <=14 
label variable _self_employed "1 if Self-employed worker last year" 


gen _wkslyr = wkswork1 
label variable _wkslyr "Weeks worked last year" 

gen _hrslyr = uhrsworkly 
replace _hrslyr = 0 if uhrsworkly == 999
label variable _hrslyr "Usual hours worked per week last year" 

gen _anhrslyr = _wkslyr*_hrslyr 
label variable _anhrslyr "Annual hours worked last year" 


gen     _FY = 0 //Full Year Worker
replace _FY = 1 if _wkslyr >= 50 
label variable _FY "1 if person worked 50 weeks last year" 

gen     _FT = 0 //Full Time Worker
replace _FT = 1 if _hrslyr >= 35 
label variable _FT "1 if person worked 35+ hours per week last year" 

gen     _FTFY = _FT*_FY 
label variable _FTFY "1 if person worked 50 weeks last year and 35+ hours per week" 

label define _FTFY 1 "Full-Time_Full-Year" 0 "Not Full-Time_Full-Year" 
*  如果 _FTFY 的值为 1，那么它会被标记为 "Full-Time_Full-Year"（即全职且全年的工作者）
* 如果 _FTFY 的值为 0，那么它会被标记为 "Not Full-Time_Full-Year"（即非全职全年的工作者）。
label values _FTFY _FTFY 
* 生成一个新变量_FTFY值就是"Full-Time_Full-Year" or "Not Full-Time_Full-Year"
  
label variable _FTFY "50+ wkslyr and 35+ _hrslyr" 

*****************************受教育年限***************************
gen _educomp = .  // 初始化 _educomp 为缺失值

// 根据 educ 变量的编码设置 _educomp 的值
replace _educomp = 0 if educ == 000 | educ == 001  // NIU or no schooling
replace _educomp = 0 if educ == 002  // None or preschool
replace _educomp = 4 if inlist(educ, 010, 011, 012, 013, 014)  // Grades 1-4
replace _educomp = 6 if inlist(educ, 020, 021, 022)  // Grades 5-6
replace _educomp = 8 if inlist(educ, 030, 031, 032)  // Grades 7-8
replace _educomp = 9 if educ == 040  // Grade 9
replace _educomp = 10 if educ == 050  // Grade 10
replace _educomp = 11 if educ == 060  // Grade 11
replace _educomp = 12 if inlist(educ, 070, 071, 072, 073)  // Grade 12
replace _educomp = 13 if educ == 080  // 1 year of college
replace _educomp = 14 if educ == 081  // Some college but no degree
replace _educomp = 14 if educ == 090  // 2 years of college
replace _educomp = 14 if educ == 091  // Associate's degree, occupational/vocational program
replace _educomp = 14 if educ == 092  // Associate's degree, academic program

replace _educomp = 15 if educ == 100                  // 3 years of college
replace _educomp = 16 if inlist(educ, 110, 111)       // 4 years of college or bachelor's degree
replace _educomp = 17 if inlist(educ, 120, 121)       // 5 years of college
replace _educomp = 18 if educ == 122                  // 6+ years of college
replace _educomp = 18 if educ == 123                  // Master's degree
replace _educomp = 19 if inlist(educ, 124, 125)       // Professional school degree or doctorate
replace _educomp = .  if educ == 999                  // Missing/Unknown

*****************************Potential experience***************************

gen     _exp = _agelyr - 7 - _educomp //完成教育之后进入劳动市场的年数
replace _exp = 0 if _exp < 0 

gen _exp1 = _exp - 15
gen _exp2 = _exp1^2
gen _exp3 = _exp1^3
gen _exp4 = _exp1^4

label variable _exp "Potential experience" 

*****************************Education-potential experience interactions***************************
generate _hsd08_exp1 = _hsd08 * _exp1
generate _hsd08_exp2 = _hsd08 * _exp2
generate _hsd08_exp3 = _hsd08 * _exp3
generate _hsd08_exp4 = _hsd08 * _exp4

generate _hsd911_exp1 = _hsd911 * _exp1
generate _hsd911_exp2 = _hsd911 * _exp2
generate _hsd911_exp3 = _hsd911 * _exp3
generate _hsd911_exp4 = _hsd911 * _exp4

generate _hsg_exp1 = _hsg * _exp1
generate _hsg_exp2 = _hsg * _exp2
generate _hsg_exp3 = _hsg * _exp3
generate _hsg_exp4 = _hsg * _exp4

generate _sc_exp1 = _sc * _exp1
generate _sc_exp2 = _sc * _exp2
generate _sc_exp3 = _sc * _exp3
generate _sc_exp4 = _sc * _exp4

generate _cg_exp1 = _cg * _exp1
generate _cg_exp2 = _cg * _exp2
generate _cg_exp3 = _cg * _exp3
generate _cg_exp4 = _cg * _exp4

generate _ad_exp1 = _ad * _exp1
generate _ad_exp2 = _ad * _exp2
generate _ad_exp3 = _ad * _exp3
generate _ad_exp4 = _ad * _exp4

****************************************************************
*** 3. 筛选数据 ***
****************************************************************


*****************************Main sample indicator***************************
generate main_sample = 1

// keep prime-age (25-54) civilians
replace  main_sample = 0 if _agelyr < 25 
replace  main_sample = 0 if _agelyr > 54

// cut(ii) individuals with total personal income below the 1st or above the 99th percentile of the distribution of income （keep people have non-negative personal income）
replace  main_sample = 0 if _inctot_cpi_tr0199 == .

******Sample restrictions 1 completed


//cut (i) individuals with missing observations on key variables (education, demographics, etc)
replace  main_sample = 0 if _hsd08==. | _hsd911==. | _hsg==. | _sc==. | _cg==. | _ad==.
replace  main_sample = 0 if _white==. | _black==. | _hispanic==.

*******Sample restrictions 2 completed

//cut(iii) ppeople living in group quarters
replace  main_sample = 0 if gq ~= 1 

*******Sample restrictions 3 completed

//drop Delaware and South Dakota
replace  main_sample = 0 if statefip == 10
replace  main_sample = 0 if statefip == 46

********Sample restrictions 4 completed


//cut(iv) individuals who receive zero income and live in households with zero or negative income from all sources of income
replace  main_sample = 0 if _hhincome_cpi == .

*********Sample restrictions 5 completed

//cut(v) a few individuals for which the CPS assigns a zero (or missing) sampling weight.
replace  main_sample = 0 if _hhwt == . | _hhwt == 0
replace  main_sample = 0 if _perwt == . | _perwt == 0

*********Sample restrictions 6 completed

tabulate main_sample, missing

compress //压缩数据文件，通过优化变量的存储类型来减少内存占用

save micro_workfile_workfile, replace



