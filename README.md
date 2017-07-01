# SaltStack API 


## Usage
### Run Batch Commands
```python
from salt import SaltApi
A = SaltApi(user,pass,url)
minions = A.key_list()
tgt = "1.1.1.1,1.1.2"
result  = A.exec_command(tgt,arg="ls /home/")
return result
```


### Run Batch Tasks 

```python
tgt = ['1.1.1.1','1.1.1.2','1.1.1.3']
result = A.deploy_module(tgt,arg='zabbix')
return result
```

