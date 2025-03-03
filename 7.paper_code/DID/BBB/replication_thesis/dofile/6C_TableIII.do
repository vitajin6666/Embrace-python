**********************************************************************************************************************************
*** Date:    December 2009
*** Authors: Beck, Levine, and Levkov
*** Purpose: Create Table III in "Big Bad Banks? The Winners and Losers from Bank Deregulation in the United States"
*** Note:    Please change the working directories below 
**********************************************************************************************************************************



clear
set mem 100m
set more off

cd "D:\python\learn_python\7.paper_code\DID\BBB\replication_thesis"

log using TableIII.log, replace

use "D:\python\learn_python\7.paper_code\DID\BBB\replication_thesis\data\macro_workfile.dta" , clear



generate Y = log(gini/(1-gini))

xtset statefip wrkyr

*** Column (1) ***
* Y = β0 + β1*_intra + β2*unit_banking + β3*_intra_unit + 年份效应 + 州固定效应 + 误差项

// 当 unit_banking = 0 时
* Y = β0 + β1*_intra + β2*0 + β3*0 + 年份效应 + 州固定效应 + 误差项

* 去监管前（_intra = 0）：Y = β0 + 年份效应 + 州固定效应。
* 去监管后（_intra = 1）：Y = β0 + β1 + 年份效应 + 州固定效应。
* 去监管的影响：Y 的变化 = β1。
* 结论：在非单一银行制州（unit_banking = 0），去监管对 Y（收入不平等）的效应就是 β1。

// 当 unit_banking = 1 时
* Y = β0 + β1*_intra + β2*1 + β3*_intra + 年份效应 + 州固定效应 + 误差项
* Y = (β0 + β2) + (β1 + β3)*_intra + 年份效应 + 州固定效应 + 误差项
* 去监管前（_intra = 0）：Y = β0 + β2 + 年份效应 + 州固定效应。
* 去监管后（_intra = 1）：Y = β0 + β2 + β1 + β3 + 年份效应 + 州固定效应。
* 去监管的影响：Y 的变化 = β1 + β3。
* 结论：在单一银行制州（unit_banking = 1），去监管的总效应是 β1 + β3。

// 所以这里是比较单一银行制州的总效应（β1 + β3） vs. 非单一银行制州的效应（β1）
generate _intra_unit = _intra*unit_banking
label var _intra_unit "Deregulation x (unit banking)"
xtreg Y _intra unit_banking _intra_unit i.wrkyr, fe vce(cluster statefip)
lincom _intra + _intra_unit 


*** Column (2) ***
* 人口分散度 = 1 /（每平方英里人口数），数据来自 1960 年美国人口普查局估计。
* 论文研究的是去监管的影响如何依赖"初始条件"（initial conditions）。去监管发生在不同州的不同年份（比如 1970s-1980s），所以需要一个早于所有去监管时间的基准年份来定义"初始"状态，选定了1960年的数据


* 估计去监管在不同人口分散度水平下的效应，特别在第 25、50 和 75 百分位（percentiles）处评估。以得出结论是否人口越分散，效应越高
* Y = β0 + β1*_intra + β2*pop_dispersion + β3*_intra_dispersion + 年份效应 + 州固定效应 + 误差项
* 去监管前（_intra = 0）：Y = β0 + β2*pop_dispersion + 年份效应 + 州固定效应。
* 去监管后（_intra = 1）：Y = β0 + β2*pop_dispersion + β1 + β3*1*pop_dispersion + 年份效应 + 州固定效应。
* 去监管的影响：Y 的变化 = β1 + β3 * pop_dispersion

generate _intra_dispersion = _intra*pop_dispersion
label var _intra_dispersion "Deregulation x (initial population dispersion)"
sum pop_dispersion, detail
xtreg Y _intra pop_dispersion _intra_dispersion i.wrkyr, fe vce(cluster statefip)

lincom _intra + 0.0099*_intra_dispersion // Evaluated at the 25th percentile
lincom _intra + 0.0148*_intra_dispersion // Evaluated at the 50th percentile
lincom _intra + 0.0376*_intra_dispersion // Evaluated at the 75th percentile（最分散）


*** Column (3) ***
generate _intra_smallbanks = _intra*small_banks
label var _intra_smallbanks "Deregulation x (initial share of small banks)"
sum small_banks, detail
xtreg Y _intra small_banks _intra_smallbanks i.wrkyr, fe vce(cluster statefip)
lincom _intra + 0.074*_intra_smallbanks
lincom _intra + 0.109*_intra_smallbanks
lincom _intra + 0.137*_intra_smallbanks


*** Column (4) ***
generate _intra_smallfirms = _intra*small_firms
label var _intra_smallfirms "Deregulation x (initial share of small firms)"
sum small_firms, detail
xtreg Y _intra small_firms _intra_smallfirms year_dumm*, fe i(statefip) robust cluster(statefip)
lincom _intra + 0.877*_intra_smallfirms
lincom _intra + 0.885*_intra_smallfirms
lincom _intra + 0.894*_intra_smallfirms

log close
