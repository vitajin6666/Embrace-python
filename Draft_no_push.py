"""
    线性回归：通过构建线性模型来进行预测的一种回归算法
"""

# numpy
import numpy as np
np.set_printoptions(precision=2) # 用于设置浮点数在显示时的精度为两位小数

# pandas
import pandas as pd

# matplotlib
import matplotlib.pyplot as plt

# sklearn
from sklearn.linear_model import LinearRegression, SGDRegressor
    # 对于小到中等规模的数据集，LinearRegression 往往是更好的选择；
    # 而对于非常大的数据集或需要频繁更新模型的应用，SGDRegressor 可能更合适。
from sklearn.preprocessing import StandardScaler
    # perform z-score normalization
from sklearn.model_selection import train_test_split
    # 允许你按指定的比例随机分割数据集，通常分为训练数据和测试数据。这是用来验证和测试模型性能的标准实践，有助于检测模型是否过拟合训练数据
from sklearn.metrics import mean_squared_error, r2_score
    # 导入两种评估回归模型性能的常用指标：均方误差（Mean Squared Error, MSE）和 R² 得分（R-squared score，或称为决定系数）

# csv文件用这段代码
data = pd.read_csv('Student_Performance.csv')
data['Extracurricular Activities'] = data['Extracurricular Activities'].map({'Yes': 1, 'No': 0})

def linear():
    X = data.drop('Performance Index', axis=1) # 去掉target列，剩下的是features
    y = data['Performance Index'] # 单独拿出target列
    X_features = ['Hours Studied', 'Previous Scores', 'Extracurricular Activities', 'Sleep Hours', 'Sample Question Papers Practiced']

    # 划分数据集
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

    # 标准化
    std1 = StandardScaler()
    x_train = std1.fit_transform(x_train)
    x_test = std1.transform(x_test)

    std2 = StandardScaler()
    y_train = std2.fit_transform(y_train.reshape(-1, 1))  # 必须传二维
    y_test = std2.transform(y_test.reshape(-1, 1))

    # 正规方程的解法
    # 建立模型
    lr = LinearRegression()  # 通过公式求解
    lr.fit(x_train, y_train)

    # 预测结果
    y_predict = lr.predict(x_test)  # 这个结果是标准化之后的结果，需要转换
    y_predict_inverse = std2.inverse_transform(y_predict)
    print(y_predict_inverse)

    # 均方误差
    error = mean_squared_error(y_test_ori, y_predict_inverse)
    print("均方误差：", error)

    # 梯度下降算法求解
    sgd = SGDRegressor()  # 通过梯度下降求解
    sgd.fit(x_train, y_train)

    # 预测结果
    y_predict_sgd = sgd.predict(x_test)
    y_predict_sgd_inverse = std2.inverse_transform(y_predict_sgd)  # 反归一化
    print("sgd预测结果：", y_predict_sgd_inverse)

    # 均方误差
    error_sgd = mean_squared_error(y_test_ori, y_predict_sgd_inverse)
    print("sgd的均分误差：", error_sgd)


if __name__ == "__main__":
    linear()

