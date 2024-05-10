import numpy as np

def load_data():
    data = np.loadtxt(r"D:\python\learn_python\ML\linear regression\1_Univariate\Exercise\data\ex1data1.txt", delimiter=',')
    X = data[:,0]
    y = data[:,1]
    return X, y

def load_data_multi():
    data = np.loadtxt("data/ex1data2.txt", delimiter=',')
    X = data[:,:2] # 这行代码意味着从 data 数组中选择所有行 (: 表示选取所有行) 和前两列 (:2 表示从第0列开始直到但不包括第2列)。
    y = data[:,2] # 这行代码意味着从 data 数组中选择所有行和第三列（列索引从0开始，因此2表示第三列）。
    return X, y
