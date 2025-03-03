clear all
set seed 10101

// 生成80个个体，每个个体有60个月（5年）的数据，总共4800个观察值
set obs 4800
gen id = ceil(_n / 60)  // 每个个体有60个月的观察值
bysort id: gen time = ym(2003, 1) + _n - 1  // 生成时间变量，从2003年1月开始
format time %tm  // 设置时间为月度格式



// 转换 time 为日度时间变量，以便正确提取年份和月份
gen temp_time = dofm(time)  // 将月度时间变量转换为日度时间变量
gen year = year(temp_time)  // 提取年份
gen month = month(temp_time)  // 提取月份
gen year_month = year*100+month 

// 设置面板数据结构
xtset id time

// 生成协变量
gen x1 = rnormal(1, 7)  // 协变量x1，均值为1，标准差为7
gen x2 = rnormal(2, 5)  // 协变量x2，均值为2，标准差为5

// 生成处理变量D和出生日期birth_date
gen D = 0  // 初始化处理变量
gen birth_date = .  // 初始化出生日期（政策干预时间）

// 设置政策干预时间
forvalues i = 1/20 {
    replace D = 1 if id == `i' & time >= ym(2004, 6)  // 1-20号个体在2004年6月接受干预
    replace birth_date = ym(2004, 6) if id == `i'
}

forvalues i = 21/40 {
    replace D = 1 if id == `i' & time >= ym(2005, 6)  // 21-40号个体在2005年6月接受干预
    replace birth_date = ym(2005, 6) if id == `i'
}

forvalues i = 41/60 {
    replace D = 1 if id == `i' & time >= ym(2006, 6)  // 41-60号个体在2006年6月接受干预
    replace birth_date = ym(2006, 6) if id == `i'
}

format birth_date %tm //可以从数字533变回2004m6

gen relative_time = time-birth_date


// 61-80号个体不接受干预，D和birth_date保持为0和缺失

// 生成因变量y
gen y0 = 10 + 5 * x1 + 3 * x2 + (time - ym(2003, 1)) + id + rnormal()  // 未接受干预的潜在结果
gen y1 = y0 + 10 if D == 1  // 接受干预的潜在结果，政策效果为10
gen y = cond(D == 1, y1, y0)  // 实际观察到的结果

// 固定效应回归并计算残差
xtreg y x1 x2, fe r
predict e, ue  // 计算残差

// 绘制残差图
binscatter e time, line(connect) by(D)




