//与Event Study Approach（事件研究法） 的结合DID 详解：https://www.lianxh.cn/news/73a938e236d82.html
//Stata：一文读懂事件研究法Event Study: https://www.lianxh.cn/details/678.html

use "D:\python\learn_python\7.paper_code\DID\learn_DID\standard_DID\DID_basic_data.dta" ,clear

// gen year_month = year*100+month 生成数值型year_month
// destring year_month, replace 将字符串形式转换成字符型

// gen event_time = year*12 + month - (2005*12+3) //构造相对时间变量,(2005*12+3)表示处置时间2005年3月

/*************************Standard DID 和 Event Study Approach（事件研究法） 的结合（将时间展开，查看每一期的效应）****************************************/


* 方法1：交互项变成：i.D##i.year_month（注意不是i.post了）
* 不推荐，不方便画平行趋势检验图，也不能控制去掉哪一个时间

// 这种方法会自动构造随时间展开的交乘项，并且会自动去掉第一个year_month值
reg y i.D##i.year_month x1 x2 i.id i.year_month,vce(cluster id) 
eststo reg_ESA   

areg y i.D##i.year_month x1 x2 i.year_month, absorb(id) vce(cluster id) 
eststo areg_ESA  

xtset id year_month
xtreg y i.D##i.year_month x1 x2 i.year_month, fe vce(cluster id) 
eststo xtreg_ESA  

reghdfe y i.D##i.year_month x1 x2, absorb(id year_month) vce(cluster id) 
eststo reghdfe_ESA   

* 对比查看(需要更改title和keep中的想要对比的变量)
//可estout, varlabels(_all)查看具体的变量名
estout *, title("The Comparison of Actual Parameter Values") ///
         cells(b(star fmt(%9.3f)) se(par)) ///
         stats(N N_g, fmt(%9.0f %9.0g) label(N Groups)) ///
         legend collabels(none) varlabels(_cons Constant) keep(1.D#200302.year_month 1.D#200502.year_month 1.D#200503.year_month 1.D#200504.year_month 1.D#200609.year_month) // 结果中是系数和（标准误）

		 
* （推荐，更灵活，也方便画平行趋势检验图）方法2：手动构造time dummy variables

//预先生成年度虚拟变量
tab year_month, gen(dym_) 

// 生成所有交乘项
foreach m of numlist 1/60 {
    gen inter_`m' = D * dym_`m'
}

//论文中常用的一般是去掉政策实施的前一期(推荐）或当期作为基准参照组。
//这里去掉了inter_26(即处置前一期，避免多重共线性)
reghdfe y inter_1 inter_2 inter_3 inter_4 inter_5 inter_6 inter_7 inter_8 inter_9 inter_10 inter_11 inter_12 inter_13 inter_14 inter_15 inter_16 inter_17 inter_18 inter_19 inter_20 inter_21 inter_22 inter_23 inter_24 inter_25 inter_27 inter_28 inter_29 inter_30 inter_31 inter_32 inter_33 inter_34 inter_35 inter_36 inter_37 inter_38 inter_39 inter_40 inter_41 inter_42 inter_43 inter_44 inter_45 inter_46 inter_47 inter_48 inter_49 inter_50 inter_51 inter_52 inter_53 inter_54 inter_55 inter_56 inter_57 inter_58 inter_59 inter_60 x1 x2, absorb(id year_month) vce(cluster id) 
		 
/*******************************************************平行趋势检验****************************************/

/// 方法1：coefplot 命令实现，手动计算各时期虚拟变量，coefplot 辅助作图
// https://repec.sowi.unibe.ch/stata/coefplot/labelling.html

coefplot, ///
	keep(inter*) /// 改成具体变量名
	vertical /// 不用改
	title("Parallel Trend Test") ytitle("Coef") xtitle("year_month") /// 按实际情况修改
	ylabel(-10(10)50,labsize(medsmall) format(%02.1f))  ///  可以先去掉改行，然后按照实际情况修改
	xlabel(1 "200301" 13 "200401" 25 "-2" 37 "200601" 49 "200701" 60 "200712", angle(280)) ///  ""内可以写具体时间如200501，也可以写相对时间如-2
	xline(26,lp(dash)) /// 标示事件发生的时间点（因为去掉了前一期，所以这里需要再具体的期数-1），以下5行不用改
	yline(0,lcolor(edkblue*0.8)) /// 加入 y=0 这条虚线
	levels(95) /// 设置置信区间的置信度
	addplot(line @b @at)        /// 绘制点成连线
    ciopts(recast(rcap))        /// 绘制置信区间的上下限为"竖线"样式
    scheme(s1mono)      // 一种具体的样式，不用改

/// 方法2： eventdd 命令实现
// https://www.lianxh.cn/details/1201.html
// https://www.lianxh.cn/details/927.html
	
/// 方法2： tvdiff 命令实现(多期DID)
// https://www.lianxh.cn/news/439e934fd68c9.html





	
	
	
. * 代码一
xtset id year_month

gen event = year - branch_reform if group==1
. replace event = -4 if event <= -4
. tab event, gen(eventt)
. forvalues i = 1/15{
  2.     replace eventt`i' = 0 if eventt`i' == .
  3. }
. drop eventt1
xtreg y 交乘项 x1 x2 i.year_month, fe vce(cluster id) 


coefplot, 
	keep(eventt2 eventt3 eventt4 eventt5 eventt6 eventt7 eventt8 eventt9 eventt10 eventt11 eventt12  eventt13) 
	coeflabels(eventt2 = "-3" eventt3 = "-2"    ///
>     eventt4 = "-1" eventt5 = "0" eventt6  = "1" eventt7  = "2" eventt8  = "3"         ///
>     eventt9 = "4" eventt10 = "5" eventt11  = "6" eventt12  = "7" eventt13 = "8")      ///
>     vertical yline(0) ytitle("coef")                                                  ///
>     xtitle("time passage relative to year of adoption of implied contract exception") ///
>     addplot(line @b @at) ciopts(recast(rcap)) scheme(s1mono)
. graph export "article3_3.png",as(png) replace width(800) height(600)	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
		 
coefplot, keep(1.D#i.year_month) vertical ///
    yline(0, lp(dash)) ytitle("Treatment Effect") ///
    xtitle("Event Time (Relative to Treatment)") scheme(s1mono)	 
	 
coefplot, keep(_cons x1 x2) vertical yline(0, lp(dash)) ytitle("Treatment Effect") xtitle("Event Time (Relative to Treatment)") scheme(s1mono)
	 
		 





	
