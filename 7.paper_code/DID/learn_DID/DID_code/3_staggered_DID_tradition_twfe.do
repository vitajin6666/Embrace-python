
* 具体论文中的操作详见：D:\python\learn_python\7.paper_code\DID\BBB\replication_thesis\dofile\6B_Figure3

use "D:\python\learn_python\7.paper_code\DID\learn_DID\DID_code\generate_data\staggered_data.dta" ,clear

gen treated = ( id<= 60)

set scheme s1mono // 可以设置全局画图风格
/*******************************************************普通双向固定效应(Two-Way Fixed Effects)的方法****************************************/

* i.D表明Stata 会将 D 转为哑变量，只有 0 和 1 两个取值。如果D已经是哑变量了，直接写D也可以

reg y i.D x1 x2 i.year_month i.id, vce(cluster id)
eststo reg

areg y i.D x1 x2 i.year_month, absorb(id) vce(cluster id)
eststo areg

xtset id year_month
xtreg y i.D x1 x2 i.year_month, fe vce(cluster id)
eststo xtreg_fe

reghdfe y i.D x1 x2, absorb(id year_month) vce(cluster id)
eststo reghdfe

* 对比查看(需要更改title和keep中的想要对比的变量)
//可estout, varlabels(_all)查看具体的变量名
estout *, title("The Comparison of Actual Parameter Values") ///
         cells(b(star fmt(%9.3f)) se(par)) ///
         stats(N N_g, fmt(%9.0f %9.0g) label(N Groups)) ///
         legend collabels(none) varlabels(_cons Constant) keep(x1 x2 1.D) // 结果中是系数和（标准误）

//可estout, varlabels(_all)查看具体的变量名



/*******************************************************TWFEDD与ESA结合（coefplot画图) ****************************************/

//- Standard DID 结合 ESA 方法所生成的时期虚拟变量是一种绝对的时间尺度，即观测政策在某个样本时期的效果
//- Time-varying DID 利用 ESA 方法所需要的是相对的时期，即观测政策效果在个体接受处理的前 N 期和后 N 期的变化。



/* 生成处置组的相对时间变量*/

* 方法1
* gen relative_time = year*12 + month - (2005*12+3)  if D == 1//(2005*12+3)表示2005年3月

*方法2：time和birth_date都是ym()时间变量
*gen relative_time = time-birth_date  if D == 1

/* 为对照组的相对时间赋值（没有实际意思的值，比如-100）*/
replace relative_time =  -100 if treated == 0 

/* 缩尾 */
gen event = relative_time
replace event = -17 if event <= -17 & event != -100 //对照组还是-100
replace event = 18 if event >= 18 & event != .


/*生成事件窗口期内的虚拟变量*/

tab event if treated == 1, gen(eventt) //处置组：在相对时间 k 对应的时间，eventt = 1，否则为0

foreach var of varlist eventt* {   //对照组所有的eventt均为0
    replace `var' = 0 if missing(`var')
}

/* 将事件发生前一期作为基准对照组（即去掉改期，避免多重共线性）在论文中最常见)*/
drop eventt17

/* 回归 */
reghdfe y eventt* x1 x2, absorb(id year_month) vce(cluster id)


/* 平行趋势检验 */
coefplot, ///
	keep(eventt*) /// 改成具体变量名
	vertical /// 不用改
	title("Parallel Trend Test") ytitle("Coef") xtitle("relative time") /// 按实际情况修改
	ylabel(-2(2)12,labsize(medsmall) format(%02.1f))  ///  可以先去掉改行，然后按照实际情况修改
	xlabel(1 "-17" 9 "-9" 17 "0" 26 "9"  35 "18", angle(280)) ///   1 "200301"代表第一个交互项标签为200301，""内可以写,相对时间如-2。注意：去掉了处置前一期之后，要特别算一下对应的时候到底是第几个交互项变量
	xline(17,lp(dash)) /// 标示事件发生的时间点（因为去掉了前一期，所以这里需要再具体的期数-1），以下5行不用改
	yline(0,lcolor(edkblue*0.8)) /// 加入 y=0 这条虚线
	levels(95) /// 设置置信区间的置信度
	addplot(line @b @at)        /// 绘制点成连线
    ciopts(lpattern(dash) recast(rcap) msize(medium))        /// 绘制置信区间的上下限为"竖线"样式
	msymbol(circle_hollow) ///plot空心格式
    scheme(s1mono)      // 一种具体的样式

///输出生成的图片，令格式为800*600
*graph export "article2_2.png",as(png) replace width(800) height(600)


/*******************************************************TWFEDD与ESA结合（eventdd方法) ****************************************/

* 上述方法首先得1.生成一系列政策实施前后的虚拟变量，然后2.将虚拟变量带入模型中重新回归，最后3.再用 coefplot 之类的命令绘图
* 这种做法存在一定劣势。首先，需要生成一长串的虚拟变量。其次，我们很难做一次就通过检验。需要不断的找规律，诸如调整分析窗口、替换参考系、增减控制变量等

* eventdd 命令有效解决了上述不足，即无需生成一系列虚拟变量，也无需再进行回归和绘图，而是将上述三个步骤融入一个命令，极大的提高了工作效率。该命令由 Damian Clarke 和 Kathya Tapia Schythe 在 2020 年共同开发
* 但是它没有内置选项对事前期数的回归系数做去均值化处理，如果需要就还是用coefplot方法吧


**************** 基础语法
// 1.ols 需要自己加入个体固定效应 和时间固定效应 
eventdd y x1 x2 i.year_month i.id , timevar(relative_time) method(, cluster(id)) graph_op(ytitle("ols"))
// fe 可以设置 method(fe)，仅需加入时间固定效应
eventdd y x1 x2 i.year_month ,timevar(relative_time) method(fe, cluster(id)) graph_op(ytitle("fe"))

// （推荐） hdfe 可以用 absorb(id year) 设定个体固定效应和时间固定效应（推荐）
eventdd y x1 x2, timevar(relative_time) method(hdfe, absorb(id year_month) cluster(id)) graph_op(ytitle("hdfe"))



**************** 继续调整事件分析窗口
// 1.不做缩尾处理
* inrange 是指将政策实施前后的所有期数带入回归，即政策实施前 41 期和实施后 42 期都被放入回归方程。但我们通过设定 leads(10) lags(10)，仅展示前后 10 期的结果
eventdd y x1 x2, timevar(relative_time)  ///
	method(hdfe, absorb(id year_month) cluster(id))  ///
	inrange leads(10) lags(10)  ///
	graph_op(ytitle("hdfe") ///
	graphregion(fcolor(white)))

* 以 0 期为基准：eventdd 默认使用政策发生前一期，即 -1 期作为基准组。我们也可以使用政策实施当期 (第 0 期) 作为基准组，引入 baseline(0) 即可,eventdd 会自动添加一条 x = -1 的参考线，当我们以第 0 期为基准时，我们得用 noline 取消掉这条线，并重新绘制一条 x = 0 的参考线
eventdd y x1 x2, timevar(relative_time) ///
	method(hdfe, absorb(id year_month) cluster(id))  ///
	inrange leads(10) lags(10) ///
	baseline(0) noline ///
	graph_op(ytitle("Suicides per 1m Women") ///
	xline(0, lc(black*0.5) lp(dash)) ///
	graphregion(fcolor(white))) 

// 2.缩尾处理
* 将inrange 换为accum(首尾两期是绿色的)
eventdd y x1 x2, timevar(relative_time)  ///
	method(hdfe, absorb(id year_month) cluster(id))  ///
	accum leads(10) lags(10)  ///
	graph_op(ytitle("hdfe") ///
	graphregion(fcolor(white)))
	
* 以 0 期为基准(noend用于去掉首尾期)
eventdd y x1 x2, timevar(relative_time) ///
	method(hdfe, absorb(id year_month) cluster(id))  ///
	accum leads(10) lags(10) ///
	baseline(0) noline noend ///
	graph_op(ytitle("Suicides per 1m Women") ///
	xline(0, lc(black*0.5) lp(dash)) ///
	graphregion(fcolor(white))) 

	
// （最好不要用) 3.保持期数平衡（缩尾+ 去掉不平衡数据）: 这种方法会损失大量样本
eventdd y x1 x2, timevar(relative_time)  ///
	method(hdfe, absorb(id year_month) cluster(id))  ///
	keepbal(id) leads(10) lags(10)  ///
	graph_op(ytitle("hdfe") ///
	graphregion(fcolor(white)))
	


**************** 完整回归+样式代码

* baseline = -1 标准样式	
eventdd y x1 x2, timevar(relative_time) ///
	method(hdfe, absorb(id year_month) cluster(id))  ///
	accum leads(10) lags(10) ///
	level(95) ci(rcap) ///  // 调整置信区间&图形类型, 默认rcap, 其余还有rarea (带区域阴影)，rline (带线条)
	endpoints_op(msymbol(oh) mcolor(black)) ///   // 调整首尾小点样式&颜色（需在accum下用）msymbol(O)代表实心，oh代表空心
	coef_op(msymbol(oh) c(l) color(black) lcolor(black)) ///  // 调整scatter样式，m(oh)点设为空心圆，c(l) 连线，color(black) 点颜色，lcolor(black)线颜色
	graph_op(ytitle("Y title") ///
		ylabel() ///   // 设置y轴展示刻度
		yline(0, lcolor(black)) /// 
		xtitle("X title") ///
		xlabel() ///   // 设置x轴展示刻度
		scheme(s1mono) ///
		graphregion(fcolor(white))) 
	 
* baseline = 0 标准样式
eventdd y x1 x2, timevar(relative_time) ///
	method(hdfe, absorb(id year_month) cluster(id))  ///
	accum leads(10) lags(10) ///
	baseline(0) noline ///
	level(95) ci(rcap) ///  // 调整置信区间&图形类型, 默认rcap, 其余还有rarea (带区域阴影)，rline (带线条)
	endpoints_op(msymbol(oh) mcolor(black)) ///   // 调整首尾小点样式&颜色（需在accum下用）msymbol(O)代表实心，oh代表空心
	coef_op(msymbol(oh) c(l) color(black) lcolor(black)) ///  // 调整scatter样式，m(oh)点设为空心圆，c(l) 连线，color(black) 点颜色，lcolor(black)线颜色
	graph_op(ytitle("Y title") ///
		ylabel() ///   // 设置y轴展示刻度
		yline(0, lcolor(black)) /// 
		xtitle("X title") ///
		xlabel() ///   // 设置x轴展示刻度
		xline(0, lc(black*0.5) lp(dash)) ///
		scheme(s1mono) ///
		graphregion(fcolor(white))) 

**************** 查看事前事后和总体效果
estat leads // 检验事前平行趋势，希望是事前检验不显著（p大），所有期数与零值无显著差异
estat lags // 事后检验 ,希望是事后高度显著，所有期数显著异于零
estat eventdd // 总体检验，将事前事后结果一起输出(希望 LEADS 不显著， LAGS 显著)














