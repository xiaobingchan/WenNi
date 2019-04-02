"""
    Group Chat Robot v0.1
"""
# coding: utf-8

import itchat, re
from itchat.content import *
import random
import json

"""
    Constants
"""
REPLY = {'工作':['且不说你的工作多么认真，我并没有见过，但是从你的字里行间，我发现了乔布斯的影子和小扎的气息，这已经不是一份工作那么简单，而是一场精神饕餮！',
               '你拥有了这个年龄段近半数人无法拥有的理想职业，太优秀了！',
               '工作这件事，大家都习以为常，只有你让大家开始思考这个问题，说明你善于反思和质疑当前的制度，你的公司会因为你这样的人变得更好！'],
         '学习':['这么多优秀的同龄人相聚在这里，一定是场思想交流的盛宴。','看到群友们的发言，真是排山倒海，气宇轩昂之势！',
               '你这句话完美的表达了你想被夸的坚定信念，你一定是一个执着追求自己理想的人！'],
         'default': ['太棒了','真不错','好开心','嗯嗯','没什么好说的了，我送你一道彩虹屁吧']}

@itchat.msg_register([TEXT], isGroupChat=True)
def text_reply(msg):

    if msg['User']['NickName'] == '测试卷':
        print('Message from: %s' % msg['User']['NickName'])
        # 发送者的昵称
        username = msg['ActualNickName']
        print('Who sent it: %s' % username)

        match = re.search('工作', msg['Text']) or re.search('加班', msg['Text'])
        if match:
            print('-+-+' * 5)
            print('Message content:%s' % msg['Content'])
            print('工作、加班 is: %s' % (match is not None))
            randomIdx = random.randint(0, len(REPLY['工作']) - 1)
            itchat.send('%s\n%s' % (username, REPLY['工作'][randomIdx]), msg['FromUserName'])

        match = re.search('学习', msg['Text']) or re.search('考试', msg['Text'])
        if match:
            print('-+-+' * 5)
            print('Message content:%s' % msg['Content'])
            print('学习、考试 is: %s' % (match is not None))
            randomIdx = random.randint(0, len(REPLY['学习']) - 1)
            itchat.send('%s\n%s' % (username, REPLY['学习'][randomIdx]), msg['FromUserName'])

        print('isAt is:%s' % msg['isAt'])

        if msg['isAt']:
            randomIdx = random.randint(0, len(REPLY['default']) - 1)
            itchat.send('%s\n%s' % (username, REPLY['default'][randomIdx]), msg['FromUserName'])
            print('-+-+'*5)

itchat.auto_login(enableCmdQR=True, hotReload=True)
itchat.run()