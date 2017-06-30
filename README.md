# SaltStack API 调用
## 批量运行shell指令调用方法：

from salt import SaltApi</br>
A = SaltApi(user,pass,url)</br>
minions = A.key_list()</br>
tgt = "1.1.1.1,1.1.2"</br>
result  = A.exec_command(tgt,arg="ls /home/")</br>
return result</br>

## 批量运行自定义工作任务模块:

tgt = ['1.1.1.1','1.1.1.2','1.1.1.3']</br>
result = A.deploy_module(tgt,arg='zabbix')</br>
return result</br>
