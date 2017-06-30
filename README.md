# SaltStack API 调用
## 批量运行shell指令调用方法：

from salt import SaltApi
A = SaltApi(user,pass,url)
minions = A.key_list()
tgt = "1.1.1.1,1.1.2"
result  = A.exec_command(tgt,arg="ls /home/")
return result

## 批量运行自定义工作任务模块:

tgt = ['1.1.1.1','1.1.1.2','1.1.1.3']
result = A.deploy_module(tgt,arg='zabbix')
return result
