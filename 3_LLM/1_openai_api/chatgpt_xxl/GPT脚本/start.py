import sys
import csv
import time

import yaml
import openai
import threading
from PyQt5.QtCore import Qt
from PyQt5.QtGui import QFont
from PyQt5.QtWidgets import QApplication, QWidget, QLabel, QLineEdit, QPushButton


class MyApp(QWidget):
    def __init__(self):
        super().__init__()
        self.initUI()

    def initUI(self):
        # 设置窗口标题
        self.setWindowTitle('My PyQt5 App')
        # 设置窗口大小和位置
        self.setGeometry(300, 300, 400, 200)

        # 创建标签控件，显示"问题："
        question_label = QLabel('问题：', self)
        question_label.move(30, 30)
        question_label.setFont(QFont('Arial', 12, QFont.Bold))

        # 创建文本输入框控件，用于输入问题
        self.question_edit = QLineEdit(self)
        self.question_edit.move(100, 27)
        self.question_edit.resize(240, 26)
        self.question_edit.setFont(QFont('Arial', 12))

        # 创建标签控件，显示"重复次数："
        repeat_label = QLabel('重复次数：', self)
        repeat_label.move(30, 70)
        repeat_label.setFont(QFont('Arial', 12, QFont.Bold))

        # 创建文本输入框控件，用于输入重复次数
        self.repeat_edit = QLineEdit(self)
        self.repeat_edit.move(100, 67)
        self.repeat_edit.resize(240, 26)
        self.repeat_edit.setFont(QFont('Arial', 12))

        # 创建按钮控件，用于确认用户输入
        self.button = QPushButton('确定', self)
        self.button.move(150, 110)
        self.button.resize(100, 30)
        self.button.setFont(QFont('Arial', 12, QFont.Bold))
        self.button.setStyleSheet('background-color: #4CAF50; color: white')

        # 创建标签控件，用于显示返回值
        self.result_label = QLabel(self)
        self.result_label.move(30, 150)
        self.result_label.resize(340, 30)
        self.result_label.setFont(QFont('Arial', 12))
        self.result_label.setAlignment(Qt.AlignCenter)
        self.result_label.setStyleSheet('background-color: #f2f2f2')

        # 显示窗口
        self.show()

        # 设置窗口样式表
        self.setStyleSheet('background-color: white')

        # 连接按钮的clicked信号到on_click方法
        self.button.clicked.connect(self.on_click)

    def on_click(self):
        # 获取用户输入的问题和重复次数
        question = self.question_edit.text()
        repeat = self.repeat_edit.text()

        # 将重复次数转换为整数
        try:
            repeat = int(repeat)
        except ValueError:
            repeat = 1

        # 调用goon函数，并在标签控件中显示返回值
        result = goon(question, repeat)
        self.result_label.setText(result)


def get(prompt, apikey):
    '''
    调用api
    :param prompt: 输入问题
    :param apikey: 请求的apikey
    :return: 返回结果
    '''
    # 设置 API 密钥
    openai.api_key = apikey
    # 调用 ChatGPT
    client = openai.OpenAI()  # 此行新加
    response =  client.chat.completions.create( # 和下一行相互替换
    # openai.ChatCompletion.create( # 原本的代码
        model="gpt-3.5-turbo",
        messages=[
            {"role": "user", "content": prompt},
        ],
        temperature=1.0,
    )
    # 输出响应结果
    answer = response.choices[0].message.content.strip()
    print(answer)
    return answer

def saveword(question, words):
    with open('answer.csv', 'a', encoding='utf-8-sig', newline='') as f:
        writer = csv.writer(f)
        writer.writerow([question, words])



def process_item(item):
    # 处理每个列表项的代码
    n = 0
    while n < item[2] / item[3]:
        data = get(item[1], item[0])
        saveword(item[1], data)
        time.sleep(17)
        n += 1



def goon(question, repeat):
    # TODO: 在这里编写您的代码，执行所需的操作，并返回相应的结果
    with open('config.yaml', 'r', encoding='utf8') as file:
        # 使用PyYAML加载YAML文件
        data = yaml.safe_load(file)
        # 确认文件路径并打开文件


    print(data)
    allcanshu = []
    apikey = data['apikey']
    lst_len = len(apikey)
    if lst_len < 10:
        thread_count = lst_len
    else:
        thread_count = lst_len // 2
    for i in apikey:
        allcanshu.append([i, question, repeat, lst_len])

    threads = []
    for i in range(thread_count):
        start_index = i * (lst_len // thread_count)
        end_index = (i + 1) * (lst_len // thread_count)
        t = threading.Thread(target=process_item, args=(allcanshu[start_index:end_index]))
        threads.append(t)
        t.start()

    return '正在爬取，请稍后！'


if __name__ == '__main__':
    # 创建应用程序对象
    app = QApplication(sys.argv)
    # 创建主窗口对象
    my_app = MyApp()
    # 进入应用程序主循环
    sys.exit(app.exec_())
