use "D:\python\learn_python\7.paper_code\DID\learn_DID\standard_DID\DID_basic_data.dta" 

//reg,areg,xtreg语法：https://www.lianxh.cn/news/f7499048842cc.html

//reghdfe语法：https://mp.weixin.qq.com/s?__biz=Mzk0MDI1NTgyOQ==&mid=2247499262&idx=1&sn=0dde23f5d4b4bd9c5fa21644abbb98f1&source=41#wechat_redirect

//standard DID详解：https://www.lianxh.cn/news/73a938e236d82.html



/*************************************Standard DID（只区分"政策前" vs. "政策后",无法刻画政策效应的时间变化趋势）*************************************/

/// 不推荐：不加入固定效应(不加固定效应的话就用reg语法就好了)

* 方法1（推荐）
reg y i.D##i.post x1 x2, vce(cluster id)  // i.D##i.post 可以代替 D post interaction_term三项

* 方法2
gen interaction_term = D * post
reg y D post interaction_term x1 x2, vce(cluster id)

/// 推荐：加入固定效应

* 四种语法
reg y i.D##i.post x1 x2 i.id i.year_month,vce(cluster id) 
eststo reg   // 将结果保存为reg

areg y i.D##i.post x1 x2 i.year_month, absorb(id) vce(cluster id) 
eststo areg   // 将结果保存为areg

xtset id year_month
xtreg y i.D##i.post x1 x2 i.year_month, fe vce(cluster id) 
eststo xtreg   // 将结果保存为xtreg

reghdfe y i.D##i.post x1 x2, absorb(id year_month) vce(cluster id)
eststo reghdfe   // 将结果保存为reghdfe

* 对比查看(需要更改title和keep中的想要对比的变量)
//可estout, varlabels(_all)查看具体的变量名
estout *, title("The Comparison of Actual Parameter Values") ///
         cells(b(star fmt(%9.3f)) se(par)) ///
         stats(N N_g, fmt(%9.0f %9.0g) label(N Groups)) ///
         legend collabels(none) varlabels(_cons Constant) keep(x1 x2 1.D#1.post ) // 结果中是系数和（标准误）

//可estout, varlabels(_all)查看具体的变量名



/*******************************************************************平行趋势检验******************************************************/

// 时间趋势图法

* 生成stata可理解的时间变量
gen time = ym(year, month)
format time %tm

* 生成按时间分组的变量
bysort D time: egen mean_y = mean(y)

* 绘图
twoway (connected mean_y time if D == 1, sort lcolor(blue) lwidth(medium) lpattern(solid)) ///
       (connected mean_y time if D == 0, sort lcolor(red) lwidth(medium) lpattern(dash)), ///
       legend(label(1 "Treated") label(2 "Untreated")) ///
       title("Parallel Trend Test") xtitle("Year-Month") ytitle("Mean of Y") ///
	   xline(`=tm(2005m3)', lcolor(black) lpattern(dash)) ///
	   xlabel(`=tm(2003m1)'(3)`=tm(2007m12)', format(%tm) angle(45)) ///
	   xscale(range(`=tm(2003m1)' `=tm(2007m12)'))