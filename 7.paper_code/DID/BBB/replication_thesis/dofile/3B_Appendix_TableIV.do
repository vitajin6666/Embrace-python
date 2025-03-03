**********************************************************************************************************************************
*** Date:    December 2009
*** Authors: Beck, Levine, and Levkov
*** Purpose: Create Appendix Table IV in "Big Bad Banks? The Winners and Losers from Bank Deregulation in the United States"
*** Note:    Please change the working directories below
**********************************************************************************************************************************

clear
set mem 100m
set more off

cd "D:\python\learn_python\7.paper_code\DID\BBB\replication_thesis"

log using Appendix_TableIV.log, replace


**********************
*** LOGISTIC(GINI) ***
**********************

**********************方法1：用回归控制个体和时间固定效应+计算残差算剩余变异性
use "D:\python\learn_python\7.paper_code\DID\BBB\replication_thesis\data\macro_workfile.dta", clear

generate y = log(gini/(1-gini))

summarize y 

reg y i.wrkyr i.statefip ,vce(cluster statefip)
predict resid, resid
summarize resid // 控制州和年固定效应后的剩余变异性



**********************方法2：用减去均值的方法算剩余变异性（论文原本的方法）
* 如果数据是均衡面板（balanced panel，每个州每年都有观测），且没有其他协变量，两种方法的结果可能非常接近。
* 如果数据是不均衡面板（unbalanced panel），回归方法更精确，因为它会加权处理缺失值，而均值减法可能偏误。


**********************计算每个州的 LOGISTIC(GINI) 的均值
use "D:\python\learn_python\7.paper_code\DID\BBB\replication_thesis\data\macro_workfile.dta", clear

generate y = log(gini/(1-gini))

reg y i.wrkyr i.statefip ,vce(cluster statefip)
predict resid, resid
summarize resid


bysort statefip: egen mean1 = mean(y)
keep statefip mean1
duplicates drop
sort statefip
save mean1, replace

**********************每个年份的 LOGISTIC(GINI) 的均值
use "D:\python\learn_python\7.paper_code\DID\BBB\replication_thesis\data\macro_workfile.dta", clear
generate y = log(gini/(1-gini))
bysort wrkyr: egen mean2 = mean(y)
keep wrkyr mean2
duplicates drop
sort wrkyr
save mean2, replace



**********************去掉 Gini 系数的州均值和年份均值，使得最终变量只反映个体层面的变化，而不受州或年份的结构性因素影响
use "D:\python\learn_python\7.paper_code\DID\BBB\replication_thesis\data\macro_workfile.dta", clear

generate y = log(gini/(1-gini))

* 合并州均值和年份均值到主数据集
sort statefip
merge statefip using mean1
drop _merge
tab1 statefip, missing

sort wrkyr
merge wrkyr using mean2
tab1 wrkyr, missing

erase mean1.dta
erase mean2.dta

*计算去趋势化（de-trended）变量

generate state_de_trended       = y - mean1 
generate wrkyr_de_trended       = y - mean2 
generate state_wrkyr_de_trended = y - mean1 - mean2 


*** SIMPLE STATS(计算总变异性) ***
summarize y

**********************以下三术语涉及数据的变异性分解（variance decomposition），用于衡量不同层级上的数据波动情况


*** CROSS-STATES STANDARD DEVIATION ***
summarize state_de_trended // 同一年，不同州之间的 Gini 水平差异：需要用该年不同州的值 - 那一州所有年的均值

*** WITHIN-STATES STANDARD DEVIATION ***
summarize wrkyr_de_trended // 同一州在不同年份的 Gini 变化：需要用该州不同年份的值 - 那一年的所有州的均值

*** WITHIN STATE-wrkyr STANDARD DEVIATION ***
summarize state_wrkyr_de_trended // 同一州、同一年里，不同个体的 Gini 差异


*****************
*** LOG(GINI) ***
*****************
use "D:\python\learn_python\7.paper_code\DID\BBB\replication_thesis\data\macro_workfile.dta", clear
generate y = log(gini)
bysort statefip: egen mean1 = mean(y)
keep statefip mean1
duplicates drop
sort statefip
save mean1, replace

use "D:\python\learn_python\7.paper_code\DID\BBB\replication_thesis\data\macro_workfile.dta", clear
generate y = log(gini)
bysort wrkyr: egen mean2 = mean(y)
keep wrkyr mean2
duplicates drop
sort wrkyr
save mean2, replace

use "D:\python\learn_python\7.paper_code\DID\BBB\replication_thesis\data\macro_workfile.dta", clear
generate y = log(gini)
sort statefip
merge statefip using mean1
drop _merge
tab1 statefip, missing
sort wrkyr
merge wrkyr using mean2
tab1 wrkyr, missing
erase mean1.dta
erase mean2.dta

generate state_de_trended       = y - mean1
generate wrkyr_de_trended       = y - mean2
generate state_wrkyr_de_trended = y - mean1 - mean2

*** SIMPLE STATS ***
summarize y

*** CROSS-STATES STANDARD DEVIATION ***
summarize state_de_trended

*** WITHIN-STATES STANDARD DEVIATION ***
summarize wrkyr_de_trended

*** WITHIN STATE-wrkyr STANDARD DEVIATION ***
summarize state_wrkyr_de_trended


******************
*** LOG(THEIL) ***
******************
use "D:\python\learn_python\7.paper_code\DID\BBB\replication_thesis\data\macro_workfile.dta", clear
generate y = log(theil)
bysort statefip: egen mean1 = mean(y)
keep statefip mean1
duplicates drop
sort statefip
save mean1, replace

use "D:\python\learn_python\7.paper_code\DID\BBB\replication_thesis\data\macro_workfile.dta", clear
generate y = log(theil)
bysort wrkyr: egen mean2 = mean(y)
keep wrkyr mean2
duplicates drop
sort wrkyr
save mean2, replace

use "D:\python\learn_python\7.paper_code\DID\BBB\replication_thesis\data\macro_workfile.dta", clear
generate y = log(theil)
sort statefip
merge statefip using mean1
drop _merge
tab1 statefip, missing
sort wrkyr
merge wrkyr using mean2
tab1 wrkyr, missing
erase mean1.dta
erase mean2.dta

generate state_de_trended       = y - mean1
generate wrkyr_de_trended       = y - mean2
generate state_wrkyr_de_trended = y - mean1 - mean2

*** SIMPLE STATS ***
summarize y

*** CROSS-STATES STANDARD DEVIATION ***
summarize state_de_trended

*** WITHIN-STATES STANDARD DEVIATION ***
summarize wrkyr_de_trended

*** WITHIN STATE-wrkyr STANDARD DEVIATION ***
summarize state_wrkyr_de_trended


******************
*** LOG(90/10) ***
******************
use "D:\python\learn_python\7.paper_code\DID\BBB\replication_thesis\data\macro_workfile.dta", clear

replace p10=1 if p10==0 // 替换掉0值

generate y = log(p90)-log(p10)
bysort statefip: egen mean1 = mean(y)
keep statefip mean1
duplicates drop
sort statefip
save mean1, replace

use "D:\python\learn_python\7.paper_code\DID\BBB\replication_thesis\data\macro_workfile.dta", clear
replace p10=1 if p10==0
generate y = log(p90)-log(p10)
bysort wrkyr: egen mean2 = mean(y)
keep wrkyr mean2
duplicates drop
sort wrkyr
save mean2, replace

use "D:\python\learn_python\7.paper_code\DID\BBB\replication_thesis\data\macro_workfile.dta", clear
replace p10=1 if p10==0
generate y = log(p90)-log(p10)
sort statefip
merge statefip using mean1
drop _merge
tab1 statefip, missing
sort wrkyr
merge wrkyr using mean2
tab1 wrkyr, missing
erase mean1.dta
erase mean2.dta

generate state_de_trended       = y - mean1
generate wrkyr_de_trended       = y - mean2
generate state_wrkyr_de_trended = y - mean1 - mean2

*** SIMPLE STATS ***
summarize y

*** CROSS-STATES STANDARD DEVIATION ***
summarize state_de_trended

*** WITHIN-STATES STANDARD DEVIATION ***
summarize wrkyr_de_trended

*** WITHIN STATE-wrkyr STANDARD DEVIATION ***
summarize state_wrkyr_de_trended


******************
*** LOG(75/25) ***
******************
use "D:\python\learn_python\7.paper_code\DID\BBB\replication_thesis\data\macro_workfile.dta", clear
generate y = log(p75)-log(p25)
bysort statefip: egen mean1 = mean(y)
keep statefip mean1
duplicates drop
sort statefip
save mean1, replace

use "D:\python\learn_python\7.paper_code\DID\BBB\replication_thesis\data\macro_workfile.dta", clear
generate y = log(p75)-log(p25)
bysort wrkyr: egen mean2 = mean(y)
keep wrkyr mean2
duplicates drop
sort wrkyr
save mean2, replace

use "D:\python\learn_python\7.paper_code\DID\BBB\replication_thesis\data\macro_workfile.dta", clear
generate y = log(p75)-log(p25)
sort statefip
merge statefip using mean1
drop _merge
tab1 statefip, missing
sort wrkyr
merge wrkyr using mean2
tab1 wrkyr, missing
erase mean1.dta
erase mean2.dta

generate state_de_trended       = y - mean1
generate wrkyr_de_trended       = y - mean2
generate state_wrkyr_de_trended = y - mean1 - mean2

*** SIMPLE STATS ***
summarize y

*** CROSS-STATES STANDARD DEVIATION ***
summarize state_de_trended

*** WITHIN-STATES STANDARD DEVIATION ***
summarize wrkyr_de_trended

*** WITHIN STATE-wrkyr STANDARD DEVIATION ***
summarize state_wrkyr_de_trended


log close
