**********************************************************************************************************************************
*** Date:    December 2009
*** Authors: Beck, Levine, and Levkov
*** Purpose: Create Figure 3 in "Big Bad Banks? The Winners and Losers from Bank Deregulation in the United States"
*** Note:    Please change the working directories below 
**********************************************************************************************************************************



clear
set mem 100m
set more off

cd "D:\python\learn_python\7.paper_code\DID\BBB\replication_thesis"

log using Figure3.log, replace

use "D:\python\learn_python\7.paper_code\DID\BBB\replication_thesis\data\macro_workfile.dta" , clear

generate y=log(gini)

xtset statefip wrkyr

bacondecomp y _intra, robust // 没法用ddetail方法，会报错。感觉异质性还是存在的

**********************************eventdd代码（最简单，但是没法对事前期数系数做去均值化处理）

generate _tintra = wrkyr - branch_reform

eventdd y , timevar(_tintra) ///
	method(hdfe, absorb(statefip wrkyr) cluster(statefip))  ///
	accum leads(10) lags(15) ///
	baseline(0) noline ///
	level(95) ci(rcap) ///  // 调整置信区间&图形类型, 默认rcap, 其余还有rarea (带区域阴影)，rline (带线条)
	endpoints_op(msymbol(oh) mcolor(black)) ///   // 调整首尾小点样式&颜色（需在accum下用）msymbol(O)代表实心，oh代表空心
	coef_op(msymbol(oh) c(l) color(black) lcolor(black)) ///  // 调整scatter样式，m(oh)点设为空心圆，c(l) 连线，color(black) 点颜色，lcolor(black)线颜色
	graph_op(ytitle("Y title") ///
		ylabel(-0.06(0.02)0.06) ///   // 设置y轴展示刻度
		yline(0, lcolor(black)) /// 
		xtitle("X title") ///
		xlabel() ///   // 设置x轴展示刻度
		xline(0, lc(black*0.5) lp(dash)) ///
		scheme(s1mono) ///
		graphregion(fcolor(white))) 

estat eventdd // 总体检验，将事前事后结果一起输出(希望 LEADS 不显著， LAGS 显著)

**********************************1.coefplot代码，可以对事前期数做去均值化处理，baseline=0

gen event = wrkyr - branch_reform

replace event  = -10 if event <= -10
replace event = 15 if event >= 15

///tab event, gen(eventt)
gen event1 = event + 10

xtset statefip wrkyr
xtreg y ib10.event1 i.wrkyr, fe vce(cluster statefip) // 因为是从0开始数的，所以要去掉第10个表示相对时间0

* 多期 DID 通常需要选择一个基准期（reference period）来比较处理前后的效应。这里用处理前 10 年的平均效应作为基准（x），而不是单一时间点（如 -1）
* 后续减去 x 是为了将所有时间点的系数标准化为相对于处理前均值的变化.减去前十期均值后，所有系数被调整为相对于处理前均值的偏差，图表的纵轴基准线变为零
* 这个变换是线性平移（subtracting a constant），不会影响系数之间的差异或显著性。它只是调整了图表的"视角"，而非数据的实质内容,所以仍然可以检验平行趋势假设


///生成前十期系数均值x
forvalues i = 0/9{
    gen b_`i' = _b[`i'.event1]

}

gen avg_coef = (b_0+b_9+b_8+b_7+b_6+b_5+b_4+b_3+b_2+b_1)/10
su avg_coef 
return list

coefplot, baselevels ///
   drop(_cons event1  *.wrkyr ) ///
   if(@at!=11) ///去除当年的系数点
   coeflabels(0.event1 = "-10"   ///
   1.event1 = "-9"           ///
   2.event1 = "-8"           ///
   3.event1 = "-7"           ///
   4.event1  = "-6"             ///
   5.event1  = "-5"              ///
   6.event1  = "-4"              ///
   7.event1  = "-3"       ///
   8.event1  = "-2" ///
   9.event1  = "-1" ///
   10.event1 = "0" ///
   11.event1  = "1" ///
   12.event1 = "2" ///
   13.event1  = "3" ///
   14.event1  = "4" ///
   15.event1  = "5" ///
   16.event1  = "6" ///
   17.event1  = "7" ///
   18.event1  = "8" ///
   19.event1 = "9" ///
   20.event1  = "10" ///
   21.event1  = "11" ///
   22.event1 = "12" ///
   23.event1  = "13" ///
   24.event1 = "14" ///
   25.event1 = "15")  ///更改系数的label
   vertical                             ///转置图形
   yline(0, lwidth(vthin) lpattern(dash) lcolor(teal)) ///加入y=0这条虚线
   ylabel(-0.06(0.02)0.06) ///
   xline(11, lwidth(vthin) lpattern(dash) lcolor(teal)) ///
   ytitle("Percentage Changes", size(small)) ///加入Y轴标题,大小small
   xtitle("Years relative to branch deregulation", size(small)) ///加入X轴标题，大小small
   transform(*=@-r(mean)) ///去除前十期的系数均值，更好看
   addplot(line @b @at  if @at < 11, lcolor(gs0)  || line @b @at if @at>11, lcolor(gs0) lwidth(thin))   ///增加点之间的连线
   ciopts(lpattern(dash) recast(rcap) msize(medium))  ///CI为虚线上下封口
   msymbol(circle_hollow) ///plot空心格式
   scheme(s1mono)

   
   
   
**********************************2.coefplot代码，可以对事前期数做去均值化处理，baseline = -1

generate _tintra = wrkyr - branch_reform

replace _tintra = -10 if _tintra <-10
replace _tintra =  15 if _tintra > 15

tab _tintra, missing

tab _tintra, gen(_tintradd)
drop _tintradd11 // 去掉前一期

xtset statefip wrkyr

xtreg y  _tintradd* i.wrkyr, fe vce(cluster statefip)

///生成前十期系数均值x
forvalues i = 1/10{
    gen b_`i' = _b[_tintradd`i']

}

gen avg_coef = (b_10+b_9+b_8+b_7+b_6+b_5+b_4+b_3+b_2+b_1)/10
su avg_coef 
return list


coefplot, ///
	keep(_tintradd*) ///
	vertical ///
    ytitle("Percentage Changes", size(small)) ///加入Y轴标题,大小small
    xtitle("Years relative to branch deregulation", size(small)) ///加入X轴标题，大小small
	ylabel(-0.06(0.02)0.04 , labsize(small)) ///
	xlabel(1 "-10" 6 "-5" 11 "1" 15 "5"  20 "10" 25 "15") ///
	yline(0, lwidth(vthin) lpattern(dash) lcolor(teal)) ///加入y=0这条虚线
	xline(11, lwidth(vthin) lpattern(dash) lcolor(teal)) ///
    addplot(line @b @at  if @at < 11, lcolor(gs0)  || line @b @at if @at>=11, lcolor(gs0) lwidth(thin))   ///增加点之间的连线
    ciopts(lpattern(dash) recast(rcap) msize(medium))  ///CI为虚线上下封口
    msymbol(circle_hollow) ///plot空心格式
	transform(*=@-r(mean)) ///去除前十期的系数均值，更好看
    scheme(s1mono)
   
**********************************3.原论文代码（twoway方式）
generate y=log(gini)

generate _tintra = wrkyr - branch_reform

replace _tintra = -10 if _tintra <-10
replace _tintra =  15 if _tintra > 15

generate d_10 = 0 
replace d_10 = 1 if _tintra == -10
generate d_9  = 0 
replace d_9  = 1 if _tintra == -9
generate d_8  = 0 
replace d_8  = 1 if _tintra == -8
generate d_7  = 0 
replace d_7  = 1 if _tintra == -7
generate d_6  = 0 
replace d_6  = 1 if _tintra == -6
generate d_5  = 0 
replace d_5  = 1 if _tintra == -5
generate d_4  = 0 
replace d_4  = 1 if _tintra == -4
generate d_3  = 0 
replace d_3  = 1 if _tintra == -3
generate d_2  = 0 
replace d_2  = 1 if _tintra == -2
generate d_1  = 0 
replace d_1  = 1 if _tintra == -1

generate d1  = 0 
replace d1  = 1 if _tintra == 1
generate d2  = 0 
replace d2  = 1 if _tintra == 2
generate d3  = 0 
replace d3  = 1 if _tintra == 3
generate d4  = 0 
replace d4  = 1 if _tintra == 4
generate d5  = 0 
replace d5  = 1 if _tintra == 5
generate d6  = 0 
replace d6  = 1 if _tintra == 6
generate d7  = 0 
replace d7  = 1 if _tintra == 7
generate d8  = 0 
replace d8  = 1 if _tintra == 8
generate d9  = 0 
replace d9  = 1 if _tintra == 9
generate d10 = 0 
replace d10 = 1 if _tintra == 10
generate d11 = 0 
replace d11 = 1 if _tintra == 11
generate d12 = 0 
replace d12 = 1 if _tintra == 12
generate d13 = 0 
replace d13 = 1 if _tintra == 13
generate d14 = 0 
replace d14 = 1 if _tintra == 14
generate d15 = 0 
replace d15 = 1 if _tintra == 15

xtset statefip wrkyr

xtreg y d_10-d15  i.wrkyr, fe vce(cluster statefip)

generate t5 = invttail(48,0.025) // 计算 t 分布的临界值（critical value），具体是双尾检验下 95% 置信水平的 t 值，自由度为 48

generate b_10 = _b[d_10] 
generate se_b_10 = _se[d_10]
generate b_10LB = b_10 - t5*se_b_10 // 计算95% 置信区间的下限（lower bound）
generate b_10UB = b_10 + t5*se_b_10 // 计算95% 置信区间的上限（upper bound）

generate b_9 = _b[d_9] 
generate se_b_9 = _se[d_9]
generate b_9LB = b_9 - t5*se_b_9
generate b_9UB = b_9 + t5*se_b_9

generate b_8 = _b[d_8] 
generate se_b_8 = _se[d_8]
generate b_8LB = b_8 - t5*se_b_8
generate b_8UB = b_8 + t5*se_b_8

generate b_7 = _b[d_7] 
generate se_b_7 = _se[d_7]
generate b_7LB = b_7 - t5*se_b_7
generate b_7UB = b_7 + t5*se_b_7

generate b_6 = _b[d_6] 
generate se_b_6 = _se[d_6]
generate b_6LB = b_6 - t5*se_b_6
generate b_6UB = b_6 + t5*se_b_6

generate b_5 = _b[d_5] 
generate se_b_5 = _se[d_5]
generate b_5LB = b_5 - t5*se_b_5
generate b_5UB = b_5 + t5*se_b_5

generate b_4 = _b[d_4] 
generate se_b_4 = _se[d_4]
generate b_4LB = b_4 - t5*se_b_4
generate b_4UB = b_4 + t5*se_b_4

generate b_3 = _b[d_3] 
generate se_b_3 = _se[d_3]
generate b_3LB = b_3 - t5*se_b_3
generate b_3UB = b_3 + t5*se_b_3

generate b_2 = _b[d_2] 
generate se_b_2 = _se[d_2]
generate b_2LB = b_2 - t5*se_b_2
generate b_2UB = b_2 + t5*se_b_2

generate b_1 = _b[d_1] 
generate se_b_1 = _se[d_1]
generate b_1LB = b_1 - t5*se_b_1
generate b_1UB = b_1 + t5*se_b_1

generate b1 = _b[d1] 
generate se_b1 = _se[d1]
generate b1LB = b1 - t5*se_b1
generate b1UB = b1 + t5*se_b1

generate b2 = _b[d2] 
generate se_b2 = _se[d2]
generate b2LB = b2 - t5*se_b2
generate b2UB = b2 + t5*se_b2

generate b3 = _b[d3] 
generate se_b3 = _se[d3]
generate b3LB = b3 - t5*se_b3
generate b3UB = b3 + t5*se_b3

generate b4 = _b[d4] 
generate se_b4 = _se[d4]
generate b4LB = b4 - t5*se_b4
generate b4UB = b4 + t5*se_b4

generate b5 = _b[d5] 
generate se_b5 = _se[d5]
generate b5LB = b5 - t5*se_b5
generate b5UB = b5 + t5*se_b5

generate b6 = _b[d6] 
generate se_b6 = _se[d6]
generate b6LB = b6 - t5*se_b6
generate b6UB = b6 + t5*se_b6

generate b7 = _b[d7] 
generate se_b7 = _se[d7]
generate b7LB = b7 - t5*se_b7
generate b7UB = b7 + t5*se_b7

generate b8 = _b[d8] 
generate se_b8 = _se[d8]
generate b8LB = b8 - t5*se_b8
generate b8UB = b8 + t5*se_b8

generate b9 = _b[d9] 
generate se_b9 = _se[d9]
generate b9LB = b9 - t5*se_b9
generate b9UB = b9 + t5*se_b9

generate b10 = _b[d10] 
generate se_b10 = _se[d10]
generate b10LB = b10 - t5*se_b10
generate b10UB = b10 + t5*se_b10

generate b11 = _b[d11] 
generate se_b11 = _se[d11]
generate b11LB = b11 - t5*se_b11
generate b11UB = b11 + t5*se_b11

generate b12 = _b[d12] 
generate se_b12 = _se[d12]
generate b12LB = b12 - t5*se_b12
generate b12UB = b12 + t5*se_b12

generate b13 = _b[d13] 
generate se_b13 = _se[d13]
generate b13LB = b13 - t5*se_b13
generate b13UB = b13 + t5*se_b13

generate b14 = _b[d14] 
generate se_b14 = _se[d14]
generate b14LB = b14 - t5*se_b14
generate b14UB = b14 + t5*se_b14

generate b15 = _b[d15] 
generate se_b15 = _se[d15]
generate b15LB = b15 - t5*se_b15
generate b15UB = b15 + t5*se_b15



generate b = .
generate LB = .
generate UB = .

replace b = b_10  if _tintra == -10
replace b = b_9  if _tintra == -9
replace b = b_8  if _tintra == -8
replace b = b_7  if _tintra == -7
replace b = b_6  if _tintra == -6
replace b = b_5  if _tintra == -5
replace b = b_4  if _tintra == -4
replace b = b_3  if _tintra == -3
replace b = b_2  if _tintra == -2
replace b = b_1  if _tintra == -1
replace b = b1   if _tintra == 1
replace b = b2   if _tintra == 2
replace b = b3   if _tintra == 3
replace b = b4   if _tintra == 4
replace b = b5   if _tintra == 5
replace b = b6   if _tintra == 6
replace b = b7   if _tintra == 7
replace b = b8   if _tintra == 8
replace b = b9   if _tintra == 9
replace b = b10  if _tintra == 10
replace b = b11  if _tintra == 11
replace b = b12  if _tintra == 12
replace b = b13  if _tintra == 13
replace b = b14  if _tintra == 14
replace b = b15  if _tintra == 15

replace LB = b_10LB if _tintra == -10
replace LB = b_9LB if _tintra == -9
replace LB = b_8LB if _tintra == -8
replace LB = b_7LB if _tintra == -7
replace LB = b_6LB if _tintra == -6
replace LB = b_5LB if _tintra == -5
replace LB = b_4LB if _tintra == -4
replace LB = b_3LB if _tintra == -3
replace LB = b_2LB if _tintra == -2
replace LB = b_1LB if _tintra == -1
replace LB = b1LB  if _tintra == 1
replace LB = b2LB  if _tintra == 2
replace LB = b3LB  if _tintra == 3
replace LB = b4LB  if _tintra == 4
replace LB = b5LB  if _tintra == 5
replace LB = b6LB  if _tintra == 6
replace LB = b7LB  if _tintra == 7
replace LB = b8LB  if _tintra == 8
replace LB = b9LB  if _tintra == 9
replace LB = b10LB  if _tintra == 10
replace LB = b11LB  if _tintra == 11
replace LB = b12LB  if _tintra == 12
replace LB = b13LB  if _tintra == 13
replace LB = b14LB  if _tintra == 14
replace LB = b15LB  if _tintra == 15

replace UB = b_10UB if _tintra == -10
replace UB = b_9UB if _tintra == -9
replace UB = b_8UB if _tintra == -8
replace UB = b_7UB if _tintra == -7
replace UB = b_6UB if _tintra == -6
replace UB = b_5UB if _tintra == -5
replace UB = b_4UB if _tintra == -4
replace UB = b_3UB if _tintra == -3
replace UB = b_2UB if _tintra == -2
replace UB = b_1UB if _tintra == -1
replace UB = b1UB  if _tintra == 1
replace UB = b2UB  if _tintra == 2
replace UB = b3UB  if _tintra == 3
replace UB = b4UB  if _tintra == 4
replace UB = b5UB  if _tintra == 5
replace UB = b6UB  if _tintra == 6
replace UB = b7UB  if _tintra == 7
replace UB = b8UB  if _tintra == 8
replace UB = b9UB  if _tintra == 9
replace UB = b10UB if _tintra == 10
replace UB = b11UB if _tintra == 11
replace UB = b12UB if _tintra == 12
replace UB = b13UB if _tintra == 13
replace UB = b14UB if _tintra == 14
replace UB = b15UB if _tintra == 15

* 多期 DID 通常需要选择一个基准期（reference period）来比较处理前后的效应。这里用处理前 10 年的平均效应作为基准（x），而不是单一时间点（如 -1）
generate x=(b_10+b_9+b_8+b_7+b_6+b_5+b_4+b_3+b_2+b_1)/10

* 后续减去 x 是为了将所有时间点的系数标准化为相对于处理前均值的变化
replace b=b-x
replace LB=LB-x
replace UB=UB-x

keep _tintra b LB UB
duplicates drop

sort _tintra

twoway (connected b _tintra, sort lcolor(navy) mcolor(navy) msymbol(circle_hollow) cmissing(n)) ///
       (rcap LB UB _tintra, lcolor(navy) lpattern(dash) msize(medium)), ///
       ytitle(Percentage change) ytitle(, size(small)) ///
       yline(0, lwidth(vthin) lpattern(dash) lcolor(teal)) ylabel(, labsize(small) angle(horizontal) nogrid) ///
       xtitle(Years relative to branch deregulation) xtitle(, size(small)) ///
       xline(0, lwidth(vthin) lpattern(dash) lcolor(teal)) xlabel(-10(5)15, labsize(small)) xmtick(-10(1)15, nolabels ticks) ///
       legend(off) ///
       graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white))

graph save Figure3, asis replace


   
   
log close

