#!/usr/bin/env python
# -*- coding: utf-8 -*-
# encoding:utf-8
# @Time     : 2018-05-25 09:41:33
# @Author   : chengengcong
# @File     : S0021-Hegui-Linux-CpuCount
# @Library  : psutil
# @Parameter: {"cpu_count":"8"}
'''cpu物理数,使用于红帽，centos等linux系统'''
import json
import platform
import sys
import psutil
import time
import re

def nfdwreturn(value, unit='', status=0, key=''):
    '''格式化并自动化阈值判断'''
    if not key:
        key = sys._getframe(1).f_code.co_name
    try:
        parameter = eval(sys.argv[1])
        if key in parameter and status == 0:
            if(str(value) > str(parameter[key])):
                status = 1
            else:
                status = 0
        return {key: {'value': value, 'unit': unit, 'status': status}}
    except:
        return {key: {'value': value, 'unit': unit, 'status': status}}

def cpu_count():
    '''cpu物理数'''
    return nfdwreturn(psutil.cpu_count(logical=False), '')


if __name__ == "__main__":
    print(cpu_count())
