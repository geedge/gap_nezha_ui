import json
import random
import hashlib
import os

#判断一个字符或字符串是否包含于另一个字符串:a是否再b中，是否则返回True，否则返回Falsle
def aisincludeb(a,b):
	result = a in b
	print(result)
	return result
	
#删除字符串当前前几个，或后几个：sourcestr源串，a[2:-2] 表示去掉前面两个和后面两个，如果光去掉后面的a[:-2]
def removeBeforOrAfter(sourcestr,a):
	#a = "16541616584984"
	#a = a[2:-2]
	sourcestr = sourcestr[a]
	return result
	
#分离字符串
def	string2list(str,split):
	return	str.split(split)

#用于生成一个指定范围内的整数
def	randomint(a,b):
	return random.randint(a,b)
	
#较小文件处理方法： 
def get_md5_01(file_path):
	md5 = None
	if os.path.isfile(file_path):
		f = open(file_path,'rb')
		md5_obj = hashlib.md5()
		md5_obj.update(f.read())
		hash_code = md5_obj.hexdigest()
		f.close()
		md5 = str(hash_code).lower()
	return md5

#较大文件处理方法：
def get_md5_02(file_path):
	f = open(file_path,'rb') 
	md5_obj = hashlib.md5()
	while True:
		d = f.read(8096)
		if not d:
			break
		md5_obj.update(d)
	hash_code = md5_obj.hexdigest()
	f.close()
	md5 = str(hash_code).lower()
	return md5