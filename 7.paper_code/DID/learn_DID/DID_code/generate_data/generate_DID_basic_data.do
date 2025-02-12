///数据结构为 60个体*5年*12个月，年份从2003-2007共 3600个观测值的平衡面板数据。
///设定 2005 年3月为政策发生的时间，id 取值在 30-60 范围内的个体为处理组，剩余的个体为控制组。

clear all
set obs 60 
set seed 10101
gen id = _n

/// 扩展为 60个体 × 5年 × 12个月 = 3600个观测值
expand 60  // 每个个体扩展为60个月（5年 × 12个月）

/// 生成月份标识（1-60）
bys id: gen period = _n  

/// 生成年份和月份
gen year = floor((period - 1) / 12) + 2003  // 生成年份（2003-2007）
gen month = mod(period - 1, 12) + 1  // 生成月份（1-12）
gen year_month = string(year) + string(month, "%02.0f") 

/// 设定面板数据结构
xtset id period

/// 生成协变量 x1, x2
gen x1 = rnormal(1, 7)
gen x2 = rnormal(2, 5)

/// 生成个体固定效应和时间固定效应
gen ind_fe = rnormal(0, 5)  // 个体固定效应
gen time_fe = rnormal(0, 3) // 时间固定效应

/// 生成 treat 和 post 变量
gen D = (id > 29)  // 处理组：id 30-60
gen post = (year > 2005 | (year == 2005 & month >= 3))  // 政策时间：2005年3月及以后

/// 生成潜在结果 y0 和 y1
gen y0 = 10 + 5 * x1 + 3 * x2 + ind_fe + time_fe + rnormal()  // 控制组潜在结果
gen y1 = y0  // 初始化处理组潜在结果

/// 政策效果随时间变化（每年增加4）
forvalues y = 2005/2007 {
    forvalues m = 1/12 {
        // 政策效应从2005年3月开始
        replace y1 = y0 + 27 + 4 * (`y' - 2005) if year == `y' & month == `m' & D == 1 & (year > 2005 | (year == 2005 & month >= 3))
    }
}

/// 生成最终结果变量 y
gen y = y0 + D * (y1 - y0)

/// 去除协变量和个体效应对 y 的影响，画出剩余残差的图像
xtreg y x1 x2, fe r
predict e, ue
binscatter e period, line(connect) by(D)
