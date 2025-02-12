*** 加载数据文件
use "D:\python\learn_python\7.paper_code\DID\learn_DID\基础变量处理\basic_variable.dta" , clear

*** 处理最基础的数据，使其生成basic panel 04_06.dta
/********************************************************** id不用动 ****************************************** */


/********************************************************** 时间相关变量 ****************************************** */

* 1.根据year,month生成time（YYYYMM，例如：200405）
gen time = string(Year) + string(Month, "%02.0f") // 创建一个字符串变量，格式为 "YYYYMM",例如：200405

gen year_month = year*100+month //生成数值型year_month

destring year_month, replace // 将字符串形式转换成字符型

gen event_time = year*12 + month - (2005*12+3) //构造相对时间变量

* 还有一种可以生成stata可识别的时间变量的方法（只在画图法平行趋势检验中用）格式为：2004m1
gen time = ym(year, month)
format time %tm


* 2.生成dym*
levelsof time , local(ym_list) // 获取所有唯一的 "YYYYMM" 值

//根据每个唯一的 "YYYYMM" 值生成 dummy 变量
foreach ym in `ym_list' {
    di "Processing: `ym'"
    gen dym_`ym' = (time == "`ym'")
}

* 3.生成T(post)
gen reform = ( Year > 2005) | ( Year == 2005 & Month >= 9)

* 4.(可选）根据时间生成某些变量

/********************************************************** 生成D(Treat) ****************************************** */
gen treatment = (Division<=4)

/**********************************************************生成多分类变量的dummy（0/1二分类的变量不用动） ****************************************** */

* 方法1：变量名自动生成为name_n
tab Position, gen(Position_) 
* 会从Position自动生成Position_1,Position_2,Position_3...（原本position有几个值就自动生成几个Position_n）

* 方法2：允许灵活自命名
gen econ = ( Division == 1)
gen generalnews = ( Division == 2)
gen politics = ( Division == 3)
gen edu = ( Division == 4)
gen localnews = ( Division == 5)
gen entertain = ( Division == 6)
gen consumption = ( Division == 7)
gen region = ( Division == 8)

/**************************************************计算连续变量（因变量取对数或计算高阶，自变量一般不用取对数） ****************************************** */

gen lnquantity = ln( QuantityScore )
gen age2 = Age ^2

/********************************************************** 生成交互项 ****************************************** */
gen reform_treatment = reform * treatment //T*D

// 或者在回归式子中直接写:i.reform##i.treatment 指代交互项





