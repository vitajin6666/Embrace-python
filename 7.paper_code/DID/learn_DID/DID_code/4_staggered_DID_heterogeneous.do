/*==================================================
project:       
Author:        Vita Jin 
E-email:       vitajin101@gmail.com         
==================================================*/



/*==================================================
              0: open dataset
==================================================*/
use "D:\python\learn_python\7.paper_code\DID\learn_DID\DID_code\generate_data\staggered_heterogeneous.dta" ,clear

/*==================================================
              0.5: Goodman-Bacon (2021) : bacondecomp
			  它用于诊断传统双向固定效应模型（TWFE）的潜在问题（尤其是异质性处理效应和负权重问题）
			  如果发现确实有问题，需要用如下方法
==================================================*/
*----------命令
bacondecomp Y D, ddetail stub(Bacon_) robust

* stub(Bacon_)：指定分解结果存储时的变量名前缀

*----------结果解读：
* D 的系数是总体 DID 估计值

* Bacon Decomposition
	* 输出分成三种类型的 2x2 比较：包括处理组组间比较（Early_v_Late，Late_v_Early），处理组和对照组比较 Never_v_timing
	* 每一对处置组之间会生成一个比较组合（Early_v_Late & Late_v_Early）
	* 我的数据中是有6组处置组，所以有15种可能得配对 n(n-1)/2。所以共有15个比较组合（Early_v_Late & Late_v_Early）
	

	* 对应于 bacon论文中的图的理解：
	* 图1&图2：处理组 vs 未处理组（Never_v_timing ）：处理效应为 .8961447696，权重为  .3904330151 
	* 图3：Early_v_Late
	* 图4：Late_v_Early
	* TWFE 的总体估计值 =  ∑ Beta * TotalWeight
	
	
* 散点图
	* "Timing Groups"：处理组间的比较（Early_v_Late 和 Late_v_Early）：如果 "Timing Groups" 的点分布广泛（Beta 值差异大，如从负到正），说明处理效应在不同时间处理的组之间存在显著异质性。这可能是 TWFE 模型偏误的来源。
	* Never Treated vs Timing：处理组与未处理组的比较
	* Within：组内比较（处理组自身前后变化，或控制固定效应后的残差）


*----------结果解读：重点关注的点：
* 1.观察 TotalWeight 列有无负值，若发现负权重，则有问题
* 2.观察Beta的范围和方向，如 -2.76 到 +1.59，方向不一且差异大，说明处理效应存在显著异质性，有问题（可以直接在散点图里看)
	
/*==================================================
              1: Callaway and Sant'Anna (2021) ——csdid
==================================================*/

* 生成日期变量，从未受处理的组取值为 0
gen gvar = cond(treat_time>15, 0, treat_time) // 相当于就是处理的年份

*----------命令
csdid Y, ivar(id) time(t) gvar(gvar) agg(event) method() cluster

est store csdid_result

* agg(): 包括(simple)(group)(calendar)(event)

/* method():
	drimp（Doubly Robust Improved）: 默认
	reg 为普通最小二乘法
	ipw (Inverse Probability Weighting) 为逆概率加权法
	dripw (Doubly Robust Inverse Probability Weighting)为基于逆概率的普通最小二乘法得到的双重稳健 DID 估计量
	stdipw (Standardized Inverse Probability Weighting) 为标准化的逆概率加权法*/

* 默认使用不处理组做对照组，需要要用尚未处理组做对照组加：notyet

* 默认情形是计算稳健标准误。添加 wboot 选项，可用 WildBootstrap 方法计算标准误；添加 cluster 选项，可计算聚类标准误。

*----------平行趋势检验
estat pretrend // 期望 P>0.05,说明不显著区别于0

*----------绘图

* 方法1：简便，但是不好更改样式
csdid_plot,  ///
	title("Event Study Plot") ///
	xtitle("Periods Relative to Treatment") ///
	ytitle("Effect") 
	
* 方法2：
event_plot csdid_result, default_look ///
	stub_lag(Tp#) stub_lead(Tm#)  ///     
    plottype(connected) ciplottype(rcap) together /// // 想去掉连线就改成 plottype(scatter)
	graph_opt(  ///
        title("Callaway and Sant'Anna (2021)")  ///
		xtitle("Periods since the event") ///
		ytitle("Average causal effect") ///
        xlabel(-13(1)5) ///
        yline(0, lcolor(black))) 


*----------结果解读：
* 1. 整体行为效果计算 
estat simple // 处理行为发生之后的所有小模块的加权平均数

* 2.不同时期的处理行为效果
estat calendar // 日历时期(多期DID中感觉没啥用)

estat event // 事件时期

* 3.不同组别的处理行为效果
estat group


/*==================================================
              2: stata官方命令：xthdidregress
==================================================*/

*----------命令
xtset id t
xthdidregress aipw (Y) (D), group(id) vce(cluster id) controlgroup() 

* 估计量方式可选择以下四种：ra(Regression Adjustment)，ipw(Inverse Probability Weigthing)，aipw（Augmented Inverse Probability Weighting），twfe(TWFE by Wooldridge (2021))
* 推荐优先使用 AIPW，因为它的双重稳健的特性，而当在权重估计值中出现极端值时，我们再考虑使用 RA 
/* 加入控制变量的方式：(x或z是协变量)
	
	xthdidregress ra (y x) (treat), group(grpvar)
	
	xthdidregress ipw (y) (treat z), group(grpvar)
	
	xthdidregress aipw (y x) (treat z), group(grpvar)
	
	xthdidregress twfe (y x) (treat), group(grpvar)*/

* controlgroup(string): 可选，指定控制组类型：never（从未治疗的单位，默认值）; notyet（尚未治疗的单位）

*----------常规绘图

* 每一个组一个图
estat atetplot, sci


* cohort翻译为队列（就是不同处理组）
estat aggregation, cohort graph

* 日历时间（一般不用这个）
estat aggregation, time graph

* event 
estat aggregation, dynamic graph

*----------eventbaseline绘图

* eventbaseline 是通过 xthdidregress（双重差分方法的一种扩展）生成的系数，使其能够生成相对基准期的事件研究图，所以需要先run xthdidregress

eventbaseline, pre(14) post(5) baseline(-1) graph
* baseline()没法设置为当期0，这点不太灵活



/*==================================================
              3: Sun and Abraham (2021) : eventstudyinteract
==================================================*/

*----------命令

* 生成从未受处理组的虚拟变量
gen lastcohort = treat_time ==r(max)

* 生成各期处理组的虚拟变量
forvalues l = 0/5 {
	gen L`l'event = relative_time ==`l'
}

forvalues l = 1/14 {
	gen F`l'event = relative_time == -`l'
}

drop F1event // 去掉事件前一期，防止共线性

eventstudyinteract Y L*event F*event, vce(cluster id) absorb(id t) cohort(treat_time) control_cohort(lastcohort)  

* control_cohort(): 指定控制组为从未处理过的个体

est store eventstudyinteract_result

*----------结果解读：
* L*event: 处置后动态结果
* F*event：处置前，以验证平行趋势

*----------绘图：

event_plot e(b_iw)#e(V_iw), default_look ///
	stub_lag(L#event) stub_lead(F#event)  ///     
    plottype(connected) ciplottype(rcap) together /// // 想去掉连线就改成 plottype(scatter)
	graph_opt(  ///
        title("Sun and Abraham (2020)")  ///
		xtitle("Periods since the event") ///
		ytitle("Average causal effect") ///
        xlabel(-14(1)5) ///
        yline(0, lcolor(black))) 

/*==================================================
              4: Chaisemartin 和 d'Haultfoeuille (2020)：did_multiplegt
==================================================*/
* did_multiplegt 现在是一个库，意味着它是一个统一的接口，封装了多个 DID 估计器。
* 新语法 did_multiplegt (mode) varlist(Y id T D) [, options] 让你通过指定 mode 调用不同功能的子命令（dyn、stat、had 或 old）
/* 
	dyn（用这个）: 调用 did_multiplegt_dyn，用于动态事件研究（event-study）估计。（基于 de Chaisemartin 和 D'Haultfoeuille 2024a）
	stat: 调用 did_multiplegt_stat，用于静态 DID 估计。（基于 de Chaisemartin 和 D'Haultfoeuille 2020, 2022）
	had: 调用 did_had，用于异质性采纳设计（Heterogeneous Adoption Designs）。（基于 de Chaisemartin 和 D'Haultfoeuille 2024b）。
	old（作者不推荐）: 调用 did_multiplegt_old，即旧版本的 did_multipleg （基于 de Chaisemartin 和 D'Haultfoeuille 2020）。 */

*----------命令
did_multiplegt (dyn) Y id t D, effects(5) placebo(5) cluster(id)

* placebo(5):指定估计治疗前的安慰剂效应（placebo effects），这些效应用于检验平行趋势假设（parallel trends）和无提前效应假设（no anticipation）。
	* The number of placebo requested cannot be larger than the number of effects requested. 

*----------结果解读

* 第一个表：治疗后的事件研究动态效应(需要显著)
* 中间的表：每个治疗单位的平均总效应是 0.848，且效应通常在治疗后约 2.44 个时间段内累积。
* 第三个表：这是治疗前的安慰剂效应，用于检验平行趋势（parallel trends）和无提前效应（no anticipation）假设。(需要不显著)

*----------绘图（其实did_multiplegt一跑出来就自带图了）

event_plot e(estimates)#e(variances), default_look ///
	stub_lag(Effect_#) stub_lead(Placebo_#)  ///     
    plottype(connected) ciplottype(rcap) together /// // 想去掉连线就改成 plottype(scatter)
	graph_opt(  ///
        title("de Chaisemartin and D'Haultfoeuille (2020)")  ///
		xtitle("Periods since the event") ///
		ytitle("Average causal effect") ///
        xlabel(-5(1)5) ///
        yline(0, lcolor(black))) 

		
/*==================================================
              5: Borusyak 等 (2021) did_imputation
==================================================*/
*----------命令
did_imputation Y id t treat_time, allhorizons pretrend(5)

*  Y 为结果变量，id 是观测的唯一识别符，t 为时期，treat_time为个体接受处理的时间 (缺失值则代表从未处理组)
* allhorizons：选项，表示估计所有时间范围内的动态效应，包括事件发生后的所有 lags（事后效应）和 leads（事前效应）。
* pretrend(5)：选项，表示在事件发生前估计 5 个事前期的效应（pre-treatment trends），用于检验平行趋势假设。

*----------结果解读：
* tau0 到 tau5：事件发生时及之后的效应（lags），希望 p 值显著，如果数值不同则表现为异质性处理效应
* pre1 到 pre5：事件发生前的效应（leads），希望 p 值均不显著，以满足平行趋势假设

*----------绘图
event_plot, default_look ///
	graph_opt(xtitle("Periods since the event") ///
		xlabel(-5(1)5) /// 
		ytitle("Average causal effect") ///
		title("Borusyak et al. (2021) imputation estimator"))
















