# coding: utf-8
# @Time : 2018-4-8
# @Author : Tanxiaoshu
# @Company : NanWangZongBu
# @File : os_all_info_001.py
# @Library : install psutil,
# @Parameter:{'cpu_percent':"50",'mem_percent':"50",'swap_mem_percent':"50",'disk_percent':"50"}
# 文件名称要包含脚本对象类型，脚本对象，脚本，功能，脚本版本号和文件扩展名
'''
脚本需要传递一个字典参数，如上parameter格式，参数需要加引号
执行账号需要有root权限并能免密码提权，脚本巡检linux系统。
'''

import platform
import time
import socket
import subprocess
import re
import os
import multiprocessing
from collections import namedtuple
import sys
import datetime


if len(sys.argv) == 1:
	monitors = {"cpu_percent":"80","mem_percent":"80","swap_mem_percent":"30","disk_percent":"80"}
else:
	monitors = eval(sys.argv[1])
result = []

def ip():
	'''获取主机IP地址'''
	try:
		sock = socket.socket(socket.AF_INET,socket.SOCK_DGRAM)
		sock.connect(('8.8.8.8',80))
		Ip = sock.getsockname()[0]
		return {'ip':{'value': Ip,'unit': 0,'status': 0}}
	except:
		return {'ip':{'value': 'Error','unit': 0,'status': 1}}

def os_type():
	'''获取主机类型'''
	os = platform.system()
	return {'system_type':{'value':os,'unit':0,'status':0}}

def os_version():
	'''获取主机版本'''
	osversion = platform.uname()[2]
	return {'system_version':{'value':osversion,'unit':0,'status':0}}

def uptime():
	'''主机运行时间'''
	with open("/proc/uptime") as f:
		for line in f:
			up_time = float(line.split()[0].split(".")[0]) / 86400
			os_uptime = float("%.1f" % up_time)
			return {'os_uptime':{'value':os_uptime,'unit':'day','status':0}}

def now_time():
	'''主机当前时间'''
	nowtime = time.strftime('%Y-%m-%d %H:%M:%S',time.localtime())
	return {'now_time':{'value':nowtime,'unit':0,'status':0}}


def lv():
	'''主机LVM状态'''
	try:
		res = subprocess.Popen(['lvdisplay'], stdout=subprocess.PIPE, shell=True)
		stdout = res.stdout
		# print(stdout)
		lv_status = []
		for line in stdout.readlines():
			# print(line)
			if re.search('LV Status', line):
				stat = line.split()[2]
				if stat == "NOT available":
					lv_status.append(stat)
		if len(lv_status) > 0:
			return {'lv_status':{'value':'NOT available','unit':0,'status':len(lv_status)}}
		else:
			return {'lv_status': {'value': 'available', 'unit': 0, 'status': len(lv_status)}}
	except:
		return {'lv_status':{'value': 'Error', 'unit': 0, 'status': 1}}

def message_log():
	'''主机message日志巡检'''
	month = {'01': 'Jan', '02': 'Feb', '03': 'Mar', '04': 'Apr', '05': 'May', '06': 'June', '07': 'July', '08': 'Aug', '09': 'Sept', '10': 'Oct', '11': 'Nov', '12': 'Dec'}
	try:
		os_month = time.strftime("%m", time.localtime())
		os_day = re.search('[1-9].?', time.strftime("%d", time.localtime())).group()
		if int(os_day) < 10:
			day = month[os_month] + '  ' + os_day
		else:
			day = month[os_month] + ' ' + os_day

		with open('/var/log/messages', 'r') as f:
			i = 0
			for line in f:
				# print(line)
				if re.search(r'%s.*(Error|error)' % (day), line):
					i += 1
			if i > 0:
				status = 1
			else:
				status = 0
		return {'message_log':{'value':i,'unit':0,'status':status}}
	except:
		return {'message_log':{'value':'Error','unit':0,'status':1}}

def dmesg_log():
	'''主机dmesg日志巡检'''
	try:
		with open('/var/log/dmesg', 'r') as f:
			i = 0
			for line in f:
				# print(line)
				if re.search(r'(Error|error)', line):
					i += 1
			if i > 0:
				status = 1
			else:
				status = 0
		return {'dmesg_log':{'value':i,'unit':0,'status':status}}
	except:
		return {'dmesg_log':{'value':'Error','unit':0,'status':1}}

def cpu():
	'''获取主机CPU个数'''
	cpu_core = multiprocessing.cpu_count()
	return {'cpu_core':{'value':cpu_core,'unit':0,'status':0}}

def cpu_percent():
	'''获取主机CPU状态及使用率'''
	cmd1 = subprocess.Popen('cat /proc/stat|grep -w cpu', shell=True, stdout=subprocess.PIPE)
	cpu_info1 = cmd1.stdout.read().strip().split()
	cpu_used1 = int(cpu_info1[1])
	total1 = int(cpu_info1[1]) + int(cpu_info1[2]) + int(cpu_info1[3]) + int(cpu_info1[4]) + int(cpu_info1[5]) + int(cpu_info1[6]) + int(cpu_info1[7])
	time.sleep(1)
	cmd2 = subprocess.Popen('cat /proc/stat|grep -w cpu', shell=True, stdout=subprocess.PIPE)
	cpu_info2 = cmd2.stdout.read().strip().split()
	cpu_used2 = int(cpu_info2[1])
	total2 = int(cpu_info2[1]) + int(cpu_info2[2]) + int(cpu_info2[3]) + int(cpu_info2[4]) + int(cpu_info2[5]) + int(cpu_info2[6]) + int(cpu_info2[7])
	cpu_idel = cpu_used2 - cpu_used1
	total = total2 - total1
	cpu_used = cpu_idel * 100 // total
	# cpu_result['cpu_used'] = cpu_used
	if int(cpu_used) > int(monitors['cpu_percent']):
		status = 1
	else:
		status = 0
	return {'cpu_used':{'value':cpu_used,'unit':"%",'status':status}}

def process():
	'''获取主机进程数'''
	stdout = subprocess.Popen('ps -ef|wc -l',shell=True,stdout=subprocess.PIPE).stdout.read().strip()
	p = stdout
	return {'process':{'value':p,'unit':0,'status':0}}

def process_zombie():
	'''获取主机僵尸进程数'''
	stdout = subprocess.Popen('top -n1|head -2|tail -1', shell=True, stdout=subprocess.PIPE).stdout.read().strip()
	#zombie = re.search(r'stopped,\s*?([0-9]).*zombie',stdout)
	zombie = re.split('\s+',stdout)
	z = zombie[-2]
	if z > 0:
		status = 1
	else:
		status = 0
	return {'zombie':{'value':z,'unit':0,'status':status}}


#巡检磁盘
disk_ntuple = namedtuple('partition', 'device mountpoint fstype')
usage_ntuple = namedtuple('usage', 'total used free percent')  # 获取当前操作系统下所有磁盘

def disk_partitions(all=False):
	# 获取文件系统及所使用的分区
	"""Return all mountd partitions as a nameduple. 
	If all == False return phyisical partitions only. 
	"""
	phydevs = []
	f = open("/proc/filesystems", "r")
	for line in f:
		if not line.startswith("nodev"):
			phydevs.append(line.strip())
	# print(phydevs)
	f.close()

	retlist = []
	f = open('/etc/mtab', "r")
	for line in f:
		if not all and line.startswith('none'):
			continue
		fields = line.split()
		device = fields[0]
		mountpoint = fields[1]
		# print(mountpoint)
		fstype = fields[2]
		# print(line)
		if not all and fstype not in phydevs:
			continue
		if device == 'none':
			device = ''
		ntuple = disk_ntuple(device, mountpoint, fstype)
		retlist.append(ntuple)
	f.close
	# print(retlist)
	return retlist

def disk_usage(path):
	# 统计某磁盘使用情况，返回对象
	"""Return disk usage associated with path."""
	st = os.statvfs(path)
	free = (st.f_bavail * st.f_frsize)
	total = (st.f_blocks * st.f_frsize)
	used = (st.f_blocks - st.f_bfree) * st.f_frsize
	try:
		percent = (float(used) / total) * 100
	except ZeroDivisionError:
		percent = 0
	return usage_ntuple(total, used, free, int(percent))

def disk():
	for i in disk_partitions():
		# 获取磁盘使用率
		# print(i[1])
		value = list(disk_usage(i[1]))
		if int(value[3]) < monitors['disk_percent']:
			status = 0
		else:
			status = 1
		return {i[1]:{'value':value[3],'unit':0,'status':status}}

def mem_total():
	'''获取内存总大小，使用率等'''
	meminfo = {}
	with open('/proc/meminfo') as f:
		for line in f:
			meminfo[line.split(':')[0]] = int(line.split(':')[1].strip().split()[0])
	mem_total = int(meminfo['MemTotal']) // 1024
	return {'mem_total':{'value':mem_total,'unit':"M","status":0}}

def mem_used():
	'''获取内存使用大小，使用率等'''
	meminfo = {}
	with open('/proc/meminfo') as f:
		for line in f:
			meminfo[line.split(':')[0]] = int(line.split(':')[1].strip().split()[0])
	mem_used = (int(meminfo['MemTotal']) - int(meminfo['MemFree']) - int(meminfo['Buffers']) - int(meminfo['Cached'])) // 1024
	return {'mem_used':{'value':mem_used,'unit':'M','status':0}}

def mem_percent():
	'''获取内存大小，使用率等'''
	meminfo = {}
	with open('/proc/meminfo') as f:
		for line in f:
			meminfo[line.split(':')[0]] = int(line.split(':')[1].strip().split()[0])
	mem_total = int(meminfo['MemTotal']) // 1024
	mem_used = (int(meminfo['MemTotal']) - int(meminfo['MemFree']) - int(meminfo['Buffers']) - int(meminfo['Cached'])) // 1024
	mem_used_percent = int(mem_used) * 100 // int(mem_total)
	if mem_used_percent > monitors['mem_percent']:
		status = 1
	else:
		status = 0
	return {'mem_used_percent':{'value':mem_used_percent,'unit':0,'status':status}}

def swap_total():
	'''获取swap大小及使用率等'''
	with open('/proc/meminfo','r') as f:
		for line in f:
			if line.startswith('SwapTotal'):
				swaptotal = line.split()[1]
				swaptotal = int(swaptotal) // 1024
				return {'swaptotal':{'value':swaptotal,'unit':"M",'status':0}}

def swap_percent():
	'''获取swap大小及使用率等'''
	with open('/proc/meminfo','r') as f:
		for line in f:
			if line.startswith('SwapTotal'):
				swaptotal = line.split()[1]
			elif line.startswith('SwapFree'):
				swapfree = line.split()[1]
		swap_used = (int(swaptotal) - int(swapfree)) // int(swaptotal) * 100
		if swap_used > 0:
			status = 1
		else:
			status = 0
		return {'swap_used_percent':{'value':swap_used,'unit':0,'status':status}}

if __name__ == '__main__':
    if platform.system().lower() == 'linux':
        for i in ip(),os_type(),os_version(),uptime(),now_time(),lv(),message_log(),dmesg_log(),cpu(),cpu_percent(),\
                 process(),process_zombie(),disk(),mem_total(),mem_used(),mem_percent(),swap_total(),swap_percent():
            result.append(i)
        print result
    else:
        print("please run in linux system!")



