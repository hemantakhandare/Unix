
import paramiko

host = "34.67.110.206"
username = "virat"
password = "virat"


# In[26]:


commands = [
    "pwd",
    "id",
    "uname -a",
    "df -h"
]


# In[22]:


private_key=r"C:\Users\hemant.khandare\OneDrive - Accenture\Desktop\python\virat_private_key.ppk"


# In[24]:


ssh = paramiko.SSHClient()
try:
       
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect("34.67.110.206",port=22,username=username, password=password,key_filename=private_key)
    #ssh.connect("34.67.110.206",port=22,username=username,key_filename=private_key)

except:
    
    print("Not connected!!!")
    
    
else:
    print("Connected!!!")


# In[17]:


# execute the commands

for command in commands:
    print("="*50, command, "="*50)
    stdin, stdout, stderr = ssh.exec_command(command)
    print(stdout.read().decode())
    err = stderr.read().decode()
    if err:
        print(err)
