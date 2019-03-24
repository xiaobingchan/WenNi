import requests
from bs4 import BeautifulSoup        #pip install beautifulsoup4
from urllib.request import urlopen   #pip install requests

data = {'userName': '18565453898', 'password': 'a12345678','checkCode':'','save':'Y','url':''}  # 构造模拟登陆的用户密码格式
r = requests.post('https://sso.taoguba.com.cn/web/login/submit', data=data)    # 向接口post data数据模拟登陆
print(r.text)
print(r.cookies.get_dict())
